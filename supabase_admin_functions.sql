-- =============================================
-- FUNCIONES RPC PARA ADMIN DE FLUTTER
-- Estas funciones permiten al admin acceder a datos
-- bypaseando las politicas RLS
-- =============================================
-- EJECUTAR EN: Supabase SQL Editor
-- COMPATIBLE CON: FashionStore schema (orders.id es INTEGER, no UUID)
-- NOTA: Usa product_stock para el stock por tallas (NO product_variants)

-- =============================================
-- admin_get_products
-- Obtiene TODOS los productos (activos e inactivos) con imagenes y stock por talla
-- IMPORTANTE: Lee de product_stock, no de product_variants
-- =============================================
DROP FUNCTION IF EXISTS admin_get_products(TEXT);
CREATE OR REPLACE FUNCTION admin_get_products(p_admin_email TEXT)
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
      'id', p.id,
      'name', p.name,
      'slug', p.slug,
      'description', p.description,
      'price', p.price,
      'stock', p.stock,
      'category_id', p.category_id,
      'is_offer', p.is_offer,
      'sizes', p.sizes,
      'active', p.active,
      'original_price', p.original_price,
      'discount_percent', p.discount_percent,
      'created_at', p.created_at,
      'category', (
        SELECT json_build_object(
          'id', c.id,
          'name', c.name,
          'slug', c.slug
        )
        FROM categories c
        WHERE c.id = p.category_id
      ),
      'images', COALESCE((
        SELECT json_agg(
          json_build_object(
            'id', pi.id,
            'image_url', pi.image_url,
            'order', pi."order",
            'color', pi.color,
            'color_hex', pi.color_hex
          )
          ORDER BY pi."order" ASC
        )
        FROM product_images pi
        WHERE pi.product_id = p.id
      ), '[]'::json),
      -- Usar product_stock en lugar de product_variants
      'variants', COALESCE((
        SELECT json_agg(
          json_build_object(
            'id', ps.id,
            'size', ps.size,
            'stock', ps.quantity
          )
          ORDER BY 
            CASE ps.size
              WHEN 'XXS' THEN 1
              WHEN 'XS' THEN 2
              WHEN 'S' THEN 3
              WHEN 'M' THEN 4
              WHEN 'L' THEN 5
              WHEN 'XL' THEN 6
              WHEN 'XXL' THEN 7
              WHEN 'XXXL' THEN 8
              ELSE 9
            END,
            ps.size ASC
        )
        FROM product_stock ps
        WHERE ps.product_id = p.id
      ), '[]'::json)
    )
    ORDER BY p.created_at DESC
  ) INTO v_result
  FROM products p;

  RETURN COALESCE(v_result, '[]'::json);
END;
$$;

GRANT EXECUTE ON FUNCTION admin_get_products(TEXT) TO anon, authenticated;

-- =============================================
-- admin_get_dashboard_stats
-- Obtiene estadisticas del dashboard
-- =============================================
DROP FUNCTION IF EXISTS admin_get_dashboard_stats(TEXT);
CREATE OR REPLACE FUNCTION admin_get_dashboard_stats(p_admin_email TEXT)
RETURNS JSON
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSON;
  v_total_products INT;
  v_total_customers INT;
  v_pending_orders INT;
  v_monthly_sales NUMERIC;
  v_month_start TIMESTAMPTZ;
BEGIN
  -- Verificar que es un admin valido
  IF NOT EXISTS (
    SELECT 1 FROM admins 
    WHERE email = p_admin_email 
    AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Usuario admin no valido';
  END IF;

  -- Calcular inicio del mes
  v_month_start := date_trunc('month', NOW());

  -- Total de productos activos
  SELECT COUNT(*) INTO v_total_products
  FROM products WHERE active = true;

  -- Total de clientes
  SELECT COUNT(*) INTO v_total_customers
  FROM customers;

  -- Pedidos pendientes (status = 'paid' - pagados pero no enviados)
  SELECT COUNT(*) INTO v_pending_orders
  FROM orders
  WHERE status = 'paid';

  -- Ventas del mes (paid, shipped, delivered)
  SELECT COALESCE(SUM(total_price), 0) INTO v_monthly_sales
  FROM orders
  WHERE status IN ('paid', 'shipped', 'delivered')
  AND created_at >= v_month_start;

  -- Construir resultado
  v_result := json_build_object(
    'totalProducts', v_total_products,
    'totalCustomers', v_total_customers,
    'pendingOrders', v_pending_orders,
    'monthlySales', v_monthly_sales
  );

  RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_get_dashboard_stats(TEXT) TO anon, authenticated;

-- =============================================
-- admin_get_customers
-- Obtiene todos los clientes con estadisticas
-- =============================================
DROP FUNCTION IF EXISTS admin_get_customers(TEXT);
CREATE OR REPLACE FUNCTION admin_get_customers(p_admin_email TEXT)
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
      'id', c.id,
      'email', c.email,
      'full_name', c.full_name,
      'phone', c.phone,
      'avatar_url', c.avatar_url,
      'newsletter', c.newsletter,
      'created_at', c.created_at,
      'updated_at', c.updated_at,
      'orders_count', COALESCE(o.orders_count, 0),
      'total_spent', COALESCE(o.total_spent, 0)
    )
    ORDER BY c.created_at DESC
  ) INTO v_result
  FROM customers c
  LEFT JOIN (
    SELECT 
      customer_id,
      COUNT(*) as orders_count,
      SUM(total_price) as total_spent
    FROM orders
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
  ) o ON c.id = o.customer_id;

  RETURN COALESCE(v_result, '[]'::json);
