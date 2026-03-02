/**
 * Supabase Edge Function: orders-relay
 *
 * Actúa como proxy entre Flutter Web y la API de FashionStore.
 * Resuelve el problema de CORS: el navegador no puede hacer POST
 * cross-origin a FashionStore, pero sí puede llamar a Supabase.
 * Esta función reenvía la petición al servidor de FashionStore
 * (servidor-a-servidor, sin restricciones CORS) y devuelve la respuesta.
 *
 * Acciones soportadas:
 *  - request-return  → /api/orders/request-return        (emails + actualiza estado)
 *  - cancel          → /api/orders/cancel                (Stripe refund + emails + stock)
 *  - request-invoice → /api/orders/request-invoice       (genera PDF + envía por email)
 *  - accept-return   → /api/orders/accept-return         (admin: reembolso + email devolución)
 *  - admin-cancel    → /api/orders/admin-cancel           (admin: cancelar + reembolso + email)
 *  - checkout        → /api/checkout/create-session      (crear sesión Stripe, usuario)
 *  - verify-checkout → /api/checkout/verify-session      (verificar pago, usuario)
 *  - reject-return   → (gestionada directamente)          (admin: rechazo + email al cliente)
 *  - accept-partial-return → (gestionada directamente)    (admin: FR- + email con PDFs)
 *
 * Deploy:
 *   supabase functions deploy orders-relay --project-ref sjalsswfvoshyppbbhtv
 */

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import { PDFDocument, rgb, StandardFonts } from 'https://esm.sh/pdf-lib@1.17.1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const FASHION_STORE_URL =
  'https://j4o0084kg0ssoo0wc0ocw0g8.victoriafp.online';

const ENDPOINT_MAP: Record<string, string> = {
  'request-return': '/api/orders/request-return',
  cancel: '/api/orders/cancel',
  'request-invoice': '/api/orders/request-invoice',
  'accept-return': '/api/orders/accept-return',
  'admin-cancel': '/api/orders/admin-cancel',
  checkout: '/api/checkout/create-session',
  'verify-checkout': '/api/checkout/verify-session',
  stock: '/api/products/stock',
  'send-shipping-update': '/api/email/send-shipping-update',
  'send-order-delivered': '/api/email/send-order-delivered',
  'send-newsletter': '/api/email/send-newsletter',
};

// Acciones que requieren cookie de admin en vez de Authorization header
const ADMIN_ACTIONS = new Set(['accept-return', 'admin-cancel', 'send-shipping-update', 'send-order-delivered', 'send-newsletter']);

// Acciones públicas que no requieren Authorization
const PUBLIC_ACTIONS = new Set(['stock']);

// Acciones que se reenvían como GET con query params en vez de POST con body
const GET_ACTIONS = new Set(['stock']);

// Acciones gestionadas directamente en la Edge Function (no se reenvían a FashionStore)
const DIRECT_ACTIONS = new Set(['reject-return', 'accept-partial-return']);

function normalizeHttpUrl(raw: unknown, fallback: string): string {
  if (typeof raw !== 'string') return fallback;

  const trimmed = raw.trim();
  if (!trimmed) return fallback;

  const normalized = trimmed.startsWith('//') ? `https:${trimmed}` : trimmed;

  try {
    const parsed = new URL(normalized, FASHION_STORE_URL);
    const protocol = parsed.protocol.toLowerCase();
    if ((protocol === 'http:' || protocol === 'https:') && parsed.hostname) {
      return parsed.toString();
    }
    return fallback;
  } catch {
    return fallback;
  }
}

