const cryptoService = require('../services/crypto.service');
const AppError = require('../utils/AppError');

function requireAuth(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return next(new AppError(401, 'UNAUTHORIZED', 'Token de acceso requerido.'));
  }

  const token = header.slice('Bearer '.length).trim();

  try {
    const payload = cryptoService.verifyAccessToken(token);
    if (payload.type !== 'access') {
      return next(new AppError(401, 'INVALID_TOKEN', 'Tipo de token inválido.'));
    }
    req.user = { id: payload.sub, email: payload.email, rol: payload.rol };
    req.accessToken = token;
    return next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return next(new AppError(403, 'TOKEN_EXPIRED', 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'));
    }
    return next(new AppError(401, 'INVALID_TOKEN', 'Token inválido.'));
  }
}

module.exports = { requireAuth };
