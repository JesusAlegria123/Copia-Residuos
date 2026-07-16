import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import { config } from '../config/env.js';

const VALID_ROLES = ['Administrador', 'Usuario', 'Invitado', 'Municipalidad'];

export function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

export function generateAccessToken({ userId, email, rol }) {
  return jwt.sign(
    { sub: userId, email, rol, type: 'access' },
    config.jwt.secret,
    { expiresIn: config.jwt.accessExpiresIn }
  );
}

export function generateRefreshToken({ userId }) {
  return jwt.sign(
    { sub: userId, type: 'refresh' },
    config.jwt.secret,
    { expiresIn: config.jwt.refreshExpiresIn }
  );
}

export function verifyToken(token) {
  return jwt.verify(token, config.jwt.secret);
}

export function getRefreshTokenExpiry() {
  const expiresIn = String(config.jwt.refreshExpiresIn);
  const expiresAt = new Date();
  const value = parseInt(expiresIn, 10) || 7;

  if (expiresIn.endsWith('d')) {
    expiresAt.setDate(expiresAt.getDate() + value);
  } else if (expiresIn.endsWith('h')) {
    expiresAt.setHours(expiresAt.getHours() + value);
  } else if (expiresIn.endsWith('m')) {
    expiresAt.setMinutes(expiresAt.getMinutes() + value);
  } else {
    expiresAt.setDate(expiresAt.getDate() + 7);
  }

  return expiresAt;
}

export const validation = {
  emailPattern: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,

  validateEmail(email) {
    if (!email || typeof email !== 'string' || !email.trim()) {
      throw validationError('El email no puede estar vacío.', 'EMAIL_EMPTY');
    }
    const normalized = email.trim().toLowerCase();
    if (!this.emailPattern.test(normalized)) {
      throw validationError('El formato del email no es válido.', 'INVALID_EMAIL');
    }
    return normalized;
  },

  validatePassword(password) {
    if (!password || typeof password !== 'string') {
      throw validationError('La contraseña no puede estar vacía.', 'PASSWORD_EMPTY');
    }
    if (password.length < 8) {
      throw validationError('La contraseña debe tener al menos 8 caracteres.', 'PASSWORD_TOO_SHORT');
    }
    if (!/[A-Z]/.test(password)) {
      throw validationError('La contraseña debe contener al menos una mayúscula.', 'PASSWORD_NO_UPPERCASE');
    }
    if (!/[a-z]/.test(password)) {
      throw validationError('La contraseña debe contener al menos una minúscula.', 'PASSWORD_NO_LOWERCASE');
    }
    if (!/[0-9]/.test(password)) {
      throw validationError('La contraseña debe contener al menos un número.', 'PASSWORD_NO_NUMBER');
    }
    if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
      throw validationError(
        'La contraseña debe contener al menos un carácter especial (!@#$%^&*).',
        'PASSWORD_NO_SPECIAL_CHAR'
      );
    }
    return password;
  },

  validateName(name) {
    if (!name || typeof name !== 'string' || !name.trim()) {
      throw validationError('Nombre es requerido.', 'FIELD_REQUIRED');
    }
    const trimmed = name.trim();
    if (trimmed.length < 3) {
      throw validationError('El nombre debe tener al menos 3 caracteres.', 'NAME_TOO_SHORT');
    }
    if (trimmed.length > 100) {
      throw validationError('El nombre no puede exceder 100 caracteres.', 'NAME_TOO_LONG');
    }
    if (!/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-.]{3,}$/.test(trimmed)) {
      throw validationError('Nombre contiene caracteres inválidos.', 'INVALID_INPUT');
    }
    return trimmed;
  },

  validateRole(role) {
    if (!role || typeof role !== 'string') {
      throw validationError('Rol es requerido.', 'FIELD_REQUIRED');
    }
    if (!VALID_ROLES.includes(role)) {
      throw validationError('Rol no válido.', 'INVALID_ROLE');
    }
    return role;
  },
};

function validationError(message, code) {
  const err = new Error(message);
  err.code = code;
  err.statusCode = 400;
  err.isValidation = true;
  return err;
}
