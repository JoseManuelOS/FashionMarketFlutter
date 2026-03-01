-- =============================================
-- Fix: Añadir partial_return y return_rejected al CHECK constraint de orders.status
-- Ejecutar una vez en Supabase SQL Editor
-- =============================================

-- 1. Eliminar el CHECK constraint existente sobre status (auto-named)
DO $$
DECLARE
  constraint_name text;
BEGIN
  SELECT conname INTO constraint_name
  FROM pg_constraint
  WHERE conrelid = 'public.orders'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) LIKE '%status%';

  IF constraint_name IS NOT NULL THEN
    EXECUTE 'ALTER TABLE public.orders DROP CONSTRAINT ' || quote_ident(constraint_name);
  END IF;
END $$;

-- 2. Añadir el nuevo CHECK constraint con los 9 estados
ALTER TABLE public.orders ADD CONSTRAINT orders_status_check
  CHECK (status = ANY (ARRAY[
    'pending'::text,
    'paid'::text,
    'shipped'::text,
    'delivered'::text,
    'cancelled'::text,
    'return_requested'::text,
    'returned'::text,
    'partial_return'::text,
    'return_rejected'::text
  ]));

-- Verificación
-- SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint WHERE conrelid = 'public.orders'::regclass AND contype = 'c';
