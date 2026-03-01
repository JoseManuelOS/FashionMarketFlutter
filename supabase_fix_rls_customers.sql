-- =============================================
-- FIX COMPLETO: Políticas RLS que causan
-- "permission denied for table users" (error 42501)
-- =============================================
-- EJECUTAR EN: Supabase SQL Editor
--
-- ESTRATEGIA: Eliminar TODAS las políticas de las tablas afectadas
-- usando DO $$ ... $$ para borrar por nombre dinámicamente,
-- luego recrear solo las políticas seguras (sin auth.users).
-- =============================================

-- =============================================
-- PASO 1: Eliminar TODAS las políticas existentes
-- en las 4 tablas de golpe (sin importar el nombre)
-- =============================================
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT policyname, tablename
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN ('customers', 'customer_addresses', 'orders', 'order_items')
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I', r.policyname, r.tablename);
  END LOOP;
END $$;

-- =============================================
-- PASO 2: Asegurar RLS habilitado
-- =============================================
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- =============================================
-- PASO 3: Recrear políticas SEGURAS (sin auth.users)
-- =============================================

-- ----- CUSTOMERS -----
CREATE POLICY "customers_select_own"
  ON customers FOR SELECT
  TO authenticated
  USING (
    auth.uid() = id
    OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  );

CREATE POLICY "customers_update_own"
  ON customers FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "customers_insert_own"
  ON customers FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- ----- CUSTOMER_ADDRESSES -----
CREATE POLICY "customer_addresses_select_own"
  ON customer_addresses FOR SELECT
  TO authenticated
  USING (auth.uid() = customer_id);

CREATE POLICY "customer_addresses_insert_own"
  ON customer_addresses FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "customer_addresses_update_own"
  ON customer_addresses FOR UPDATE
  TO authenticated
  USING (auth.uid() = customer_id)
  WITH CHECK (auth.uid() = customer_id);

CREATE POLICY "customer_addresses_delete_own"
  ON customer_addresses FOR DELETE
  TO authenticated
  USING (auth.uid() = customer_id);

-- ----- ORDERS -----
-- Clientes ven sus pedidos por customer_id o email
-- Admins ven todos (via JWT, sin tocar auth.users)
CREATE POLICY "orders_select_own"
  ON orders FOR SELECT
  TO authenticated
  USING (
    customer_id = auth.uid()
    OR customer_email = (auth.jwt() ->> 'email')
    OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  );

CREATE POLICY "orders_insert_auth"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "orders_insert_anon"
  ON orders FOR INSERT
  TO anon
  WITH CHECK (
    total_price >= 0
    AND status IN ('pending', 'paid')
  );

CREATE POLICY "orders_update_own"
  ON orders FOR UPDATE
  TO authenticated
  USING (
    customer_id = auth.uid()
    OR customer_email = (auth.jwt() ->> 'email')
    OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  )
  WITH CHECK (true);

-- ----- ORDER_ITEMS -----
-- Sub-query a orders sin usar auth.users
CREATE POLICY "order_items_select_own"
  ON order_items FOR SELECT
  TO authenticated
  USING (
    order_id IN (
      SELECT id FROM orders
      WHERE customer_id = auth.uid()
         OR customer_email = (auth.jwt() ->> 'email')
         OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
    )
  );

CREATE POLICY "order_items_insert_auth"
  ON order_items FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "order_items_insert_anon"
  ON order_items FOR INSERT
  TO anon
  WITH CHECK (
    quantity > 0
    AND price_at_purchase >= 0
  );

-- =============================================
-- ✅ VERIFICACIÓN
-- =============================================
SELECT '✅ Todas las políticas recreadas sin auth.users' AS status;

-- Ver políticas activas (verificar que ninguna mencione auth.users)
SELECT tablename, policyname, cmd, qual
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('customers', 'customer_addresses', 'orders', 'order_items')
ORDER BY tablename, policyname;
