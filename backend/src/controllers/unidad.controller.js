import * as unidadService from '../services/unidad.service.js';
import { success, formatUnidad, formatUbicacion } from '../utils/response.js';

function notFoundError() {
  const err = new Error('La unidad no fue encontrada.');
  err.code = 'NOT_FOUND';
  err.statusCode = 404;
  return err;
}

export async function listUnidades(req, res, next) {
  try {
    const rows = await unidadService.listUnidades();
    return success(res, { unidades: rows.map(formatUnidad) });
  } catch (err) {
    next(err);
  }
}

export async function getUnidad(req, res, next) {
  try {
    const row = await unidadService.getUnidadById(req.params.id);
    if (!row) throw notFoundError();
    return success(res, formatUnidad(row));
  } catch (err) {
    next(err);
  }
}

export async function createUnidad(req, res, next) {
  try {
    const row = await unidadService.createUnidad(req.body ?? {});
    return success(res, formatUnidad(row), 201);
  } catch (err) {
    next(err);
  }
}

export async function updateUnidad(req, res, next) {
  try {
    const row = await unidadService.updateUnidad(req.params.id, req.body ?? {});
    return success(res, formatUnidad(row));
  } catch (err) {
    next(err);
  }
}

export async function updateUnidadEstado(req, res, next) {
  try {
    const { estado } = req.body ?? {};
    if (typeof estado !== 'boolean') {
      const err = new Error('El campo "estado" es requerido y debe ser booleano.');
      err.code = 'BAD_REQUEST';
      err.statusCode = 400;
      err.isValidation = true;
      throw err;
    }
    const row = await unidadService.updateUnidadEstado(req.params.id, estado);
    return success(res, formatUnidad(row));
  } catch (err) {
    next(err);
  }
}

export async function registrarUbicacion(req, res, next) {
  try {
    const row = await unidadService.registrarUbicacion(req.params.id, req.body ?? {});
    return success(res, formatUbicacion(row), 201);
  } catch (err) {
    next(err);
  }
}

export async function getUltimaUbicacion(req, res, next) {
  try {
    const row = await unidadService.getUltimaUbicacion(req.params.id);
    if (!row) {
      const err = new Error('Esta unidad todavía no reporta ubicación.');
      err.code = 'NO_LOCATION_YET';
      err.statusCode = 404;
      throw err;
    }
    return success(res, formatUbicacion(row));
  } catch (err) {
    next(err);
  }
}

export async function getHistorial(req, res, next) {
  try {
    const { desde, hasta, limit } = req.query;
    const rows = await unidadService.getHistorialUbicaciones(req.params.id, { desde, hasta, limit });
    return success(res, { historial: rows.map(formatUbicacion), total: rows.length });
  } catch (err) {
    next(err);
  }
}
