export function success(res, data, statusCode = 200) {
  return res.status(statusCode).json({ success: true, data });
}

export function successMessage(res, message, statusCode = 200) {
  return res.status(statusCode).json({ success: true, message });
}

export function error(res, code, message, statusCode = 400) {
  return res.status(statusCode).json({
    success: false,
    error: { code, message },
  });
}

export function formatUser(row) {
  if (!row) return null;

  return {
    id: row.id,
    email: row.email,
    nombre: row.nombre,
    rol: row.rol,
    activo: row.activo,
    createdAt: row.created_at,
    ultimoLogin: row.ultimo_login ?? null,
  };
}

export function formatLegacyUsuario(row) {
  if (!row) return null;

  return {
    idUsuario: row.id_usuario,
    nombre: row.nombre,
    apellido: row.apellido,
    correo: row.correo,
    telefono: row.telefono ?? '',
    direccion: row.direccion ?? null,
    latitud: row.latitud ?? null,
    longitud: row.longitud ?? null,
    estado: row.estado,
    fechaRegistro: row.fecha_registro,
    rol: row.rol
      ? { idRol: row.rol.id_rol, nombre: row.rol.nombre }
      : null,
    zona: row.zona
      ? { idZona: row.zona.id_zona, nombre: row.zona.nombre }
      : null,
  };
}