function sanitizeCheckoutPayload(payload: Record<string, unknown>): Record<string, unknown> {
  const safePayload: Record<string, unknown> = { ...payload };

  safePayload.successUrl = normalizeHttpUrl(
    payload.successUrl,
    `${FASHION_STORE_URL}/checkout/success`,
  );
  safePayload.cancelUrl = normalizeHttpUrl(
    payload.cancelUrl,
    `${FASHION_STORE_URL}/checkout`,
  );

  const rawItems = Array.isArray(payload.items) ? payload.items : [];
  safePayload.items = rawItems.map((item) => {
    if (!item || typeof item !== 'object' || Array.isArray(item)) return item;

    const itemRecord = { ...(item as Record<string, unknown>) };
    if (typeof itemRecord.image === 'string') {
      const normalizedImage = normalizeHttpUrl(itemRecord.image, '');
      if (normalizedImage) {
        itemRecord.image = normalizedImage;
      } else {
        delete itemRecord.image;
      }
    }
    return itemRecord;
  });

  return safePayload;
}

// ─── Helpers para acciones directas ─────────────────────────────────

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY') || '';
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || '';
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';

function getSupabaseAdmin() {
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
}

async function sendEmail(to: string[], subject: string, html: string, attachments?: Array<{filename: string; content: Uint8Array}>) {
  const emailBody: Record<string, unknown> = {
    from: 'FashionMarket <noreply@roomieapp.info>',
    to,
    subject,
    html,
  };
  if (attachments && attachments.length > 0) {
    emailBody.attachments = attachments.map(a => ({
      filename: a.filename,
      content: btoa(String.fromCharCode(...a.content)),
    }));
  }
  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(emailBody),
  });
  if (!res.ok) {
    const err = await res.text();
    console.error('[sendEmail] Error:', err);
  }
  return res;
}

// ─── PDF Generation (factura rectificativa) ──────────────────────────

async function generateCreditNotePDF(
  creditNote: Record<string, unknown>,
  orderNumber: string,
  originalInvoiceNumber: string,
): Promise<Uint8Array> {
  const doc = await PDFDocument.create();
  const page = doc.addPage([595, 842]); // A4
  const font = await doc.embedFont(StandardFonts.Helvetica);
  const fontBold = await doc.embedFont(StandardFonts.HelveticaBold);
  const { height } = page.getSize();

  let y = height - 50;

  // Header
  page.drawText('FACTURA RECTIFICATIVA', { x: 50, y, font: fontBold, size: 18, color: rgb(0.8, 0.2, 0.2) });
  y -= 25;
  page.drawText(`${creditNote.invoice_number}`, { x: 50, y, font: fontBold, size: 14, color: rgb(0.3, 0.3, 0.3) });
  y -= 18;
  page.drawText(`Factura original: ${originalInvoiceNumber}`, { x: 50, y, font, size: 10, color: rgb(0.5, 0.5, 0.5) });
  y -= 18;
  page.drawText(`Pedido: #${orderNumber}`, { x: 50, y, font, size: 10, color: rgb(0.5, 0.5, 0.5) });
  y -= 18;
  page.drawText(`Fecha: ${new Date().toLocaleDateString('es-ES')}`, { x: 50, y, font, size: 10, color: rgb(0.5, 0.5, 0.5) });

  y -= 30;

  // Customer info
  page.drawText(`Cliente: ${creditNote.customer_name || 'N/A'}`, { x: 50, y, font, size: 10 });
  y -= 15;
  page.drawText(`Email: ${creditNote.customer_email || 'N/A'}`, { x: 50, y, font, size: 10 });

  y -= 30;

  // Table header
  page.drawRectangle({ x: 45, y: y - 5, width: 505, height: 20, color: rgb(0.9, 0.9, 0.9) });
  page.drawText('Producto', { x: 50, y, font: fontBold, size: 9 });
  page.drawText('Talla', { x: 280, y, font: fontBold, size: 9 });
  page.drawText('Cant.', { x: 340, y, font: fontBold, size: 9 });
  page.drawText('Precio/ud', { x: 400, y, font: fontBold, size: 9 });
  page.drawText('Total', { x: 480, y, font: fontBold, size: 9 });
  y -= 20;

  // Items
  const items = (creditNote.items as Array<Record<string, unknown>>) || [];
  for (const item of items) {
    const name = String(item.product_name || '').substring(0, 35);
    const qty = Number(item.quantity || 0);
    const price = Number(item.price || 0);
    const total = Number(item.total || 0);
    page.drawText(name, { x: 50, y, font, size: 9 });
    page.drawText(String(item.size || ''), { x: 280, y, font, size: 9 });
    page.drawText(String(qty), { x: 340, y, font, size: 9, color: rgb(0.8, 0.2, 0.2) });
    page.drawText(`€${price.toFixed(2)}`, { x: 400, y, font, size: 9 });
    page.drawText(`€${total.toFixed(2)}`, { x: 480, y, font, size: 9, color: rgb(0.8, 0.2, 0.2) });
    y -= 16;
  }

  y -= 10;
  // Line
  page.drawLine({ start: { x: 45, y: y + 5 }, end: { x: 550, y: y + 5 }, thickness: 0.5, color: rgb(0.7, 0.7, 0.7) });

  // Totals
  y -= 15;
  page.drawText(`Subtotal: €${Number(creditNote.subtotal || 0).toFixed(2)}`, { x: 400, y, font, size: 10 });
  y -= 15;
  page.drawText(`IVA (21%): €${Number(creditNote.iva_amount || 0).toFixed(2)}`, { x: 400, y, font, size: 10 });
  y -= 15;
  page.drawText(`Envío: €0.00`, { x: 400, y, font, size: 10, color: rgb(0.5, 0.5, 0.5) });
  y -= 20;
  page.drawText(`TOTAL: €${Number(creditNote.total || 0).toFixed(2)}`, { x: 400, y, font: fontBold, size: 13, color: rgb(0.8, 0.2, 0.2) });

  // Footer
  y = 50;
  page.drawText('FashionMarket — Factura rectificativa generada automáticamente', { x: 50, y, font, size: 8, color: rgb(0.6, 0.6, 0.6) });

  return doc.save();
}

