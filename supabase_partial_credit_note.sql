-- =============================================
-- Factura Rectificativa parcial (FR-) para devoluciones parciales
-- Ejecutar DESPUÉS de supabase_fix_partial_return.sql
-- =============================================

-- 1. Asegurar que facturacion.order_id NO tiene unique constraint
--    (permite factura original + una o más rectificativas por pedido)
ALTER TABLE facturacion DROP CONSTRAINT IF EXISTS unique_order_facturacion;
CREATE INDEX IF NOT EXISTS idx_facturacion_order_id ON facturacion(order_id);

-- 2. Asegurar que invoice_number NO tiene unique index problemático
--    (lo recreamos correctamente)
DROP INDEX IF EXISTS idx_facturacion_invoice_number;
CREATE UNIQUE INDEX IF NOT EXISTS idx_facturacion_invoice_number ON facturacion(invoice_number);

-- 3. Función: Generar siguiente número de factura rectificativa FR-YYYY-XXXXXX
CREATE OR REPLACE FUNCTION generate_credit_note_number()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_year TEXT;
  v_last_seq INTEGER;
  v_next_seq INTEGER;
BEGIN
  v_year := to_char(NOW(), 'YYYY');

  SELECT COALESCE(MAX(
    CAST(SPLIT_PART(invoice_number, '-', 3) AS INTEGER)
  ), 0)
  INTO v_last_seq
  FROM facturacion
  WHERE invoice_number LIKE 'FR-' || v_year || '-%';

  v_next_seq := v_last_seq + 1;

  RETURN 'FR-' || v_year || '-' || LPAD(v_next_seq::TEXT, 6, '0');
END;
$$;

-- 4. RPC: Crear factura rectificativa parcial para devolución parcial
--    Recibe: order_id, items devueltos [{product_name, quantity, size, price, total}], refund_amount
--    Los importes se guardan en NEGATIVO (convención contable para rectificativas)
CREATE OR REPLACE FUNCTION admin_create_partial_credit_note(
  p_admin_email TEXT,
  p_order_id UUID,
  p_returned_items JSONB,
  p_refund_amount NUMERIC(10,2)
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_admin_exists BOOLEAN;
  v_original_invoice RECORD;
  v_credit_note_number TEXT;
  v_items JSONB;
  v_subtotal NUMERIC(10,2);
  v_iva_amount NUMERIC(10,2);
  v_total NUMERIC(10,2);
  v_new_id INTEGER;
BEGIN
  -- Verificar admin
  SELECT EXISTS(SELECT 1 FROM admins WHERE email = p_admin_email AND is_active = true)
  INTO v_admin_exists;

  IF NOT v_admin_exists THEN
    RAISE EXCEPTION 'No autorizado';
  END IF;

  -- Obtener factura original (FM-..., no FR-...)
  SELECT f.* INTO v_original_invoice
  FROM facturacion f
  WHERE f.order_id = p_order_id
    AND (f.invoice_number NOT LIKE 'FR-%' OR f.invoice_number IS NULL)
  ORDER BY f.created_at ASC
  LIMIT 1;

  IF v_original_invoice IS NULL THEN
    RAISE EXCEPTION 'No se encontró la factura original para el pedido %', p_order_id;
  END IF;

  -- Generar número de rectificativa
  v_credit_note_number := generate_credit_note_number();

  -- Construir items con importes negativos
  SELECT jsonb_agg(
    jsonb_build_object(
      'product_name', item->>'product_name',
      'quantity', -(item->>'quantity')::integer,
      'size', item->>'size',
      'price', (item->>'price')::numeric,
      'total', -ABS((item->>'total')::numeric)
    )
  )
  INTO v_items
  FROM jsonb_array_elements(p_returned_items) AS item;

  -- Calcular totales (IVA 21%)
  v_total := -ABS(p_refund_amount);
  v_subtotal := ROUND(v_total / 1.21, 2);
  v_iva_amount := v_total - v_subtotal;

  -- Insertar factura rectificativa
  INSERT INTO facturacion (
    order_id, invoice_number, customer_name, customer_email,
    shipping_address, items, subtotal, iva_amount, shipping_cost, total
  ) VALUES (
    p_order_id,
    v_credit_note_number,
    v_original_invoice.customer_name,
    v_original_invoice.customer_email,
    v_original_invoice.shipping_address,
    v_items,
    v_subtotal,
    v_iva_amount,
    0,  -- El envío no se reembolsa en parciales
    v_total
  )
  RETURNING id INTO v_new_id;

  RETURN jsonb_build_object(
    'success', true,
    'credit_note_id', v_new_id,
    'credit_note_number', v_credit_note_number,
    'total', v_total,
    'original_invoice_number', v_original_invoice.invoice_number,
    'message', format('Factura rectificativa %s creada por €%s', v_credit_note_number, v_total)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION admin_create_partial_credit_note(TEXT, UUID, JSONB, NUMERIC) TO anon, authenticated;

-- Verificación:
-- SELECT admin_create_partial_credit_note(
--   'admin@ejemplo.com',
--   'order-uuid'::uuid,
--   '[{"product_name":"Camiseta","quantity":1,"size":"M","price":29.99,"total":29.99}]'::jsonb,
--   29.99
-- );
