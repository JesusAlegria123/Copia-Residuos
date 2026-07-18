import { Router } from 'express';
import * as estadisticasController from '../controllers/estadisticas.controller.js';
import { authenticate, requireAdmin } from '../middleware/auth.middleware.js';

const router = Router();

router.get('/usuarios', authenticate, requireAdmin, estadisticasController.getUsuarios);
router.get('/rutas', authenticate, requireAdmin, estadisticasController.getRutas);
router.get('/residuos', authenticate, requireAdmin, estadisticasController.getResiduos);

export default router;
