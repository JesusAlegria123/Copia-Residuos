import jwt from 'jsonwebtoken';
import { config } from '../config/env.js';
import { error } from '../utils/response.js';

export function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return error(res, 'TOKEN_INVALID', 'Token inválido. Por favor, inicia sesión nuevamente.', 401);
  }

  const token = authHeader.slice(7);

  try {
    const payload = jwt.verify(token, config.jwt.secret);

    if (payload.type !== 'access') {
      return error(res, 'TOKEN_INVALID', 'Token inválido. Por favor, inicia sesión nuevamente.', 401);
    }

    req.user = {
      id: payload.sub,
      email: payload.email,
      rol: payload.rol,
    };

    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return error(res, 'TOKEN_EXPIRED', 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.', 403);
    }
    return error(res, 'TOKEN_INVALID', 'Token inválido. Por favor, inicia sesión nuevamente.', 401);
  }
}

export function requireAdmin(req, res, next) {
  if (req.user?.rol !== 'Administrador') {
    return error(res, 'FORBIDDEN', 'Esta acción no está permitida.', 403);
  }
  next();
}

/** Autenticación opcional: adjunta req.user si hay token válido, sin bloquear. */
export function optionalAuthenticate(req, _res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next();
  }

  const token = authHeader.slice(7);

  try {
    const payload = jwt.verify(token, config.jwt.secret);
    if (payload.type === 'access') {
      req.user = {
        id: payload.sub,
        email: payload.email,
        rol: payload.rol,
      };
    }
  } catch {
    // Token inválido en reporte ciudadano: continuar sin usuario asociado
  }

  next();
}
