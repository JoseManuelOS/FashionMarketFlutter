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
 *
 * Deploy:
 *   supabase functions deploy orders-relay --project-ref sjalsswfvoshyppbbhtv
 */

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
};

// Acciones que requieren cookie de admin en vez de Authorization header
const ADMIN_ACTIONS = new Set(['accept-return', 'admin-cancel']);

// Acciones públicas que no requieren Authorization
const PUBLIC_ACTIONS = new Set(['stock']);

// Acciones que se reenvían como GET con query params en vez de POST con body
const GET_ACTIONS = new Set(['stock']);

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
      fashionStoreResponse = await fetch(
        `${FASHION_STORE_URL}${endpoint}`,
        {
          method: 'POST',
          headers,
          body: JSON.stringify(forwardBody),
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
