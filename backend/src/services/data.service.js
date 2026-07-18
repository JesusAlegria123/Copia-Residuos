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

const USUARIO_EDITABLE_FIELDS = [
  'nombre',
  'apellido',
  'telefono',
  'direccion',
  'latitud',
  'longitud',
  'id_rol',
  'id_zona',
];

export async function updateUsuario(id, cambios) {
  const payload = {};
  for (const field of USUARIO_EDITABLE_FIELDS) {
    if (Object.prototype.hasOwnProperty.call(cambios, field)) {
      payload[field] = cambios[field];
    }
  }

  if (Object.keys(payload).length === 0) {
    const err = new Error('No enviaste ningún campo válido para actualizar.');
    err.code = 'BAD_REQUEST';
    err.statusCode = 400;
    err.isValidation = true;
    throw err;
  }

  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('usuarios')
    .update(payload)
    .eq('id_usuario', id)
    .select(USUARIO_SELECT)
    .maybeSingle();

  if (error) throw error;
  if (!data) {
    const err = new Error('El usuario no fue encontrado.');
    err.code = 'NOT_FOUND';
    err.statusCode = 404;
    throw err;
  }
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

const AUTH_USER_EDITABLE_FIELDS = ['nombre', 'rol'];
const ROLES_VALIDOS = ['Administrador', 'Usuario'];

export async function updateAuthUser(id, cambios) {
  const payload = {};
  for (const field of AUTH_USER_EDITABLE_FIELDS) {
    if (Object.prototype.hasOwnProperty.call(cambios, field)) {
      payload[field] = cambios[field];
    }
  }

  if (Object.keys(payload).length === 0) {
    const err = new Error('No enviaste ningún campo válido para actualizar (nombre, rol).');
    err.code = 'BAD_REQUEST';
    err.statusCode = 400;
    err.isValidation = true;
    throw err;
  }

  if (payload.rol && !ROLES_VALIDOS.includes(payload.rol)) {
    const err = new Error(`Rol inválido. Usa: ${ROLES_VALIDOS.join(', ')}`);
    err.code = 'INVALID_ROL';
    err.statusCode = 400;
    err.isValidation = true;
    throw err;
  }

  payload.updated_at = new Date().toISOString();

  const supabase = getSupabase();
  const { data, error } = await supabase
    .from('users')
    .update(payload)
    .eq('id', id)
    .select('id, email, nombre, rol, activo, created_at, ultimo_login')
    .maybeSingle();

  if (error) throw error;
  if (!data) {
    const err = new Error('El usuario no fue encontrado.');
    err.code = 'NOT_FOUND';
    err.statusCode = 404;
    throw err;
  }
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
