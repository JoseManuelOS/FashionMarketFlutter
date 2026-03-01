/**
 * CORS headers para Supabase Edge Functions.
 * Permite llamadas desde cualquier origen (Flutter Web, app móvil, etc.)
 */
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
