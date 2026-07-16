const AppError = require('../utils/AppError');

// RFC 5322 simplificado, suficiente para validación práctica de formulario.
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const NAME_REGEX = /^[A-Za-zÀ-ÿ\u00f1\u00d1\s'-]{3,100}$/;

function validateEmail(email) {
  if (!email || typeof email !== 'string') {
    throw new AppError(400, 'INVALID_EMAIL', 'El email es requerido.');
  }
  if (!EMAIL_REGEX.test(email)) {
    throw new AppError(400, 'INVALID_EMAIL', 'El formato del email no es válido.');
  }
}

function validatePassword(password) {
  if (!password || typeof password !== 'string') {
    throw new AppError(400, 'WEAK_PASSWORD', 'La contraseña es requerida.');
  }
  const checks = [
    [/.{8,}/, 'mínimo 8 caracteres'],
    [/[A-Z]/, 'una letra mayúscula'],
    [/[a-z]/, 'una letra minúscula'],
    [/[0-9]/, 'un número'],
    [/[!@#$%^&*]/, 'un carácter especial (!@#$%^&*)'],
  ];
  const failed = checks.filter(([regex]) => !regex.test(password));
  if (failed.length > 0) {
    throw new AppError(
      400,
      'WEAK_PASSWORD',
      `La contraseña debe tener al menos: ${failed.map((f) => f[1]).join(', ')}.`
    );
  }
}

function validateName(nombre) {
  if (!nombre || typeof nombre !== 'string') {
    throw new AppError(400, 'INVALID_NAME', 'El nombre es requerido.');
  }
  if (!NAME_REGEX.test(nombre.trim())) {
    throw new AppError(
      400,
      'INVALID_NAME',
      'El nombre debe tener entre 3 y 100 caracteres, solo letras, espacios, acentos y guiones.'
    );
  }
}

module.exports = { validateEmail, validatePassword, validateName };
