import { error } from '../utils/response.js';

export function notFoundHandler(req, res) {
  return error(res, 'NOT_FOUND', 'El recurso no fue encontrado.', 404);
}

export function errorHandler(err, req, res, _next) {
  console.error(`[error] ${req.method} ${req.path}:`, err);

  if (err.isValidation) {
    return error(res, err.code || 'BAD_REQUEST', err.message, err.statusCode || 400);
  }

  if (err.code === 'INVALID_CREDENTIALS') {
    return error(res, 'INVALID_CREDENTIALS', err.message, 401);
  }

  if (err.code === 'EMAIL_EXISTS') {
    return error(res, 'EMAIL_EXISTS', err.message, 400);
  }

  if (err.code === 'USER_INACTIVE') {
    return error(res, 'USER_INACTIVE', err.message, 403);
  }

  if (err.code === 'TOKEN_EXPIRED') {
    return error(res, 'TOKEN_EXPIRED', err.message, 403);
  }

  if (err.code === 'TOKEN_INVALID' || err.code === 'REFRESH_FAILED') {
    return error(res, err.code, err.message, 401);
  }

  if (err.code === 'NOT_FOUND') {
    return error(res, 'NOT_FOUND', err.message, 404);
  }

  if (err.code === 'FORBIDDEN') {
    return error(res, 'FORBIDDEN', err.message, 403);
  }

  // Fallback genérico: cualquier error de negocio ya trae su propio
  // statusCode/code (ej. INVALID_ESTADO, CONFLICT, BAD_REQUEST) y no
  // necesita whitelist explícita para no caer sistemáticamente en 500.
  if (err.statusCode && err.statusCode < 500) {
    return error(res, err.code || 'BAD_REQUEST', err.message, err.statusCode);
  }

  return error(
    res,
    'SERVER_ERROR',
    'Error en el servidor. Por favor, intenta de nuevo más tarde.',
    500
  );
}
