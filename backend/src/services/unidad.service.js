import { getSupabase } from '../config/supabase.js';

const UNIDAD_SELECT = `
  id_unidad,
  codigo,
  nombre,
  placa,
  capacidad_kg,
  color_hex,
  estado,
  created_at,
  updated_at,
  ruta:rutas(id_ruta, nombre)
`;

function notFound(message = 'La unidad no fue encontrada.') {
  const err = new Error(message);
  err.code = 'NOT_FOUND';
  err.statusCode = 404;
  return err;
}

async function attachUltimaUbicacion(supabase, unidad) {
  const { data: ubicacion } = await supabase
    .from('ubicaciones_unidad')
    .select('latitud, longitud, velocidad_kmh, rumbo, registrado_en')
    .eq('id_unidad', unidad.id_unidad)
    .order('registrado_en', { ascending: false })
    .limit(1)
    .maybeSingle();

  return { ...unidad, ultima_ubicacion: ubicacion ?? null };
}

export async function listUnidades() {
  const supabase = getSupabase();
  const { data, error } = await supabase.from('unidades_recoleccion').select(UNIDAD_SELECT).order('id_unidad');
  if (error) throw error;

  return Promise.all(data.map((u) => attachUltimaUbicacion(supabase, u)));
}

export async function getUnidadById(id) {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('unidades_recoleccion')
    .select(UNIDAD_SELECT)
    .eq('id_unidad', id)
    .maybeSingle();

  if (error) throw error;
  if (!data) return null;
  return attachUltimaUbicacion(supabase, data);
}

export async function createUnidad({ codigo, nombre, placa, capacidadKg, colorHex, idRuta }) {
  if (!codigo || !String(codigo).trim()) {
    const err = new Error('El código de la unidad es obligatorio.');
    err.code = 'CODE_REQUIRED';
    err.statusCode = 400;
    err.isValidation = true;
    throw err;
  }
  if (!nombre || !String(nombre).trim()) {
    const err = new Error('El nombre de la unidad es obligatorio.');
    err.code = 'NAME_REQUIRED';
    err.statusCode = 400;
    err.isValidation = true;
    throw err;
  }

  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('unidades_recoleccion')
    .insert({
      codigo: String(codigo).trim(),
      nombre: String(nombre).trim(),
      placa: placa ?? null,
      capacidad_kg: capacidadKg ?? null,
      color_hex: colorHex ?? '#9333EA',
      id_ruta: idRuta ?? null,
    })
    .select(UNIDAD_SELECT)
    .single();

  if (error) {
    if (error.code === '23505') {
      const err = new Error('Ya existe una unidad con ese código.');
      err.code = 'CODE_EXISTS';
      err.statusCode = 400;
      throw err;
    }
    throw error;
  }
  return { ...data, ultima_ubicacion: null };
}

const UNIDAD_EDITABLE_FIELDS = {
  nombre: 'nombre',
  placa: 'placa',
  capacidadKg: 'capacidad_kg',
  colorHex: 'color_hex',
  idRuta: 'id_ruta',
};

export async function updateUnidad(id, cambios) {
  const payload = {};
  for (const [key, column] of Object.entries(UNIDAD_EDITABLE_FIELDS)) {
    if (Object.prototype.hasOwnProperty.call(cambios, key)) {
      payload[column] = cambios[key];
    }
  }

  if (Object.keys(payload).length === 0) {
    const err = new Error('No enviaste ningún campo válido para actualizar.');
    err.code = 'BAD_REQUEST';
    err.statusCode = 400;
    err.isValidation = true;
    throw err;
  }
  payload.updated_at = new Date().toISOString();

  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('unidades_recoleccion')
    .update(payload)
    .eq('id_unidad', id)
    .select(UNIDAD_SELECT)
    .maybeSingle();

  if (error) throw error;
  if (!data) throw notFound();
  return attachUltimaUbicacion(supabase, data);
}

export async function updateUnidadEstado(id, estado) {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('unidades_recoleccion')
    .update({ estado, updated_at: new Date().toISOString() })
    .eq('id_unidad', id)
    .select(UNIDAD_SELECT)
    .maybeSingle();

  if (error) throw error;
  if (!data) throw notFound();
  return attachUltimaUbicacion(supabase, data);
}

export async function registrarUbicacion(idUnidad, { latitud, longitud, velocidadKmh, rumbo, fuente }) {
  const lat = parseFloat(latitud);
  const lng = parseFloat(longitud);

  if (Number.isNaN(lat) || Number.isNaN(lng)) {
    const err = new Error('latitud y longitud son obligatorias y deben ser numéricas.');
    err.code = 'LOCATION_REQUIRED';
    err.statusCode = 400;
    err.isValidation = true;
    throw err;
  }
  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
    const err = new Error('Las coordenadas geográficas no son válidas.');
    err.code = 'INVALID_COORDINATES';
    err.statusCode = 400;
    err.isValidation = true;
    throw err;
  }

  const supabase = getSupabase();

  const unidad = await getUnidadById(idUnidad);
  if (!unidad) throw notFound();

  const { data, error } = await supabase
    .from('ubicaciones_unidad')
    .insert({
      id_unidad: idUnidad,
      latitud: lat,
      longitud: lng,
      velocidad_kmh: velocidadKmh ?? null,
      rumbo: rumbo ?? null,
      fuente: fuente || 'gps',
    })
    .select('*')
    .single();

  if (error) throw error;
  return data;
}

export async function getUltimaUbicacion(idUnidad) {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('ubicaciones_unidad')
    .select('*')
    .eq('id_unidad', idUnidad)
    .order('registrado_en', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) throw error;
  return data;
}

export async function getHistorialUbicaciones(idUnidad, { desde, hasta, limit } = {}) {
  const supabase = getSupabase();
  let query = supabase
    .from('ubicaciones_unidad')
    .select('*')
    .eq('id_unidad', idUnidad)
    .order('registrado_en', { ascending: false })
    .limit(Math.min(Number(limit) || 200, 1000));

  if (desde) query = query.gte('registrado_en', desde);
  if (hasta) query = query.lte('registrado_en', hasta);

  const { data, error } = await query;
  if (error) throw error;
  return data;
}
