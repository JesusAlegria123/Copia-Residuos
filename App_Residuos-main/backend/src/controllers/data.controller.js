import * as dataService from '../services/data.service.js';
import { formatLegacyUsuario, formatUser, success } from '../utils/response.js';

export async function getUsuarios(req, res, next) {
  try {
    const rows = await dataService.listUsuarios();
    return success(res, { usuarios: rows.map(formatLegacyUsuario) });
  } catch (err) {
    next(err);
  }
}

export async function getUsuario(req, res, next) {
  try {
    const row = await dataService.getUsuarioById(req.params.id);
    if (!row) {
      const err = new Error('El recurso no fue encontrado.');
      err.code = 'NOT_FOUND';
      err.statusCode = 404;
      throw err;
    }
    return success(res, formatLegacyUsuario(row));
  } catch (err) {
    next(err);
  }
}

export async function disableUsuario(req, res, next) {
  try {
    const row = await dataService.updateUsuarioEstado(req.params.id, false);
    return success(res, formatLegacyUsuario(row));
  } catch (err) {
    next(err);
  }
}

export async function enableUsuario(req, res, next) {
  try {
    const row = await dataService.updateUsuarioEstado(req.params.id, true);
    return success(res, formatLegacyUsuario(row));
  } catch (err) {
    next(err);
  }
}

export async function getRoles(req, res, next) {
  try {
    const rows = await dataService.listRoles();
    return success(res, {
      roles: rows.map((r) => ({ idRol: r.id_rol, nombre: r.nombre })),
    });
  } catch (err) {
    next(err);
  }
}

export async function getZonas(req, res, next) {
  try {
    const rows = await dataService.listZonas();
    return success(res, {
      zonas: rows.map((z) => ({
        idZona: z.id_zona,
        nombre: z.nombre,
        descripcion: z.descripcion ?? null,
      })),
    });
  } catch (err) {
    next(err);
  }
}

export async function getRutas(req, res, next) {
  try {
    const rows = await dataService.listRutas();
    return success(res, {
      rutas: rows.map((r) => ({
        idRuta: r.id_ruta,
        nombre: r.nombre,
        descripcion: r.descripcion ?? null,
        estado: r.estado,
        zona: r.zona
          ? { idZona: r.zona.id_zona, nombre: r.zona.nombre }
          : null,
      })),
    });
  } catch (err) {
    next(err);
  }
}

export async function getRuta(req, res, next) {
  try {
    const row = await dataService.getRutaById(req.params.id);
    if (!row) {
      const err = new Error('El recurso no fue encontrado.');
      err.code = 'NOT_FOUND';
      err.statusCode = 404;
      throw err;
    }

    return success(res, {
      idRuta: row.id_ruta,
      nombre: row.nombre,
      descripcion: row.descripcion ?? null,
      estado: row.estado,
      zona: row.zona
        ? { idZona: row.zona.id_zona, nombre: row.zona.nombre }
        : null,
      puntos: (row.ruta_puntos ?? [])
        .sort((a, b) => a.orden_recorrido - b.orden_recorrido)
        .map((p) => ({
          idPunto: p.id_punto,
          latitud: p.latitud,
          longitud: p.longitud,
          ordenRecorrido: p.orden_recorrido,
        })),
      horarios: (row.horarios ?? []).map((h) => ({
        idHorario: h.id_horario,
        diaSemana: h.dia_semana,
        horaInicio: h.hora_inicio,
        horaFin: h.hora_fin,
      })),
    });
  } catch (err) {
    next(err);
  }
}

export async function getAuthUsers(req, res, next) {
  try {
    const rows = await dataService.listAuthUsers();
    return success(res, { users: rows.map(formatUser) });
  } catch (err) {
    next(err);
  }
}

export async function updateAuthUserStatus(req, res, next) {
  try {
    const { activo } = req.body;
    if (typeof activo !== 'boolean') {
      const err = new Error('Solicitud inválida. Por favor, verifica tus datos.');
      err.code = 'BAD_REQUEST';
      err.statusCode = 400;
      err.isValidation = true;
      throw err;
    }

    const row = await dataService.updateAuthUserStatus(req.params.id, activo);
    return success(res, formatUser(row));
  } catch (err) {
    next(err);
  }
}
