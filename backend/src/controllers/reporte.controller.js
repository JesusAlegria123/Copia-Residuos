import * as reporteService from '../services/reporte.service.js';
import { success } from '../utils/response.js';
import { DISTRITOS_CUSCO } from '../utils/reporte.validation.js';

function formatReporte(row, req) {
  const baseUrl = `${req.protocol}://${req.get('host')}`;
  const fotoUrl = row.foto_url?.startsWith('http')
    ? row.foto_url
    : row.foto_url
      ? `${baseUrl}${row.foto_url}`
      : null;

  return {
    idReporte: row.id_reporte,
    titulo: row.titulo,
    descripcion: row.descripcion,
    distrito: row.distrito,
    latitud: Number(row.latitud),
    longitud: Number(row.longitud),
    fotoUrl,
    estado: row.estado,
    userId: row.user_id ?? null,
    createdAt: row.created_at,
  };
}

export function getDistritos(_req, res) {
  return success(res, { distritos: DISTRITOS_CUSCO });
}

export async function createReporte(req, res, next) {
  try {
    const { titulo, descripcion, distrito, latitud, longitud } = req.body;
    const fotoPath = req.file ? `/uploads/reportes/${req.file.filename}` : null;

    const row = await reporteService.createReporte({
      titulo,
      descripcion,
      distrito,
      latitud,
      longitud,
      fotoUrl: fotoPath,
      userId: req.user?.id,
    });

    return success(res, formatReporte(row, req), 201);
  } catch (err) {
    next(err);
  }
}

export async function listReportes(req, res, next) {
  try {
    const { estado, distrito } = req.query;
    const rows = await reporteService.listReportes({ estado, distrito });
    return success(res, {
      reportes: rows.map((row) => formatReporte(row, req)),
      total: rows.length,
    });
  } catch (err) {
    next(err);
  }
}

export async function getReporte(req, res, next) {
  try {
    const row = await reporteService.getReporteById(req.params.id);
    if (!row) {
      const err = new Error('El reporte no fue encontrado.');
      err.code = 'NOT_FOUND';
      err.statusCode = 404;
      throw err;
    }
    return success(res, formatReporte(row, req));
  } catch (err) {
    next(err);
  }
}

export async function updateEstadoReporte(req, res, next) {
  try {
    const { id } = req.params;
    const { estado } = req.body;

    if (!estado) {
      const err = new Error('El campo "estado" es requerido.');
      err.statusCode = 400;
      err.code = 'FIELD_REQUIRED';
      throw err;
    }

    const row = await reporteService.updateEstadoReporte(id, estado);
    return success(res, formatReporte(row, req));
  } catch (err) {
    next(err);
  }
}