async function generateOriginalInvoicePDF(
  invoice: Record<string, unknown>,
  orderNumber: string,
): Promise<Uint8Array> {
  const doc = await PDFDocument.create();
  const page = doc.addPage([595, 842]);
  const font = await doc.embedFont(StandardFonts.Helvetica);
  const fontBold = await doc.embedFont(StandardFonts.HelveticaBold);
  const { height } = page.getSize();

  let y = height - 50;

  // Header
  page.drawText('FACTURA', { x: 50, y, font: fontBold, size: 18, color: rgb(0.1, 0.1, 0.1) });
  y -= 25;
  page.drawText(`${invoice.invoice_number}`, { x: 50, y, font: fontBold, size: 14, color: rgb(0.3, 0.3, 0.3) });
  y -= 18;
  page.drawText(`Pedido: #${orderNumber}`, { x: 50, y, font, size: 10, color: rgb(0.5, 0.5, 0.5) });
  y -= 18;
  const createdDate = invoice.created_at ? new Date(String(invoice.created_at)).toLocaleDateString('es-ES') : new Date().toLocaleDateString('es-ES');
  page.drawText(`Fecha: ${createdDate}`, { x: 50, y, font, size: 10, color: rgb(0.5, 0.5, 0.5) });

  y -= 30;
  page.drawText(`Cliente: ${invoice.customer_name || 'N/A'}`, { x: 50, y, font, size: 10 });
  y -= 15;
  page.drawText(`Email: ${invoice.customer_email || 'N/A'}`, { x: 50, y, font, size: 10 });

  y -= 30;

  // Table header
  page.drawRectangle({ x: 45, y: y - 5, width: 505, height: 20, color: rgb(0.93, 0.93, 0.93) });
  page.drawText('Producto', { x: 50, y, font: fontBold, size: 9 });
  page.drawText('Talla', { x: 280, y, font: fontBold, size: 9 });
  page.drawText('Cant.', { x: 340, y, font: fontBold, size: 9 });
  page.drawText('Precio/ud', { x: 400, y, font: fontBold, size: 9 });
  page.drawText('Total', { x: 480, y, font: fontBold, size: 9 });
  y -= 20;

  const items = (invoice.items as Array<Record<string, unknown>>) || [];
  for (const item of items) {
    const name = String(item.product_name || '').substring(0, 35);
    page.drawText(name, { x: 50, y, font, size: 9 });
    page.drawText(String(item.size || ''), { x: 280, y, font, size: 9 });
    page.drawText(String(item.quantity || 0), { x: 340, y, font, size: 9 });
    page.drawText(`€${Number(item.price || 0).toFixed(2)}`, { x: 400, y, font, size: 9 });
    page.drawText(`€${Number(item.total || Number(item.price || 0) * Number(item.quantity || 0)).toFixed(2)}`, { x: 480, y, font, size: 9 });
    y -= 16;
  }

  y -= 10;
  page.drawLine({ start: { x: 45, y: y + 5 }, end: { x: 550, y: y + 5 }, thickness: 0.5, color: rgb(0.7, 0.7, 0.7) });

  y -= 15;
  page.drawText(`Subtotal: €${Number(invoice.subtotal || 0).toFixed(2)}`, { x: 400, y, font, size: 10 });
  y -= 15;
  page.drawText(`IVA (21%): €${Number(invoice.iva_amount || 0).toFixed(2)}`, { x: 400, y, font, size: 10 });
  y -= 15;
  page.drawText(`Envío: €${Number(invoice.shipping_cost || 0).toFixed(2)}`, { x: 400, y, font, size: 10 });
  y -= 20;
  page.drawText(`TOTAL: €${Number(invoice.total || 0).toFixed(2)}`, { x: 400, y, font: fontBold, size: 13 });

  y = 50;
  page.drawText('FashionMarket — Copia de factura original', { x: 50, y, font, size: 8, color: rgb(0.6, 0.6, 0.6) });

  return doc.save();
}

