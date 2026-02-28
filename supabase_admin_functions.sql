-- =============================================
-- FUNCIONES RPC PARA ADMIN DE FLUTTER
-- Estas funciones permiten al admin acceder a datos
-- bypaseando las politicas RLS
-- =============================================
-- EJECUTAR EN: Supabase SQL Editor
-- COMPATIBLE CON: FashionStore schema (orders.id es INTEGER, no UUID)
-- NOTA: Usa product_variants para el stock por tallas (igual que FashionStore)

-- =============================================
-- admin_get_products
-- Obtiene TODOS los productos (activos e inactivos) con imagenes y stock por talla
-- IMPORTANTE: Lee de product_variants (igual que FashionStore)
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
      'colors', p.colors,
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
      'variants', COALESCE((
        SELECT json_agg(
          json_build_object(
            'id', pv.id,
            'size', pv.size,
            'stock', pv.stock,
            'color', pv.color,
            'sku', pv.sku
          )
          ORDER BY 
            CASE pv.size
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
            pv.size ASC
        )
        FROM product_variants pv
        WHERE pv.product_id = p.id
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
-- Obtiene estadisticas completas del dashboard
-- Incluye: productos, clientes, pedidos, ventas, stock bajo, ofertas, top producto
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
  v_low_stock_count INT;
  v_offer_products INT;
  v_top_product_name TEXT;
  v_top_product_qty INT;
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

  -- Stock bajo: variantes con stock <= 5 (igual que FashionStore)
  SELECT COUNT(DISTINCT product_id) INTO v_low_stock_count
  FROM product_variants
  WHERE stock <= 5;

  -- Productos en oferta
  SELECT COUNT(*) INTO v_offer_products
  FROM products
  WHERE is_offer = true AND active = true;

  -- Producto más vendido del mes
  SELECT 
    oi.product_name,
    SUM(oi.quantity)::INT
  INTO v_top_product_name, v_top_product_qty
  FROM order_items oi
  JOIN orders o ON o.id = oi.order_id
  WHERE o.status IN ('paid', 'shipped', 'delivered')
  AND o.created_at >= v_month_start
  GROUP BY oi.product_name
  ORDER BY SUM(oi.quantity) DESC
  LIMIT 1;

  -- Construir resultado
  v_result := json_build_object(
    'totalProducts', v_total_products,
    'totalCustomers', v_total_customers,
    'pendingOrders', v_pending_orders,
    'monthlySales', v_monthly_sales,
    'lowStockCount', v_low_stock_count,
    'offerProducts', v_offer_products,
    'topProductName', COALESCE(v_top_product_name, 'Sin ventas'),
    'topProductQty', COALESCE(v_top_product_qty, 0)
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
-- admin_get_sales_by_period
-- Ventas de los ultimos N dias (configurable: 7, 30, 90)
-- Incluye tanto importe total como numero de pedidos por dia
-- =============================================
DROP FUNCTION IF EXISTS admin_get_sales_by_period(TEXT, INT);
CREATE OR REPLACE FUNCTION admin_get_sales_by_period(
  p_admin_email TEXT,
  p_days INT DEFAULT 7
)
RETURNS JSON
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSON;
  v_interval INTERVAL;
BEGIN
  -- Verificar que es un admin valido
  IF NOT EXISTS (
    SELECT 1 FROM admins 
    WHERE email = p_admin_email 
    AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Usuario admin no valido';
  END IF;

  -- Limitar dias entre 1 y 365
  p_days := GREATEST(1, LEAST(p_days, 365));
  v_interval := (p_days - 1) * interval '1 day';

  SELECT json_agg(
    json_build_object(
      'date', day::date,
      'total', COALESCE(daily_sales.total, 0),
      'orders', COALESCE(daily_sales.order_count, 0)
    )
    ORDER BY day
  ) INTO v_result
  FROM generate_series(
    current_date - v_interval,
    current_date,
    interval '1 day'
  ) AS day
  LEFT JOIN (
    SELECT 
      date_trunc('day', created_at)::date as sale_date,
      SUM(total_price) as total,
      COUNT(*) as order_count
    FROM orders
    WHERE status IN ('paid', 'shipped', 'delivered')
    AND created_at >= current_date - v_interval
    GROUP BY date_trunc('day', created_at)::date
  ) daily_sales ON day::date = daily_sales.sale_date;

  RETURN COALESCE(v_result, '[]'::json);
END;
$$;

GRANT EXECUTE ON FUNCTION admin_get_sales_by_period(TEXT, INT) TO anon, authenticated;

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
-- admin_create_product
-- Crea un producto con variantes (tallas/stock) e imagenes
-- Replica la logica de FashionStore/src/pages/admin/productos/nuevo.astro
-- =============================================
DROP FUNCTION IF EXISTS admin_create_product(TEXT, JSONB);
CREATE OR REPLACE FUNCTION admin_create_product(
  p_admin_email TEXT,
  p_data JSONB
)
RETURNS JSON
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_product_id UUID;
  v_variant JSONB;
  v_image JSONB;
  v_total_stock INT := 0;
  v_slug TEXT;
BEGIN
  -- Verificar que es un admin valido
  IF NOT EXISTS (
    SELECT 1 FROM admins 
    WHERE email = p_admin_email 
    AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Usuario admin no valido';
  END IF;

  -- Generar slug a partir del nombre
  v_slug := lower(regexp_replace(trim(p_data->>'name'), '[^a-zA-Z0-9]+', '-', 'g'));
  v_slug := regexp_replace(v_slug, '^-|-$', '', 'g');
  -- Asegurar unicidad agregando timestamp si ya existe
  IF EXISTS (SELECT 1 FROM products WHERE slug = v_slug) THEN
    v_slug := v_slug || '-' || extract(epoch from now())::int;
  END IF;

  -- Calcular stock total sumando variantes
  IF p_data ? 'variants' AND jsonb_array_length(p_data->'variants') > 0 THEN
    SELECT COALESCE(SUM((v->>'stock')::int), 0)
    INTO v_total_stock
    FROM jsonb_array_elements(p_data->'variants') AS v;
  END IF;

  -- Insertar producto
  INSERT INTO products (
    name, slug, description, price, stock,
    category_id, is_offer, sizes, colors, active,
    original_price, discount_percent
  ) VALUES (
    p_data->>'name',
    v_slug,
    p_data->>'description',
    (p_data->>'price')::numeric,
    v_total_stock,
    (p_data->>'category_id')::uuid,
    COALESCE((p_data->>'is_offer')::boolean, false),
    ARRAY(SELECT jsonb_array_elements_text(COALESCE(p_data->'sizes', '[]'::jsonb))),
    COALESCE(p_data->'colors', '[]'::jsonb),
    COALESCE((p_data->>'active')::boolean, true),
    CASE WHEN p_data->>'original_price' IS NOT NULL 
      THEN (p_data->>'original_price')::numeric ELSE NULL END,
    CASE WHEN p_data->>'discount_percent' IS NOT NULL 
      THEN (p_data->>'discount_percent')::numeric ELSE NULL END
  )
  RETURNING id INTO v_product_id;

  -- Insertar variantes (tallas con stock)
  IF p_data ? 'variants' THEN
    FOR v_variant IN SELECT * FROM jsonb_array_elements(p_data->'variants')
    LOOP
      INSERT INTO product_variants (product_id, size, stock, color, sku)
      VALUES (
        v_product_id,
        v_variant->>'size',
        COALESCE((v_variant->>'stock')::int, 0),
        v_variant->>'color',
        COALESCE(v_variant->>'sku', v_slug || '-' || lower(COALESCE(v_variant->>'color','')) || '-' || lower(v_variant->>'size'))
      );
    END LOOP;
  END IF;

  -- Insertar imagenes
  IF p_data ? 'images' THEN
    FOR v_image IN SELECT * FROM jsonb_array_elements(p_data->'images')
    LOOP
      INSERT INTO product_images (product_id, image_url, "order", color, color_hex)
      VALUES (
        v_product_id,
        v_image->>'image_url',
        COALESCE((v_image->>'order')::int, 0),
        v_image->>'color',
        v_image->>'color_hex'
      );
    END LOOP;
  END IF;

  RETURN json_build_object(
    'success', true, 
    'product_id', v_product_id,
    'message', 'Producto creado correctamente'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION admin_create_product(TEXT, JSONB) TO anon, authenticated;

-- =============================================
-- admin_update_product
-- Actualiza un producto existente con variantes e imagenes
-- Replica la logica de FashionStore admin edit
-- =============================================
DROP FUNCTION IF EXISTS admin_update_product(TEXT, UUID, JSONB);
CREATE OR REPLACE FUNCTION admin_update_product(
  p_admin_email TEXT,
  p_product_id UUID,
  p_data JSONB
)
RETURNS JSON
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_variant JSONB;
  v_image JSONB;
  v_total_stock INT := 0;
  v_product_exists BOOLEAN;
BEGIN
  -- Verificar que es un admin valido
  IF NOT EXISTS (
    SELECT 1 FROM admins 
    WHERE email = p_admin_email 
    AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Usuario admin no valido';
  END IF;

  -- Verificar que el producto existe
  SELECT EXISTS(SELECT 1 FROM products WHERE id = p_product_id) INTO v_product_exists;
  IF NOT v_product_exists THEN
    RAISE EXCEPTION 'Producto no encontrado';
  END IF;

  -- Calcular stock total si se envian variantes
  IF p_data ? 'variants' AND jsonb_array_length(p_data->'variants') > 0 THEN
    SELECT COALESCE(SUM((v->>'stock')::int), 0)
    INTO v_total_stock
    FROM jsonb_array_elements(p_data->'variants') AS v;
  ELSE
    -- Mantener stock actual si no se envian variantes
    SELECT stock INTO v_total_stock FROM products WHERE id = p_product_id;
  END IF;

  -- Actualizar producto
  UPDATE products SET
    name = COALESCE(p_data->>'name', name),
    description = COALESCE(p_data->>'description', description),
    price = COALESCE((p_data->>'price')::numeric, price),
    stock = v_total_stock,
    category_id = COALESCE((p_data->>'category_id')::uuid, category_id),
    is_offer = COALESCE((p_data->>'is_offer')::boolean, is_offer),
    sizes = CASE WHEN p_data ? 'sizes' THEN ARRAY(SELECT jsonb_array_elements_text(p_data->'sizes')) ELSE sizes END,
    colors = COALESCE(p_data->'colors', colors),
    active = COALESCE((p_data->>'active')::boolean, active),
    original_price = CASE 
      WHEN p_data ? 'original_price' THEN (p_data->>'original_price')::numeric
      ELSE original_price
    END,
    discount_percent = CASE 
      WHEN p_data ? 'discount_percent' THEN (p_data->>'discount_percent')::numeric
      ELSE discount_percent
    END,
    updated_at = NOW()
  WHERE id = p_product_id;

  -- Actualizar variantes: borrar y recrear (strategy: replace all)
  IF p_data ? 'variants' THEN
    DELETE FROM product_variants WHERE product_id = p_product_id;
    
    FOR v_variant IN SELECT * FROM jsonb_array_elements(p_data->'variants')
    LOOP
      INSERT INTO product_variants (product_id, size, stock, color, sku)
      VALUES (
        p_product_id,
        v_variant->>'size',
        COALESCE((v_variant->>'stock')::int, 0),
        v_variant->>'color',
        v_variant->>'sku'
      );
    END LOOP;
  END IF;

  -- Actualizar imagenes: borrar y recrear si se envian
  IF p_data ? 'images' THEN
    DELETE FROM product_images WHERE product_id = p_product_id;
    
    FOR v_image IN SELECT * FROM jsonb_array_elements(p_data->'images')
    LOOP
      INSERT INTO product_images (product_id, image_url, "order", color, color_hex)
      VALUES (
        p_product_id,
        v_image->>'image_url',
        COALESCE((v_image->>'order')::int, 0),
        v_image->>'color',
        v_image->>'color_hex'
      );
    END LOOP;
  END IF;

  RETURN json_build_object(
    'success', true,
    'product_id', p_product_id,
    'message', 'Producto actualizado correctamente'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION admin_update_product(TEXT, UUID, JSONB) TO anon, authenticated;

-- =============================================
-- admin_delete_product
-- Elimina un producto y todas sus relaciones
-- =============================================
DROP FUNCTION IF EXISTS admin_delete_product(TEXT, UUID);
CREATE OR REPLACE FUNCTION admin_delete_product(
  p_admin_email TEXT,
  p_product_id UUID
)
RETURNS JSON
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Verificar que es un admin valido
  IF NOT EXISTS (
    SELECT 1 FROM admins 
    WHERE email = p_admin_email 
    AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Usuario admin no valido';
  END IF;

  -- Verificar que el producto existe
  IF NOT EXISTS (SELECT 1 FROM products WHERE id = p_product_id) THEN
    RAISE EXCEPTION 'Producto no encontrado';
  END IF;

  -- Eliminar en orden (FK constraints)
  DELETE FROM product_images WHERE product_id = p_product_id;
  DELETE FROM product_variants WHERE product_id = p_product_id;
  DELETE FROM products WHERE id = p_product_id;

  RETURN json_build_object(
    'success', true,
    'message', 'Producto eliminado correctamente'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION admin_delete_product(TEXT, UUID) TO anon, authenticated;


-- =============================================
-- admin_get_invoices
-- Obtiene TODAS las facturas con datos del pedido asociado
-- Bypasea RLS con SECURITY DEFINER
-- =============================================
DROP FUNCTION IF EXISTS admin_get_invoices(TEXT);
CREATE OR REPLACE FUNCTION admin_get_invoices(p_admin_email TEXT)
RETURNS JSON
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_result JSON;
BEGIN
  -- Verificar que es un admin válido
  IF NOT EXISTS (
    SELECT 1 FROM admins 
    WHERE email = p_admin_email 
    AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Usuario admin no válido';
  END IF;

  SELECT json_agg(row_to_json(t))
  INTO v_result
  FROM (
    SELECT 
      f.id,
      f.order_id,
      f.created_at,
      json_build_object(
        'customer_email', o.customer_email,
        'customer_name', o.customer_name,
        'status', o.status,
        'total_price', o.total_price
      ) AS orders
    FROM facturacion f
    INNER JOIN orders o ON o.id = f.order_id
    ORDER BY f.created_at DESC
  ) t;

  RETURN COALESCE(v_result, '[]'::json);
END;
$$;

GRANT EXECUTE ON FUNCTION admin_get_invoices(TEXT) TO anon, authenticated;


-- =============================================
-- TABLA DE DEVOLUCIONES PARCIALES POR ITEM
-- =============================================
CREATE TABLE IF NOT EXISTS order_item_returns (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  order_item_id INTEGER NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
  quantity_returned INTEGER NOT NULL CHECK (quantity_returned > 0),
  reason TEXT,
  refund_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
  processed_by TEXT, -- admin email
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_order_item_returns_order ON order_item_returns(order_id);
CREATE INDEX IF NOT EXISTS idx_order_item_returns_item ON order_item_returns(order_item_id);

-- RLS deshabilitado (acceso vía SECURITY DEFINER RPCs)
ALTER TABLE order_item_returns ENABLE ROW LEVEL SECURITY;


-- =============================================
-- RPC: Obtener items de un pedido con devoluciones previas
-- =============================================
CREATE OR REPLACE FUNCTION admin_get_order_items(
  p_admin_email TEXT,
  p_order_id INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_admin_exists BOOLEAN;
  v_result JSONB;
BEGIN
  SELECT EXISTS(SELECT 1 FROM admin_users WHERE email = p_admin_email AND is_active = true)
  INTO v_admin_exists;
  
  IF NOT v_admin_exists THEN
    RAISE EXCEPTION 'No autorizado';
  END IF;

  SELECT jsonb_agg(
    jsonb_build_object(
      'id', oi.id,
      'order_id', oi.order_id,
      'product_id', oi.product_id,
      'product_name', oi.product_name,
      'product_image', oi.product_image,
      'size', oi.size,
      'color', oi.color,
      'quantity', oi.quantity,
      'price_at_purchase', oi.price_at_purchase,
      'already_returned', COALESCE(
        (SELECT SUM(r.quantity_returned) FROM order_item_returns r WHERE r.order_item_id = oi.id),
        0
      )
    )
    ORDER BY oi.id
  )
  INTO v_result
  FROM order_items oi
  WHERE oi.order_id = p_order_id;

  RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

GRANT EXECUTE ON FUNCTION admin_get_order_items(TEXT, INTEGER) TO anon, authenticated;


-- =============================================
-- RPC: Procesar devolución parcial
-- p_data: {
--   "order_id": 123,
--   "reason": "Talla incorrecta",
--   "items": [
--     {"order_item_id": 1, "quantity_to_return": 1},
--     {"order_item_id": 2, "quantity_to_return": 2}
--   ]
-- }
-- NUNCA devuelve el envío. Solo suma de (price_at_purchase * quantity_to_return)
-- =============================================
CREATE OR REPLACE FUNCTION admin_process_partial_return(
  p_admin_email TEXT,
  p_data JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_admin_exists BOOLEAN;
  v_order_id INTEGER;
  v_order_status TEXT;
  v_item JSONB;
  v_order_item RECORD;
  v_already_returned INTEGER;
  v_qty_to_return INTEGER;
  v_refund_total NUMERIC(10,2) := 0;
  v_item_refund NUMERIC(10,2);
  v_all_items_returned BOOLEAN;
  v_new_status TEXT;
BEGIN
  -- Verificar admin
  SELECT EXISTS(SELECT 1 FROM admin_users WHERE email = p_admin_email AND is_active = true)
  INTO v_admin_exists;
  
  IF NOT v_admin_exists THEN
    RAISE EXCEPTION 'No autorizado';
  END IF;

  v_order_id := (p_data->>'order_id')::integer;

  -- Verificar que el pedido existe y está en estado válido para devolución
  SELECT status INTO v_order_status FROM orders WHERE id = v_order_id;
  
  IF v_order_status IS NULL THEN
    RAISE EXCEPTION 'Pedido no encontrado';
  END IF;
  
  IF v_order_status NOT IN ('delivered', 'return_requested', 'partial_return') THEN
    RAISE EXCEPTION 'El pedido no está en un estado válido para devolución (estado actual: %)', v_order_status;
  END IF;

  -- Procesar cada item
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_data->'items')
  LOOP
    v_qty_to_return := (v_item->>'quantity_to_return')::integer;
    
    IF v_qty_to_return <= 0 THEN
      CONTINUE;
    END IF;

    -- Obtener info del order_item
    SELECT oi.* INTO v_order_item
    FROM order_items oi
    WHERE oi.id = (v_item->>'order_item_id')::integer
      AND oi.order_id = v_order_id;
    
    IF v_order_item IS NULL THEN
      RAISE EXCEPTION 'Item de pedido no encontrado: %', v_item->>'order_item_id';
    END IF;

    -- Verificar que no se excede la cantidad disponible
    SELECT COALESCE(SUM(r.quantity_returned), 0) INTO v_already_returned
    FROM order_item_returns r
    WHERE r.order_item_id = v_order_item.id;
    
    IF (v_already_returned + v_qty_to_return) > v_order_item.quantity THEN
      RAISE EXCEPTION 'No se puede devolver más unidades de las compradas para "%"', v_order_item.product_name;
    END IF;

    -- Calcular reembolso de este item (SIN envío)
    v_item_refund := v_order_item.price_at_purchase * v_qty_to_return;
    v_refund_total := v_refund_total + v_item_refund;

    -- Insertar registro de devolución
    INSERT INTO order_item_returns (order_id, order_item_id, quantity_returned, reason, refund_amount, processed_by)
    VALUES (v_order_id, v_order_item.id, v_qty_to_return, p_data->>'reason', v_item_refund, p_admin_email);

    -- Restaurar stock en product_variants
    UPDATE product_variants
    SET stock = stock + v_qty_to_return
    WHERE product_id = v_order_item.product_id::uuid
      AND size = v_order_item.size
      AND (
        (color IS NULL AND v_order_item.color IS NULL)
        OR color = v_order_item.color
      );
    
    -- Actualizar stock total del producto
    UPDATE products
    SET stock = stock + v_qty_to_return
    WHERE id = v_order_item.product_id::uuid;
  END LOOP;

  IF v_refund_total <= 0 THEN
    RAISE EXCEPTION 'No se seleccionaron items para devolver';
  END IF;

  -- Determinar nuevo estado: si TODOS los items están completamente devueltos → returned, sino → partial_return
  SELECT NOT EXISTS(
    SELECT 1 FROM order_items oi
    WHERE oi.order_id = v_order_id
    AND oi.quantity > COALESCE(
      (SELECT SUM(r.quantity_returned) FROM order_item_returns r WHERE r.order_item_id = oi.id),
      0
    )
  ) INTO v_all_items_returned;

  v_new_status := CASE WHEN v_all_items_returned THEN 'returned' ELSE 'partial_return' END;

  UPDATE orders SET status = v_new_status, updated_at = NOW() WHERE id = v_order_id;

  RETURN jsonb_build_object(
    'success', true,
    'refund_amount', v_refund_total,
    'new_status', v_new_status,
    'message', format('Devolución procesada: €%s (envío no incluido)', v_refund_total)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION admin_process_partial_return(TEXT, JSONB) TO anon, authenticated;


-- =============================================
-- SQL para backfill: Rellenar products.colors desde product_variants
-- Ejecutar una vez para productos que tienen variantes con color pero colors JSONB es NULL
-- =============================================
-- UPDATE products p
-- SET colors = (
--   SELECT jsonb_agg(DISTINCT jsonb_build_object('name', pv.color, 'hex', COALESCE(
--     (SELECT pi.color_hex FROM product_images pi WHERE pi.product_id = p.id AND pi.color = pv.color LIMIT 1),
--     '#808080'
--   )))
--   FROM product_variants pv
--   WHERE pv.product_id = p.id AND pv.color IS NOT NULL AND pv.color != ''
-- )
-- WHERE p.colors IS NULL
-- AND EXISTS (
--   SELECT 1 FROM product_variants pv2 
--   WHERE pv2.product_id = p.id AND pv2.color IS NOT NULL AND pv2.color != ''
-- );


-- =============================================
-- VERIFICACION
-- =============================================
-- Para probar, ejecuta (reemplaza con tu email de admin):
-- SELECT admin_get_products('tu_email@admin.com');
-- SELECT admin_get_dashboard_stats('tu_email@admin.com');
-- SELECT admin_get_customers('tu_email@admin.com');
-- SELECT admin_get_orders('tu_email@admin.com', NULL);
-- SELECT admin_get_sales_last_7_days('tu_email@admin.com');
-- SELECT admin_create_product('tu_email@admin.com', '{"name":"Test","price":29.99,"category_id":"...","variants":[{"size":"M","stock":10}],"images":[{"image_url":"https://...","order":0}]}'::jsonb);
-- SELECT admin_update_product('tu_email@admin.com', 'product-uuid-here'::uuid, '{"name":"Updated","price":39.99,"variants":[{"size":"M","stock":5}]}'::jsonb);
-- SELECT admin_delete_product('tu_email@admin.com', 'product-uuid-here'::uuid);
