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

export function formatUnidad(row) {
  if (!row) return null;

  return {
    idUnidad: row.id_unidad,
    codigo: row.codigo,
    nombre: row.nombre,
    placa: row.placa ?? null,
    capacidadKg: row.capacidad_kg ?? null,
    colorHex: row.color_hex ?? null,
    estado: row.estado,
    ruta: row.ruta
      ? { idRuta: row.ruta.id_ruta, nombre: row.ruta.nombre }
      : null,
    ultimaUbicacion: row.ultima_ubicacion
      ? {
          latitud: Number(row.ultima_ubicacion.latitud),
          longitud: Number(row.ultima_ubicacion.longitud),
          velocidadKmh: row.ultima_ubicacion.velocidad_kmh ?? null,
          rumbo: row.ultima_ubicacion.rumbo ?? null,
          registradoEn: row.ultima_ubicacion.registrado_en,
        }
      : null,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

export function formatUbicacion(row) {
  if (!row) return null;

  return {
    idUbicacion: row.id_ubicacion,
    idUnidad: row.id_unidad,
    latitud: Number(row.latitud),
    longitud: Number(row.longitud),
    velocidadKmh: row.velocidad_kmh ?? null,
    rumbo: row.rumbo ?? null,
    fuente: row.fuente,
    registradoEn: row.registrado_en,
  };
}

export function formatRecoleccion(row) {
  if (!row) return null;

  return {
    idRecoleccion: row.id_recoleccion,
    idUnidad: row.id_unidad ?? null,
    idRuta: row.id_ruta ?? null,
    tipoResiduo: row.tipo_residuo,
    pesoKg: Number(row.peso_kg),
    registradoPor: row.registrado_por ?? null,
    fecha: row.fecha,
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