// ─── HTML builders ──────────────────────────────────────────────────

function buildPartialReturnAcceptedHTML(params: {
  customerName: string;
  orderRef: string;
  returnedItems: Array<Record<string, unknown>>;
  refundAmount: number;
  creditNoteNumber: string;
  originalInvoiceNumber: string;
}): string {
  const itemRows = params.returnedItems.map(item =>
    `<tr>
      <td style="padding:8px 12px;border-bottom:1px solid #eee;">${item.product_name}</td>
      <td style="padding:8px 12px;border-bottom:1px solid #eee;">${item.size || '-'}</td>
      <td style="padding:8px 12px;border-bottom:1px solid #eee;text-align:center;">${item.quantity}</td>
      <td style="padding:8px 12px;border-bottom:1px solid #eee;text-align:right;">€${Number(item.price || 0).toFixed(2)}</td>
    </tr>`
  ).join('');

  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="margin:0;padding:0;background:#f4f4f4;font-family:Arial,sans-serif;">
  <div style="max-width:600px;margin:30px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,0.08);">
    <div style="background:linear-gradient(135deg,#0d9488,#14b8a6);padding:30px;text-align:center;">
      <h1 style="margin:0;color:#fff;font-size:22px;">Devolución Parcial Aceptada</h1>
      <p style="margin:8px 0 0;color:rgba(255,255,255,0.9);font-size:14px;">Pedido ${params.orderRef}</p>
    </div>
    <div style="padding:30px;">
      <p style="color:#333;">Hola <strong>${params.customerName}</strong>,</p>
      <p style="color:#555;">Tu solicitud de devolución parcial ha sido procesada correctamente. A continuación el detalle:</p>
      
      <table style="width:100%;border-collapse:collapse;margin:20px 0;">
        <thead>
          <tr style="background:#f8f8f8;">
            <th style="padding:10px 12px;text-align:left;font-size:13px;color:#666;">Producto</th>
            <th style="padding:10px 12px;text-align:left;font-size:13px;color:#666;">Talla</th>
            <th style="padding:10px 12px;text-align:center;font-size:13px;color:#666;">Cant.</th>
            <th style="padding:10px 12px;text-align:right;font-size:13px;color:#666;">Precio</th>
          </tr>
        </thead>
        <tbody>${itemRows}</tbody>
      </table>

      <div style="background:#f0fdfa;border:1px solid #99f6e4;border-radius:8px;padding:16px;margin:20px 0;">
        <p style="margin:0;color:#0d9488;font-size:18px;font-weight:bold;text-align:center;">
          Reembolso: €${params.refundAmount.toFixed(2)}
        </p>
        <p style="margin:6px 0 0;color:#666;font-size:12px;text-align:center;">
          El coste de envío no está incluido en el reembolso.
        </p>
      </div>

      <p style="color:#555;font-size:13px;">
        Factura rectificativa: <strong>${params.creditNoteNumber}</strong><br>
        Referencia factura original: <strong>${params.originalInvoiceNumber}</strong>
      </p>
      <p style="color:#555;font-size:13px;">
        Adjuntamos la factura rectificativa y una copia de la factura original en formato PDF.
        El reembolso se procesará en los próximos 5-10 días hábiles.
      </p>
    </div>
    <div style="background:#f8f8f8;padding:20px;text-align:center;border-top:1px solid #eee;">
      <p style="margin:0;color:#999;font-size:12px;">FashionMarket — Gracias por tu confianza</p>
    </div>
  </div>
</body>
</html>`;
}

function buildReturnRejectedHTML(params: {
  customerName: string;
  orderRef: string;
  reason: string;
}): string {
  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="margin:0;padding:0;background:#f4f4f4;font-family:Arial,sans-serif;">
  <div style="max-width:600px;margin:30px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,0.08);">
    <div style="background:linear-gradient(135deg,#dc2626,#ef4444);padding:30px;text-align:center;">
      <h1 style="margin:0;color:#fff;font-size:22px;">Solicitud de Devolución Rechazada</h1>
      <p style="margin:8px 0 0;color:rgba(255,255,255,0.9);font-size:14px;">Pedido ${params.orderRef}</p>
    </div>
    <div style="padding:30px;">
      <p style="color:#333;">Hola <strong>${params.customerName}</strong>,</p>
      <p style="color:#555;">Lamentamos informarte de que tu solicitud de devolución no ha podido ser aceptada.</p>
      
      <div style="background:#fef2f2;border:1px solid #fecaca;border-radius:8px;padding:16px;margin:20px 0;">
        <p style="margin:0;color:#666;font-size:13px;"><strong>Motivo:</strong></p>
        <p style="margin:8px 0 0;color:#dc2626;font-size:14px;">${params.reason}</p>
      </div>

      <p style="color:#555;font-size:13px;">
        Si tienes dudas o deseas más información, no dudes en contactarnos respondiendo a este email.
      </p>
    </div>
    <div style="background:#f8f8f8;padding:20px;text-align:center;border-top:1px solid #eee;">
      <p style="margin:0;color:#999;font-size:12px;">FashionMarket — Gracias por tu comprensión</p>
    </div>
  </div>
</body>
</html>`;
}

