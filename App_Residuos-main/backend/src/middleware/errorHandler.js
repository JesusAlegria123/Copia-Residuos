const AppError = require('../utils/AppError');

// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, next) {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      error: { code: err.code, message: err.message },
    });
  }

  // Error no controlado: nunca exponer detalles internos al cliente.
  // eslint-disable-next-line no-console
  console.error('Unhandled error:', err);
  return res.status(500).json({
    success: false,
    error: {
      code: 'SERVER_ERROR',
      message: 'Error en el servidor. Por favor, intenta de nuevo más tarde.',
    },
  });
}

function notFoundHandler(req, res) {
  res.status(404).json({
    success: false,
    error: { code: 'NOT_FOUND', message: 'Recurso no encontrado.' },
  });
}

module.exports = { errorHandler, notFoundHandler };
