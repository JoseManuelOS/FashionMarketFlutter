-- =============================================
-- FIX: Políticas RLS de customers que causan
-- "permission denied for table users" (error 42501)
-- =============================================
-- EJECUTAR EN: Supabase SQL Editor
-- 
-- PROBLEMA: La política "customers_admin_all" hace SELECT en auth.users,
-- pero los usuarios normales no tienen permiso para acceder a auth.users.
-- Esto causa un error en cascada cuando:
--   1. orders_select_own → sub-query en customers → customers_admin_all → auth.users → ERROR
--   2. Cualquier consulta que toque la tabla customers indirectamente
-- =============================================

-- 1. Eliminar la política problemática
DROP POLICY IF EXISTS "customers_admin_all" ON customers;

-- 2. Recrear políticas seguras para customers
DROP POLICY IF EXISTS "customers_own_profile_select" ON customers;
CREATE POLICY "customers_own_profile_select"
  ON customers FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "customers_own_profile_update" ON customers;
CREATE POLICY "customers_own_profile_update"
  ON customers FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 3. Eliminar la política de admin en customer_addresses (mismo problema)
DROP POLICY IF EXISTS "customer_addresses_admin_all" ON customer_addresses;

-- 4. Recrear políticas seguras para customer_addresses
DROP POLICY IF EXISTS "customer_addresses_own_select" ON customer_addresses;
CREATE POLICY "customer_addresses_own_select"
  ON customer_addresses FOR SELECT
  TO authenticated
  USING (auth.uid() = customer_id);

DROP POLICY IF EXISTS "customer_addresses_own_insert" ON customer_addresses;
CREATE POLICY "customer_addresses_own_insert"
  ON customer_addresses FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = customer_id);

DROP POLICY IF EXISTS "customer_addresses_own_update" ON customer_addresses;
CREATE POLICY "customer_addresses_own_update"
  ON customer_addresses FOR UPDATE
  TO authenticated
  USING (auth.uid() = customer_id)
  WITH CHECK (auth.uid() = customer_id);

DROP POLICY IF EXISTS "customer_addresses_own_delete" ON customer_addresses;
CREATE POLICY "customer_addresses_own_delete"
  ON customer_addresses FOR DELETE
  TO authenticated
  USING (auth.uid() = customer_id);

-- =============================================
-- ✅ VERIFICACIÓN
-- =============================================
SELECT '✅ Política customers_admin_all eliminada' as status;

-- Verificar políticas activas
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('customers', 'customer_addresses', 'orders')
ORDER BY tablename, policyname;
