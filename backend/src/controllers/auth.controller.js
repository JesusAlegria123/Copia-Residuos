import { config } from '../config/env.js';
import * as authService from '../services/auth.service.js';
import { formatUser, success, successMessage } from '../utils/response.js';

function getClientMeta(req) {
  return {
    ipAddress: req.ip || req.headers['x-forwarded-for'] || null,
    userAgent: req.headers['user-agent'] || null,
  };
}

export async function signup(req, res, next) {
  try {
    const { email, password, nombre, rol } = req.body;
    const user = await authService.signup({ email, password, nombre, rol });

    return success(
      res,
      { user: formatUser(user) },
      201
    );
  } catch (err) {
    next(err);
  }
}

export async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    const meta = getClientMeta(req);
    const { user, accessToken, refreshToken } = await authService.login({
      email,
      password,
      ...meta,
    });

    return success(res, {
      user: formatUser(user),
      accessToken,
      refreshToken,
      expiresIn: config.jwt.accessExpiresSeconds,
    });
  } catch (err) {
    next(err);
  }
}

export async function refresh(req, res, next) {
  try {
    const { refreshToken } = req.body;
    const result = await authService.refreshAccessToken(refreshToken);
    return success(res, result);
  } catch (err) {
    next(err);
  }
}

export async function logout(req, res, next) {
  try {
    const { refreshToken } = req.body ?? {};
    await authService.logout(req.user.id, refreshToken);
    return successMessage(res, 'Logout exitoso. Sesión cerrada.');
  } catch (err) {
    next(err);
  }
}

export async function me(req, res, next) {
  try {
    const user = await authService.getCurrentUser(req.user.id);
    return success(res, formatUser(user));
  } catch (err) {
    next(err);
  }
}
