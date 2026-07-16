import { Router } from 'express';
import * as dataController from '../controllers/data.controller.js';
import { authenticate, requireAdmin } from '../middleware/auth.middleware.js';

const router = Router();

router.use(authenticate);

router.get('/roles', dataController.getRoles);
router.get('/zonas', dataController.getZonas);
router.get('/rutas', dataController.getRutas);
router.get('/rutas/:id', dataController.getRuta);

router.get('/usuarios', requireAdmin, dataController.getUsuarios);
router.get('/usuarios/:id', requireAdmin, dataController.getUsuario);
router.patch('/usuarios/:id/disable', requireAdmin, dataController.disableUsuario);
router.patch('/usuarios/:id/enable', requireAdmin, dataController.enableUsuario);

router.get('/users', requireAdmin, dataController.getAuthUsers);
router.patch('/users/:id/status', requireAdmin, dataController.updateAuthUserStatus);

export default router;
