import * as estadisticasService from '../services/estadisticas.service.js';
import { success } from '../utils/response.js';

export async function getUsuarios(req, res, next) {
  try {
    const data = await estadisticasService.getEstadisticasUsuarios();
    return success(res, data);
  } catch (err) {
    next(err);
  }
}

export async function getRutas(req, res, next) {
  try {
    const data = await estadisticasService.getEstadisticasRutas();
    return success(res, data);
  } catch (err) {
    next(err);
  }
}

export async function getResiduos(req, res, next) {
  try {
    const { desde, hasta } = req.query;
    const data = await estadisticasService.getEstadisticasResiduos({ desde, hasta });
    return success(res, data);
  } catch (err) {
    next(err);
  }
}
