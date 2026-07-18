import { Router } from 'express';
import * as dataController from '../controllers/data.controller.js';
import { authenticate, requireAdmin } from '../middleware/auth.middleware.js';

const router = Router();

// Rutas públicas (sin autenticación)
router.get('/roles', dataController.getRoles);
router.get('/zonas', dataController.getZonas);
router.get('/rutas', dataController.getRutas);
router.get('/rutas/:id', dataController.getRuta);

// Rutas protegidas (requieren token)
router.get('/usuarios', authenticate, requireAdmin, dataController.getUsuarios);
router.get('/usuarios/:id', authenticate, requireAdmin, dataController.getUsuario);
router.patch('/usuarios/:id', authenticate, requireAdmin, dataController.updateUsuario);
router.patch('/usuarios/:id/disable', authenticate, requireAdmin, dataController.disableUsuario);
router.patch('/usuarios/:id/enable', authenticate, requireAdmin, dataController.enableUsuario);

router.get('/users', authenticate, requireAdmin, dataController.getAuthUsers);
router.patch('/users/:id', authenticate, requireAdmin, dataController.updateAuthUser);
router.patch('/users/:id/status', authenticate, requireAdmin, dataController.updateAuthUserStatus);

export default router;
