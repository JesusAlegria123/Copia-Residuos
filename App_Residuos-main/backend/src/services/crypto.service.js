const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const env = require('../config/env');

const BCRYPT_ROUNDS = 10;

async function hashPassword(plainPassword) {
  return bcrypt.hash(plainPassword, BCRYPT_ROUNDS);
}

async function verifyPassword(plainPassword, hash) {
  return bcrypt.compare(plainPassword, hash);
}

function signAccessToken(user) {
  return jwt.sign(
    {
      sub: user.id,
      email: user.email,
      rol: user.rol,
      type: 'access',
    },
    env.jwt.accessSecret,
    { expiresIn: env.jwt.accessExpiresIn }
  );
}

function signRefreshToken(user) {
  return jwt.sign(
    {
      sub: user.id,
      type: 'refresh',
    },
    env.jwt.refreshSecret,
    { expiresIn: env.jwt.refreshExpiresIn }
  );
}

function verifyAccessToken(token) {
  return jwt.verify(token, env.jwt.accessSecret);
}

function verifyRefreshToken(token) {
  return jwt.verify(token, env.jwt.refreshSecret);
}

// El refresh token se guarda hasheado (SHA256) en la BD, nunca en texto plano.
function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

// "expiresIn" del access token en segundos, para devolverlo en la respuesta.
function accessTokenExpiresInSeconds() {
  const match = /^(\d+)([smhd])$/.exec(env.jwt.accessExpiresIn);
  if (!match) return 900; // fallback: 15 minutos
  const value = Number(match[1]);
  const unit = match[2];
  const multipliers = { s: 1, m: 60, h: 3600, d: 86400 };
  return value * multipliers[unit];
}

module.exports = {
  hashPassword,
  verifyPassword,
  signAccessToken,
  signRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  hashToken,
  accessTokenExpiresInSeconds,
};
