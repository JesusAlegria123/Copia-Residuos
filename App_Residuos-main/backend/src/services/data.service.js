import { getSupabase } from '../config/supabase.js';

const USUARIO_SELECT = `
  id_usuario,
  nombre,
  apellido,
  correo,
  telefono,
  direccion,
  latitud,
  longitud,
  estado,
  fecha_registro,
  rol:roles(id_rol, nombre),
  zona:zonas(id_zona, nombre)
`;

export async function listUsuarios() {
  const supabase = getSupabase();
  const { data, error } = await supabase.from('usuarios').select(USUARIO_SELECT).order('id_usuario');

  if (error) throw error;
  return data;
}

export async function getUsuarioById(id) {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('usuarios')
    .select(USUARIO_SELECT)
    .eq('id_usuario', id)
    .maybeSingle();

  if (error) throw error;
  return data;
}

export async function updateUsuarioEstado(id, estado) {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('usuarios')
    .update({ estado })
    .eq('id_usuario', id)
    .select(USUARIO_SELECT)
    .single();

  if (error) throw error;
  return data;
}

export async function listRoles() {
  const supabase = getSupabase();
  const { data, error } = await supabase.from('roles').select('*').order('id_rol');
  if (error) throw error;
  return data;
}

export async function listZonas() {
  const supabase = getSupabase();
  const { data, error } = await supabase.from('zonas').select('*').order('id_zona');
  if (error) throw error;
  return data;
}

export async function listRutas() {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('rutas')
    .select(`
      id_ruta,
      nombre,
      descripcion,
      estado,
      zona:zonas(id_zona, nombre)
    `)
    .order('id_ruta');

  if (error) throw error;
  return data;
}

export async function getRutaById(id) {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('rutas')
    .select(`
      id_ruta,
      nombre,
      descripcion,
      estado,
      zona:zonas(id_zona, nombre),
      ruta_puntos(id_punto, latitud, longitud, orden_recorrido),
      horarios(id_horario, dia_semana, hora_inicio, hora_fin)
    `)
    .eq('id_ruta', id)
    .maybeSingle();

  if (error) throw error;
  return data;
}

export async function listAuthUsers() {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('users')
    .select('id, email, nombre, rol, activo, created_at, ultimo_login')
    .order('created_at', { ascending: false });

  if (error) throw error;
  return data;
}

export async function updateAuthUserStatus(id, activo) {
  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('users')
    .update({ activo, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select('id, email, nombre, rol, activo, created_at, ultimo_login')
    .single();

  if (error) throw error;
  return data;
}
