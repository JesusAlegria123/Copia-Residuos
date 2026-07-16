const { createClient } = require('@supabase/supabase-js');
const env = require('./env');

// Usamos la Service Role Key porque este cliente vive en el SERVIDOR,
// nunca en la app Flutter. Esta key ignora RLS, así que el propio
// backend es responsable de aplicar las reglas de autorización.
const supabase = createClient(env.supabaseUrl, env.supabaseServiceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
});

module.exports = supabase;