// ─── Direct action handlers ──────────────────────────────────────────

async function handleRejectReturn(body: Record<string, unknown>): Promise<Response> {
  const { orderId, adminEmail, reason } = body;
  if (!orderId || !reason) {
    return new Response(
      JSON.stringify({ error: 'Faltan orderId o reason' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  const supabase = getSupabaseAdmin();

  // Get order
  const { data: order, error: orderError } = await supabase
    .from('orders')
    .select('*')
    .eq('id', orderId)
    .single();

  if (orderError || !order) {
    return new Response(
      JSON.stringify({ error: 'Pedido no encontrado' }),
      { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  // Update status to return_rejected
  const { error: updateError } = await supabase
    .from('orders')
    .update({ status: 'return_rejected', updated_at: new Date().toISOString() })
    .eq('id', orderId);

  if (updateError) {
    console.error('[reject-return] Update error:', updateError);
    return new Response(
      JSON.stringify({ error: 'Error al actualizar estado' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  // Send rejection email
  const orderRef = `#${order.order_number || String(orderId).slice(0, 8)}`;
  const customerName = order.customer_name || 'Cliente';

  if (order.customer_email) {
    try {
      const html = buildReturnRejectedHTML({ customerName, orderRef, reason: String(reason) });
      await sendEmail(
        [order.customer_email],
        `Devolución Rechazada - Pedido ${orderRef} - FashionMarket`,
        html,
      );
    } catch (e) {
      console.error('[reject-return] Email error:', e);
    }
  }

  return new Response(
    JSON.stringify({ success: true, message: 'Devolución rechazada y email enviado', status: 'return_rejected' }),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

async function handleAcceptPartialReturn(body: Record<string, unknown>): Promise<Response> {
  const { orderId, adminEmail, refundAmount, returnedItems, reason } = body;
  if (!orderId || !adminEmail || !refundAmount || !returnedItems) {
    return new Response(
      JSON.stringify({ error: 'Faltan campos requeridos: orderId, adminEmail, refundAmount, returnedItems' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  const supabase = getSupabaseAdmin();

  // 1. Get order info
  const { data: order, error: orderError } = await supabase
    .from('orders')
    .select('*')
    .eq('id', orderId)
    .single();

  if (orderError || !order) {
    return new Response(
      JSON.stringify({ error: 'Pedido no encontrado' }),
      { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  // 2. Get original invoice (FM-...)
  const { data: originalInvoice } = await supabase
    .from('facturacion')
    .select('*')
    .eq('order_id', orderId)
    .not('invoice_number', 'like', 'FR-%')
    .order('created_at', { ascending: true })
    .limit(1)
    .maybeSingle();

  if (!originalInvoice) {
    return new Response(
      JSON.stringify({ error: 'No se encontró la factura original. No se puede crear factura rectificativa.' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  // 3. Create partial credit note via RPC
  const items = (returnedItems as Array<Record<string, unknown>>);
  const { data: creditNoteResult, error: cnError } = await supabase.rpc(
    'admin_create_partial_credit_note',
    {
      p_admin_email: adminEmail,
      p_order_id: orderId,
      p_returned_items: items,
      p_refund_amount: Number(refundAmount),
    }
  );

  if (cnError) {
    console.error('[accept-partial-return] Credit note RPC error:', cnError);
    return new Response(
      JSON.stringify({ error: `Error al crear factura rectificativa: ${cnError.message}` }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }

  const creditNoteNumber = creditNoteResult?.credit_note_number || 'FR-????';
  const creditNoteId = creditNoteResult?.credit_note_id;

  // 4. Get the inserted credit note full data for PDF
  let creditNote = creditNoteResult;
  if (creditNoteId) {
    const { data: cnData } = await supabase
      .from('facturacion')
      .select('*')
      .eq('id', creditNoteId)
      .single();
    if (cnData) creditNote = cnData;
  }

  // 5. Generate PDFs
  const orderNumber = String(order.order_number || String(orderId).slice(0, 8));
  let creditNotePDF: Uint8Array;
  let originalPDF: Uint8Array;

  try {
    creditNotePDF = await generateCreditNotePDF(
      creditNote || { invoice_number: creditNoteNumber, customer_name: order.customer_name, customer_email: order.customer_email, items, subtotal: 0, iva_amount: 0, total: -Number(refundAmount) },
      orderNumber,
      originalInvoice.invoice_number,
    );
    originalPDF = await generateOriginalInvoicePDF(originalInvoice, orderNumber);
  } catch (pdfErr) {
    console.error('[accept-partial-return] PDF generation error:', pdfErr);
    // Continue without PDFs
    creditNotePDF = new Uint8Array(0);
    originalPDF = new Uint8Array(0);
  }

  // 6. Send email with attachments
  const orderRef = `#${orderNumber}`;
  const customerName = order.customer_name || 'Cliente';

  if (order.customer_email) {
    try {
      const html = buildPartialReturnAcceptedHTML({
        customerName,
        orderRef,
        returnedItems: items,
        refundAmount: Number(refundAmount),
        creditNoteNumber,
        originalInvoiceNumber: originalInvoice.invoice_number,
      });

      const attachments: Array<{filename: string; content: Uint8Array}> = [];
      if (creditNotePDF.length > 0) {
        attachments.push({
          filename: `Factura_Rectificativa_${creditNoteNumber}.pdf`,
          content: creditNotePDF,
        });
      }
      if (originalPDF.length > 0) {
        attachments.push({
          filename: `Factura_${originalInvoice.invoice_number}.pdf`,
          content: originalPDF,
        });
      }

      await sendEmail(
        [order.customer_email],
        `Devolución Parcial Aceptada - Pedido ${orderRef} - FashionMarket`,
        html,
        attachments.length > 0 ? attachments : undefined,
      );
      console.log('[accept-partial-return] Email sent to:', order.customer_email);
    } catch (emailErr) {
      console.error('[accept-partial-return] Email error:', emailErr);
    }
  }

  return new Response(
    JSON.stringify({
      success: true,
      message: `Factura rectificativa ${creditNoteNumber} creada y email enviado`,
      credit_note_number: creditNoteNumber,
      refund_amount: refundAmount,
    }),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  try {
    // 1. Parsear body: { action, ...resto }
    const body = await req.json();
    const { action, ...forwardBody } = body;

    // 2. Verificar token del cliente (excepto acciones públicas)
    const authHeader = req.headers.get('Authorization');
    if (!PUBLIC_ACTIONS.has(action) && (!authHeader || !authHeader.startsWith('Bearer '))) {
      return new Response(
        JSON.stringify({ error: 'No authorization token' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    if (!action) {
      return new Response(
        JSON.stringify({ error: 'Falta el campo "action"' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // ─── Acciones gestionadas directamente (no se reenvían a FashionStore) ───
    if (DIRECT_ACTIONS.has(action)) {
      if (action === 'reject-return') {
        return handleRejectReturn(forwardBody);
      }
      if (action === 'accept-partial-return') {
        return handleAcceptPartialReturn(forwardBody);
      }
    }

    const endpoint = ENDPOINT_MAP[action];
    if (!endpoint) {
      return new Response(
        JSON.stringify({ error: `Acción desconocida: ${action}` }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    // 3. Construir headers según tipo de acción
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    if (ADMIN_ACTIONS.has(action)) {
      // Acciones admin: reenviar cookie de admin-session
      const adminEmail = forwardBody.adminEmail;
      if (!adminEmail) {
        return new Response(
          JSON.stringify({ error: 'Falta adminEmail para acción admin' }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        );
      }
      const adminSession = JSON.stringify({
        email: adminEmail,
        role: 'admin',
        timestamp: Date.now(),
      });
      headers['Cookie'] = `admin-session=${encodeURIComponent(adminSession)}`;
      headers['Origin'] = FASHION_STORE_URL;
    } else {
      // Acciones de usuario: reenviar JWT + Origin del navegador
      // (necesario para checkout: FashionStore usa Origin para construir las URLs de Stripe)
      headers['Authorization'] = authHeader;
      const browserOrigin = req.headers.get('origin');
      if (browserOrigin) {
        headers['Origin'] = browserOrigin;
        headers['Referer'] = browserOrigin + '/';
      }
    }

    // 4. Reenviar a FashionStore (servidor ↔ servidor, sin CORS)
    let fashionStoreResponse: Response;

    if (GET_ACTIONS.has(action)) {
      // Acciones GET: convertir body a query params
      const url = new URL(`${FASHION_STORE_URL}${endpoint}`);
      for (const [key, value] of Object.entries(forwardBody)) {
        if (value !== undefined && value !== null) {
          url.searchParams.set(key, String(value));
        }
      }
      fashionStoreResponse = await fetch(url.toString(), {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
      });
    } else {
      const bodyToForward = action === 'checkout'
        ? sanitizeCheckoutPayload(forwardBody)
        : forwardBody;

      fashionStoreResponse = await fetch(
        `${FASHION_STORE_URL}${endpoint}`,
        {
          method: 'POST',
          headers,
          body: JSON.stringify(bodyToForward),
        }
      );
    }

    const data = await fashionStoreResponse.json();

    return new Response(JSON.stringify(data), {
      status: fashionStoreResponse.status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error: unknown) {
    const msg = error instanceof Error ? error.message : 'Internal server error';
    console.error('[orders-relay] Error:', msg);
    return new Response(JSON.stringify({ error: msg }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
