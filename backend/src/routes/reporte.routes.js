import { Router } from 'express';
import * as reporteController from '../controllers/reporte.controller.js';
import { uploadReporteFoto, handleMulterError } from '../middleware/upload.middleware.js';
import { optionalAuthenticate, authenticate, requireAdmin } from '../middleware/auth.middleware.js';

const router = Router();

router.get('/distritos', reporteController.getDistritos);
router.get('/', reporteController.listReportes);
router.get('/:id', reporteController.getReporte);

router.post(
  '/',
  optionalAuthenticate,
  (req, res, next) => {
    uploadReporteFoto(req, res, (err) => {
      if (err) return handleMulterError(err, req, res, next);
      next();
    });
  },
  reporteController.createReporte
);

router.patch('/:id/estado', authenticate, requireAdmin, reporteController.updateEstadoReporte);

export default router;
