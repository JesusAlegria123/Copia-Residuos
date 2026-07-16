const { Router } = require('express');
const rateLimit = require('express-rate-limit');
const authController = require('../controllers/auth.controller');
const asyncHandler = require('../utils/asyncHandler');
const { requireAuth } = require('../middleware/auth.middleware');

const router = Router();

// Límite estricto en login/signup para mitigar fuerza bruta.
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: { code: 'TOO_MANY_REQUESTS', message: 'Demasiados intentos. Intenta de nuevo más tarde.' },
  },
});

router.post('/signup', authLimiter, asyncHandler(authController.signup));
router.post('/login', authLimiter, asyncHandler(authController.login));
router.post('/refresh', asyncHandler(authController.refresh));
router.post('/logout', requireAuth, asyncHandler(authController.logout));
router.get('/me', requireAuth, asyncHandler(authController.me));

module.exports = router;