END;
$$;

GRANT EXECUTE ON FUNCTION admin_get_customers(TEXT) TO anon, authenticated;

-- =============================================
-- admin_get_orders
-- Obtiene todos los pedidos con items
-- NOTA: orders.id es INTEGER (SERIAL), no UUID
-- =============================================
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

-- =============================================
-- admin_get_sales_last_7_days
-- Ventas de los ultimos 7 dias
-- =============================================
DROP FUNCTION IF EXISTS admin_get_sales_last_7_days(TEXT);
CREATE OR REPLACE FUNCTION admin_get_sales_last_7_days(p_admin_email TEXT)
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
      'date', day::date,
      'total', COALESCE(daily_sales.total, 0)
    )
    ORDER BY day
  ) INTO v_result
  FROM generate_series(
    current_date - interval '6 days',
    current_date,
    interval '1 day'
  ) AS day
  LEFT JOIN (
    SELECT 
      date_trunc('day', created_at)::date as sale_date,
      SUM(total_price) as total
    FROM orders
    WHERE status IN ('paid', 'shipped', 'delivered')
    AND created_at >= current_date - interval '6 days'
    GROUP BY date_trunc('day', created_at)::date
  ) daily_sales ON day::date = daily_sales.sale_date;

  RETURN COALESCE(v_result, '[]'::json);
END;
$$;

GRANT EXECUTE ON FUNCTION admin_get_sales_last_7_days(TEXT) TO anon, authenticated;

-- =============================================
-- admin_update_order_status
-- Actualiza el estado de un pedido
-- NOTA: p_order_id es INTEGER como texto (ej: '123')
-- =============================================
DROP FUNCTION IF EXISTS admin_update_order_status(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT);
CREATE OR REPLACE FUNCTION admin_update_order_status(
  p_admin_email TEXT,
  p_order_id TEXT,
  p_new_status TEXT,
  p_tracking_number TEXT DEFAULT NULL,
  p_tracking_url TEXT DEFAULT NULL,
  p_shipping_carrier TEXT DEFAULT NULL
)
RETURNS JSON
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_order_id INTEGER;
  v_order_exists BOOLEAN;
BEGIN
  -- Verificar que es un admin valido
  IF NOT EXISTS (
    SELECT 1 FROM admins 
    WHERE email = p_admin_email 
    AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Usuario admin no valido';
  END IF;

  -- Convertir order_id a INTEGER
  v_order_id := p_order_id::INTEGER;

  -- Verificar que el pedido existe
  SELECT EXISTS(SELECT 1 FROM orders WHERE id = v_order_id) INTO v_order_exists;
  
  IF NOT v_order_exists THEN
    RAISE EXCEPTION 'Pedido no encontrado';
  END IF;

  -- Actualizar pedido
  UPDATE orders
  SET 
    status = p_new_status,
    tracking_number = COALESCE(p_tracking_number, tracking_number),
    tracking_url = COALESCE(p_tracking_url, tracking_url),
    shipping_carrier = COALESCE(p_shipping_carrier, shipping_carrier),
    shipped_at = CASE WHEN p_new_status = 'shipped' THEN NOW() ELSE shipped_at END,
    delivered_at = CASE WHEN p_new_status = 'delivered' THEN NOW() ELSE delivered_at END,
    updated_at = NOW()
  WHERE id = v_order_id;

  RETURN json_build_object('success', true, 'message', 'Estado actualizado correctamente');
END;
$$;

GRANT EXECUTE ON FUNCTION admin_update_order_status(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT) TO anon, authenticated;

-- =============================================
-- VERIFICACION
-- =============================================
-- Para probar, ejecuta (reemplaza con tu email de admin):
-- SELECT admin_get_products('tu_email@admin.com');
-- SELECT admin_get_dashboard_stats('tu_email@admin.com');
-- SELECT admin_get_customers('tu_email@admin.com');
-- SELECT admin_get_orders('tu_email@admin.com', NULL);
-- SELECT admin_get_sales_last_7_days('tu_email@admin.com');
