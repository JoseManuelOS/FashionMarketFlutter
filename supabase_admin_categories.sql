-- =============================================
-- FUNCIONES RPC PARA ADMIN DE CATEGORÍAS (FLUTTER)
-- Estas funciones permiten al admin gestionar categorías
-- bypaseando las políticas RLS
-- =============================================
-- EJECUTAR EN: Supabase SQL Editor
-- COMPATIBLE CON: FashionStore schema (categories table)

-- =============================================
-- admin_get_categories
-- Obtiene TODAS las categorías con conteo de productos
-- =============================================
DROP FUNCTION IF EXISTS admin_get_categories(TEXT);
CREATE OR REPLACE FUNCTION admin_get_categories(p_admin_email TEXT)
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

  SELECT json_agg(
    json_build_object(
      'id', c.id,
      'name', c.name,
      'slug', c.slug,
      'description', c.description,
      'image_url', c.image_url,
      'display_order', c.display_order,
      'created_at', c.created_at,
      'products_count', COALESCE(pc.cnt, 0)
    )
    ORDER BY c.display_order ASC, c.name ASC
  ) INTO v_result
  FROM categories c
  LEFT JOIN (
    SELECT category_id, COUNT(*) as cnt
    FROM products
    WHERE active = true
    GROUP BY category_id
  ) pc ON c.id = pc.category_id;

  RETURN COALESCE(v_result, '[]'::json);
END;
$$;

GRANT EXECUTE ON FUNCTION admin_get_categories(TEXT) TO anon, authenticated;

-- =============================================
-- admin_upsert_category
-- Crea o actualiza una categoría
-- =============================================
DROP FUNCTION IF EXISTS admin_upsert_category(TEXT, JSONB);
CREATE OR REPLACE FUNCTION admin_upsert_category(
  p_admin_email TEXT,
  p_data JSONB
)
RETURNS JSON
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_id UUID;
  v_name TEXT;
  v_slug TEXT;
  v_description TEXT;
  v_image_url TEXT;
  v_display_order INTEGER;
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

  -- Extraer datos del JSONB
  v_id := (p_data->>'id')::UUID;
  v_name := p_data->>'name';
  v_slug := p_data->>'slug';
  v_description := p_data->>'description';
  v_image_url := p_data->>'image_url';
  v_display_order := COALESCE((p_data->>'display_order')::INTEGER, 0);

  IF v_name IS NULL OR v_slug IS NULL THEN
    RAISE EXCEPTION 'name y slug son requeridos';
  END IF;

  IF v_id IS NOT NULL THEN
    -- UPDATE
    UPDATE categories SET
      name = v_name,
      slug = v_slug,
      description = v_description,
      image_url = v_image_url,
      display_order = v_display_order
    WHERE id = v_id;

    v_result := json_build_object('success', true, 'id', v_id, 'action', 'updated');
  ELSE
    -- INSERT
    INSERT INTO categories (name, slug, description, image_url, display_order)
    VALUES (v_name, v_slug, v_description, v_image_url, v_display_order)
    RETURNING id INTO v_id;

    v_result := json_build_object('success', true, 'id', v_id, 'action', 'created');
  END IF;

  RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_upsert_category(TEXT, JSONB) TO anon, authenticated;

-- =============================================
-- admin_delete_category
-- Elimina una categoría (products quedan con category_id = NULL)
-- =============================================
DROP FUNCTION IF EXISTS admin_delete_category(TEXT, UUID);
CREATE OR REPLACE FUNCTION admin_delete_category(
  p_admin_email TEXT,
  p_category_id UUID
)
RETURNS JSON
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Verificar que es un admin válido
  IF NOT EXISTS (
    SELECT 1 FROM admins 
    WHERE email = p_admin_email 
    AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Usuario admin no válido';
  END IF;

  -- Verificar que la categoría existe
  IF NOT EXISTS (SELECT 1 FROM categories WHERE id = p_category_id) THEN
    RAISE EXCEPTION 'Categoría no encontrada';
  END IF;

  -- Eliminar (products.category_id = NULL por ON DELETE SET NULL)
  DELETE FROM categories WHERE id = p_category_id;

  RETURN json_build_object('success', true, 'message', 'Categoría eliminada');
END;
$$;

GRANT EXECUTE ON FUNCTION admin_delete_category(TEXT, UUID) TO anon, authenticated;

-- =============================================
-- VERIFICACIÓN
-- =============================================
-- SELECT admin_get_categories('tu_email@admin.com');
-- SELECT admin_upsert_category('tu_email@admin.com', '{"name":"Test","slug":"test"}'::jsonb);
-- SELECT admin_delete_category('tu_email@admin.com', 'uuid-aqui'::uuid);
