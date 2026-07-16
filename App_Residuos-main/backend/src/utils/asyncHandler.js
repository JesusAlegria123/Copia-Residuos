// Envuelve controladores async para que cualquier error caiga
// automáticamente en el errorHandler central, sin try/catch repetido.
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = asyncHandler;
