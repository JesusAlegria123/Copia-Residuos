import { getSupabase } from '../config/supabase.js';
import { hashPassword, verifyPassword } from '../utils/password.js';
import {
  generateAccessToken,
  generateRefreshToken,
  getRefreshTokenExpiry,
  hashToken,
  validation,
  verifyToken,
} from '../utils/jwt.js';

function authError(message, code) {
  const err = new Error(message);
  err.code = code;
  return err;
}

export async function logLoginAttempt({ email, success, userId, ipAddress, userAgent, errorMessage }) {
  try {
    const supabase = getSupabase();
    await supabase.from('login_audit').insert({
      email,
      user_id: userId ?? null,
      ip_address: ipAddress ?? null,
      user_agent: userAgent ?? null,
      success,
      error_message: errorMessage ?? null,
    });
  } catch (err) {
    console.error('[audit] Error registrando login:', err.message);
  }
}

async function getUserByEmail(email) {
  const supabase = getSupabase();
  const { data, error: dbError } = await supabase
    .from('users')
    .select('*')
    .eq('email', email)
    .maybeSingle();

  if (dbError) throw dbError;
  return data;
}

async function getUserById(userId) {
  const supabase = getSupabase();
  const { data, error: dbError } = await supabase
    .from('users')
    .select('*')
    .eq('id', userId)
    .maybeSingle();

  if (dbError) throw dbError;
  return data;
}

async function saveRefreshToken(userId, refreshToken) {
  const supabase = getSupabase();
  const tokenHash = hashToken(refreshToken);
  const expiresAt = getRefreshTokenExpiry();

  const { error: dbError } = await supabase.from('refresh_tokens').insert({
    user_id: userId,
    token_hash: tokenHash,
    expires_at: expiresAt.toISOString(),
  });

  if (dbError) throw dbError;
  return tokenHash;
}

async function updateLastLogin(userId) {
  const supabase = getSupabase();
  await supabase
    .from('users')
    .update({ ultimo_login: new Date().toISOString(), updated_at: new Date().toISOString() })
    .eq('id', userId);
}

export async function signup({ email, password, nombre, rol = 'Usuario' }) {
  const validatedEmail = validation.validateEmail(email);
  validation.validatePassword(password);
  const validatedName = validation.validateName(nombre);
  const validatedRole = validation.validateRole(rol);

  const existing = await getUserByEmail(validatedEmail);
  if (existing) {
    throw authError('Este email ya está registrado. Intenta iniciar sesión.', 'EMAIL_EXISTS');
  }

  const passwordHash = await hashPassword(password);
  const supabase = getSupabase();

  const { data, error: dbError } = await supabase
    .from('users')
    .insert({
      email: validatedEmail,
      password_hash: passwordHash,
      nombre: validatedName,
      rol: validatedRole,
      activo: true,
    })
    .select()
    .single();

  if (dbError) {
    if (dbError.code === '23505') {
      throw authError('Este email ya está registrado. Intenta iniciar sesión.', 'EMAIL_EXISTS');
    }
    throw dbError;
  }

  return data;
}

export async function login({ email, password, ipAddress, userAgent }) {
  const validatedEmail = validation.validateEmail(email);

  if (!password || !password.trim()) {
    throw validationError('La contraseña no puede estar vacía.', 'PASSWORD_EMPTY');
  }

  const user = await getUserByEmail(validatedEmail);

  if (!user) {
    await logLoginAttempt({
      email: validatedEmail,
      success: false,
      ipAddress,
      userAgent,
      errorMessage: 'Usuario no encontrado',
    });
    throw authError(
      'Credenciales inválidas. Por favor, verifica tu email y contraseña.',
      'INVALID_CREDENTIALS'
    );
  }

  if (!user.activo) {
    await logLoginAttempt({
      email: validatedEmail,
      success: false,
      userId: user.id,
      ipAddress,
      userAgent,
      errorMessage: 'Usuario inactivo',
    });
    throw authError('Tu cuenta ha sido desactivada. Contacta al administrador.', 'USER_INACTIVE');
  }

  const passwordValid = await verifyPassword(password, user.password_hash);

  if (!passwordValid) {
    await logLoginAttempt({
      email: validatedEmail,
      success: false,
      userId: user.id,
      ipAddress,
      userAgent,
      errorMessage: 'Contraseña incorrecta',
    });
    throw authError(
      'Credenciales inválidas. Por favor, verifica tu email y contraseña.',
      'INVALID_CREDENTIALS'
    );
  }

  const accessToken = generateAccessToken({
    userId: user.id,
    email: user.email,
    rol: user.rol,
  });

  const refreshToken = generateRefreshToken({ userId: user.id });
  await saveRefreshToken(user.id, refreshToken);
  await updateLastLogin(user.id);

  await logLoginAttempt({
    email: validatedEmail,
    success: true,
    userId: user.id,
    ipAddress,
    userAgent,
  });

  return { user, accessToken, refreshToken };
}

export async function refreshAccessToken(refreshToken) {
  if (!refreshToken) {
    throw authError('No se pudo refrescar la sesión. Por favor, inicia sesión nuevamente.', 'REFRESH_FAILED');
  }

  let payload;
  try {
    payload = verifyToken(refreshToken);
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      throw authError('Tu sesión ha expirado. Por favor, inicia sesión nuevamente.', 'TOKEN_EXPIRED');
    }
    throw authError('Token inválido. Por favor, inicia sesión nuevamente.', 'TOKEN_INVALID');
  }

  if (payload.type !== 'refresh') {
    throw authError('Token inválido. Por favor, inicia sesión nuevamente.', 'TOKEN_INVALID');
  }

  const tokenHash = hashToken(refreshToken);
  const supabase = getSupabase();

  const { data: storedToken, error: tokenError } = await supabase
    .from('refresh_tokens')
    .select('*')
    .eq('user_id', payload.sub)
    .eq('token_hash', tokenHash)
    .eq('revoked', false)
    .gt('expires_at', new Date().toISOString())
    .maybeSingle();

  if (tokenError) throw tokenError;

  if (!storedToken) {
    throw authError('No se pudo refrescar la sesión. Por favor, inicia sesión nuevamente.', 'REFRESH_FAILED');
  }

  const user = await getUserById(payload.sub);
  if (!user || !user.activo) {
    throw authError('No se pudo refrescar la sesión. Por favor, inicia sesión nuevamente.', 'REFRESH_FAILED');
  }

  const accessToken = generateAccessToken({
    userId: user.id,
    email: user.email,
    rol: user.rol,
  });

  return { accessToken, expiresIn: 900 };
}

export async function logout(userId, refreshToken) {
  const supabase = getSupabase();

  if (refreshToken) {
    const tokenHash = hashToken(refreshToken);
    await supabase
      .from('refresh_tokens')
      .update({ revoked: true })
      .eq('user_id', userId)
      .eq('token_hash', tokenHash);
  } else {
    await supabase
      .from('refresh_tokens')
      .update({ revoked: true })
      .eq('user_id', userId)
      .eq('revoked', false);
  }
}

export async function getCurrentUser(userId) {
  const user = await getUserById(userId);
  if (!user) {
    throw authError('El usuario no fue encontrado.', 'USER_NOT_FOUND');
  }
  return user;
}

function validationError(message, code) {
  const err = new Error(message);
  err.code = code;
  err.statusCode = 400;
  err.isValidation = true;
  return err;
}
