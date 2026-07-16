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

export async function listReportes({ estado, distrito } = {}) {
  const supabase = getSupabase();
  let query = supabase
    .from('reportes_malos_trabajos')
    .select('*')
    .order('created_at', { ascending: false });

  if (estado)   query = query.eq('estado', estado);
  if (distrito) query = query.eq('distrito', distrito);

  const { data, error } = await query;
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

export async function updateEstadoReporte(id, estado) {
  const ESTADOS_VALIDOS = ['Pendiente', 'En Proceso', 'Resuelto', 'Rechazado'];
  if (!ESTADOS_VALIDOS.includes(estado)) {
    const err = new Error(`Estado inválido. Usa: ${ESTADOS_VALIDOS.join(', ')}`);
    err.statusCode = 400;
    err.code = 'INVALID_ESTADO';
    throw err;
  }

  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('reportes_malos_trabajos')
    .update({ estado })
    .eq('id_reporte', id)
    .select('*')
    .maybeSingle();

  if (error) throw error;
  if (!data) {
    const err = new Error('El reporte no fue encontrado.');
    err.statusCode = 404;
    err.code = 'NOT_FOUND';
    throw err;
  }
  return data;
}
