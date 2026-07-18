import { Router } from 'express';
import * as recoleccionController from '../controllers/recoleccion.controller.js';
import { authenticate, requireAdmin } from '../middleware/auth.middleware.js';

const router = Router();

// Registrar y consultar recolecciones requiere estar autenticado
// (lo hace el recolector/admin desde la unidad o el panel).
router.post('/', authenticate, recoleccionController.createRecoleccion);
router.get('/', authenticate, requireAdmin, recoleccionController.listRecolecciones);

export default router;
