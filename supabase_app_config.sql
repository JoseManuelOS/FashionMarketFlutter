-- ═══════════════════════════════════════════════════════════════
-- app_config: Tabla de configuración global clave-valor.
-- Permite activar/desactivar ofertas, etc. desde el panel admin.
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.app_config (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL DEFAULT 'true',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Habilitar Realtime en app_config para que los clientes reciban cambios
ALTER PUBLICATION supabase_realtime ADD TABLE app_config;

-- Habilitar Realtime para products (ofertas en tiempo real)
-- (puede que ya esté habilitado; ignorar si da error)
ALTER PUBLICATION supabase_realtime ADD TABLE products;

-- RLS: Lectura pública, escritura solo admins
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "app_config_public_read"
ON public.app_config FOR SELECT
USING (true);

CREATE POLICY "app_config_admin_write"
ON public.app_config FOR ALL
USING (
  EXISTS (SELECT 1 FROM admins WHERE email = auth.jwt() ->> 'email')
);

-- Insertar valor por defecto
INSERT INTO public.app_config (key, value)
VALUES ('offers_enabled', 'true')
ON CONFLICT (key) DO NOTHING;

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_app_config_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER app_config_updated
  BEFORE UPDATE ON public.app_config
  FOR EACH ROW
  EXECUTE FUNCTION update_app_config_timestamp();
