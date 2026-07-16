const userService = require('../services/user.service');
const cryptoService = require('../services/crypto.service');
const validationService = require('../services/validation.service');
const AppError = require('../utils/AppError');

function getClientInfo(req) {
  return {
    ipAddress: req.ip || req.headers['x-forwarded-for'] || 'unknown',
    userAgent: req.headers['user-agent'] || 'unknown',
  };
}

function toPublicUser(user) {
  return {
    id: user.id,
    email: user.email,
    nombre: user.nombre,
    rol: user.rol,
    activo: user.activo,
  };
}

// POST /api/auth/signup
async function signup(req, res) {
  const { email, password, nombre, rol } = req.body;

  validationService.validateEmail(email);
  validationService.validatePassword(password);
  validationService.validateName(nombre);

  const existing = await userService.findUserByEmail(email);
  if (existing) {
    throw new AppError(400, 'EMAIL_EXISTS', 'Este email ya está registrado. Intenta iniciar sesión.');
  }

  const passwordHash = await cryptoService.hashPassword(password);
  const user = await userService.createUser({ email, passwordHash, nombre, rol });

  res.status(201).json({
    success: true,
    data: { user: { ...user, createdAt: user.created_at } },
  });
}

// POST /api/auth/login
async function login(req, res) {
  const { email, password } = req.body;
  const { ipAddress, userAgent } = getClientInfo(req);

  validationService.validateEmail(email);
  if (!password) {
    throw new AppError(400, 'INVALID_CREDENTIALS', 'La contraseña es requerida.');
  }

  const user = await userService.findUserByEmail(email);

  if (!user || !user.activo) {
    await userService.recordLoginAttempt({
      email,
      ipAddress,
      userAgent,
      success: false,
      errorMessage: 'Usuario no encontrado o inactivo',
    });
    throw new AppError(401, 'INVALID_CREDENTIALS', 'Credenciales inválidas. Por favor, verifica tu email y contraseña.');
  }

  const passwordOk = await cryptoService.verifyPassword(password, user.password_hash);
  if (!passwordOk) {
    await userService.recordLoginAttempt({
      userId: user.id,
      email,
      ipAddress,
      userAgent,
      success: false,
      errorMessage: 'Contraseña incorrecta',
    });
    throw new AppError(401, 'INVALID_CREDENTIALS', 'Credenciales inválidas. Por favor, verifica tu email y contraseña.');
  }

  const accessToken = cryptoService.signAccessToken(user);
  const refreshToken = cryptoService.signRefreshToken(user);
  const refreshTokenHash = cryptoService.hashToken(refreshToken);
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();

  await userService.storeRefreshToken({ userId: user.id, tokenHash: refreshTokenHash, expiresAt });
  await userService.updateLastLogin(user.id);
  await userService.recordLoginAttempt({ userId: user.id, email, ipAddress, userAgent, success: true });

  res.status(200).json({
    success: true,
    data: {
      user: toPublicUser(user),
      accessToken,
      refreshToken,
      expiresIn: cryptoService.accessTokenExpiresInSeconds(),
    },
  });
}

// POST /api/auth/refresh
async function refresh(req, res) {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    throw new AppError(400, 'MISSING_REFRESH_TOKEN', 'El refresh token es requerido.');
  }

  let payload;
  try {
    payload = cryptoService.verifyRefreshToken(refreshToken);
  } catch (err) {
    const code = err.name === 'TokenExpiredError' ? 'TOKEN_EXPIRED' : 'INVALID_TOKEN';
    const message =
      code === 'TOKEN_EXPIRED'
        ? 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.'
        : 'Refresh token inválido.';
    throw new AppError(403, code, message);
  }

  const tokenHash = cryptoService.hashToken(refreshToken);
  const stored = await userService.findValidRefreshToken({ userId: payload.sub, tokenHash });
  if (!stored) {
    throw new AppError(403, 'TOKEN_EXPIRED', 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.');
  }

  const user = await userService.findUserById(payload.sub);
  if (!user || !user.activo) {
    throw new AppError(401, 'INVALID_CREDENTIALS', 'Usuario no encontrado o inactivo.');
  }

  const accessToken = cryptoService.signAccessToken({ id: user.id, email: user.email, rol: user.rol });

  res.status(200).json({
    success: true,
    data: { accessToken, expiresIn: cryptoService.accessTokenExpiresInSeconds() },
  });
}

// POST /api/auth/logout
async function logout(req, res) {
  const { refreshToken } = req.body;

  if (refreshToken) {
    const tokenHash = cryptoService.hashToken(refreshToken);
    await userService.revokeRefreshToken({ userId: req.user.id, tokenHash });
  } else {
    // Si no envían el refresh token, revocamos todas las sesiones del usuario por seguridad.
    await userService.revokeAllRefreshTokens(req.user.id);
  }

  res.status(200).json({ success: true, message: 'Logout exitoso. Sesión cerrada.' });
}

// GET /api/auth/me
async function me(req, res) {
  const user = await userService.findUserById(req.user.id);
  if (!user) {
    throw new AppError(404, 'USER_NOT_FOUND', 'Usuario no encontrado.');
  }

  res.status(200).json({
    success: true,
    data: {
      id: user.id,
      email: user.email,
      nombre: user.nombre,
      rol: user.rol,
      activo: user.activo,
      createdAt: user.created_at,
      ultimoLogin: user.ultimo_login,
    },
  });
}

module.exports = { signup, login, refresh, logout, me };
