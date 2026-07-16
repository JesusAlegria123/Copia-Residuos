import { createClient } from '@supabase/supabase-js';
import { config } from './env.js';

let supabase = null;

export function getSupabase() {
  if (!supabase) {
    if (!config.supabase.url || !config.supabase.serviceRoleKey) {
      throw new Error(
        'Supabase no configurado. Define SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY en .env'
      );
    }

    supabase = createClient(config.supabase.url, config.supabase.serviceRoleKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });
  }

  return supabase;
}
