-- =============================================
-- Migration: Add return_reason & cancellation_reason columns to orders
-- =============================================
-- return_reason: stores the customer's return/devolution reason text
-- cancellation_reason: stores the reason for cancellation (client or admin)
--
-- The FashionStore API endpoints receive these reasons but never persist
-- them. The Flutter app writes them directly to Supabase after API success.
-- =============================================

-- 1) Add the columns (nullable TEXT)
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS return_reason TEXT;

ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

-- 2) Update admin_get_orders to include both fields in its output
DROP FUNCTION IF EXISTS admin_get_orders(TEXT, TEXT);
CREATE OR REPLACE FUNCTION admin_get_orders(
  p_admin_email TEXT,
  p_status TEXT DEFAULT NULL
)
RETURNS JSON
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSON;
BEGIN
  -- Verificar que es un admin valido
  IF NOT EXISTS (
    SELECT 1 FROM admins 
    WHERE email = p_admin_email 
    AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Usuario admin no valido';
  END IF;

  SELECT json_agg(
    json_build_object(
      'id', o.id,
      'order_number', o.order_number,
      'total_price', o.total_price,
      'status', o.status,
      'customer_email', o.customer_email,
      'customer_name', o.customer_name,
      'customer_id', o.customer_id,
      'shipping_address', o.shipping_address,
      'shipping_method_id', o.shipping_method_id,
      'shipping_carrier', o.shipping_carrier,
      'tracking_number', o.tracking_number,
      'tracking_url', o.tracking_url,
      'shipped_at', o.shipped_at,
      'delivered_at', o.delivered_at,
      'return_reason', o.return_reason,
      'cancellation_reason', o.cancellation_reason,
      'created_at', o.created_at,
      'updated_at', o.updated_at,
      'items', COALESCE((
        SELECT json_agg(
          json_build_object(
            'id', oi.id,
            'product_id', oi.product_id,
            'product_name', oi.product_name,
            'product_image', oi.product_image,
            'quantity', oi.quantity,
            'size', oi.size,
            'price_at_purchase', oi.price_at_purchase
          )
        )
        FROM order_items oi
        WHERE oi.order_id = o.id
      ), '[]'::json)
    )
    ORDER BY o.created_at DESC
  ) INTO v_result
  FROM orders o
  WHERE (p_status IS NULL OR o.status = p_status);

  RETURN COALESCE(v_result, '[]'::json);
END;
$$;

GRANT EXECUTE ON FUNCTION admin_get_orders(TEXT, TEXT) TO anon, authenticated;
