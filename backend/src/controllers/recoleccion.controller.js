import * as recoleccionService from '../services/recoleccion.service.js';
import { success, formatRecoleccion } from '../utils/response.js';

export async function createRecoleccion(req, res, next) {
  try {
    const { idUnidad, idRuta, tipoResiduo, pesoKg } = req.body ?? {};
    const row = await recoleccionService.createRecoleccion({
      idUnidad,
      idRuta,
      tipoResiduo,
      pesoKg,
      registradoPor: req.user?.id,
    });
    return success(res, formatRecoleccion(row), 201);
  } catch (err) {
    next(err);
  }
}

export async function listRecolecciones(req, res, next) {
  try {
    const { idRuta, idUnidad, desde, hasta } = req.query;
    const rows = await recoleccionService.listRecolecciones({ idRuta, idUnidad, desde, hasta });
    return success(res, { recolecciones: rows.map(formatRecoleccion), total: rows.length });
  } catch (err) {
    next(err);
  }
}
