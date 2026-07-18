import { Router } from 'express';
import * as unidadController from '../controllers/unidad.controller.js';
import { authenticate, requireAdmin } from '../middleware/auth.middleware.js';

const router = Router();

// Lectura: cualquier usuario autenticado puede ver unidades y su ubicación
// (la app de monitoreo la usan tanto admins como usuarios/recolectores).
router.get('/', authenticate, unidadController.listUnidades);
router.get('/:id', authenticate, unidadController.getUnidad);
router.get('/:id/ubicacion', authenticate, unidadController.getUltimaUbicacion);
router.get('/:id/historial', authenticate, unidadController.getHistorial);

// Reportar posición: cualquier usuario autenticado (ej. el dispositivo del
// recolector). Si luego se agrega un rol "Recolector" propio, restringir aquí.
router.post('/:id/ubicacion', authenticate, unidadController.registrarUbicacion);

// Administración de la flota: solo admins
router.post('/', authenticate, requireAdmin, unidadController.createUnidad);
router.patch('/:id', authenticate, requireAdmin, unidadController.updateUnidad);
router.patch('/:id/estado', authenticate, requireAdmin, unidadController.updateUnidadEstado);

export default router;
