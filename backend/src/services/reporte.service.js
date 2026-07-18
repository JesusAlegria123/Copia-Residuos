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

export async function updateEstadoReporte(id, estado, adminId) {
  const ESTADOS_VALIDOS = ['Pendiente', 'En Proceso', 'Resuelto', 'Rechazado'];
  if (!ESTADOS_VALIDOS.includes(estado)) {
    const err = new Error(`Estado inválido. Usa: ${ESTADOS_VALIDOS.join(', ')}`);
    err.statusCode = 400;
    err.code = 'INVALID_ESTADO';
    throw err;
  }

  const actual = await getReporteById(id);
  if (!actual) {
    const err = new Error('El reporte no fue encontrado.');
    err.statusCode = 404;
    err.code = 'NOT_FOUND';
    throw err;
  }

  // Transición inválida: un reporte ya Resuelto/Rechazado no vuelve a Pendiente
  // salvo que un admin explícitamente lo reabra pasándolo a "En Proceso".
  const ESTADOS_FINALES = ['Resuelto', 'Rechazado'];
  if (ESTADOS_FINALES.includes(actual.estado) && estado === 'Pendiente') {
    const err = new Error(
      `El reporte ya está en estado "${actual.estado}" y no puede volver a "Pendiente". Usa "En Proceso" para reabrirlo.`
    );
    err.statusCode = 409;
    err.code = 'INVALID_TRANSITION';
    throw err;
  }

  const payload = { estado };
  // Solo registramos quién resolvió/rechazó; si vuelve a estar activo, se limpia.
  payload.resuelto_por = ESTADOS_FINALES.includes(estado) ? adminId ?? null : null;

  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('reportes_malos_trabajos')
    .update(payload)
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
