import { getSupabase } from '../config/supabase.js';
import { validateReporteInput } from '../utils/reporte.validation.js';

export async function createReporte({ titulo, descripcion, distrito, latitud, longitud, fotoUrl, userId }) {
  const validated = validateReporteInput({
    descripcion,
    distrito,
    latitud,
    longitud,
    hasFoto: Boolean(fotoUrl),
  });

  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('reportes_malos_trabajos')
    .insert({
      titulo: titulo?.trim() || null,
      descripcion: validated.descripcion,
      distrito: validated.distrito,
      latitud: validated.latitud,
      longitud: validated.longitud,
      foto_url: fotoUrl,
      user_id: userId ?? null,
      estado: 'Pendiente',
    })
    .select('*')
    .single();

  if (error) throw error;
  return data;
}

export async function listReportes() {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('reportes_malos_trabajos')
    .select('*')
    .order('created_at', { ascending: false });

  if (error) throw error;
  return data;
}

export async function getReporteById(id) {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('reportes_malos_trabajos')
    .select('*')
    .eq('id_reporte', id)
    .maybeSingle();

  if (error) throw error;
  return data;
}
