const supabase = require('../config/supabase');
const AppError = require('../utils/AppError');

async function findUserByEmail(email) {
  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('email', email)
    .maybeSingle();

  if (error) throw new AppError(500, 'SERVER_ERROR', 'Error al consultar el usuario.');
  return data;
}

async function findUserById(id) {
  const { data, error } = await supabase
    .from('users')
    .select('id, email, nombre, rol, activo, created_at, ultimo_login')
    .eq('id', id)
    .maybeSingle();

  if (error) throw new AppError(500, 'SERVER_ERROR', 'Error al consultar el usuario.');
  return data;
}

async function createUser({ email, passwordHash, nombre, rol }) {
  const { data, error } = await supabase
    .from('users')
    .insert({
      email,
      password_hash: passwordHash,
      nombre,
      rol: rol || 'Usuario',
    })
    .select('id, email, nombre, rol, activo, created_at')
    .single();

  if (error) {
    if (error.code === '23505') {
      throw new AppError(400, 'EMAIL_EXISTS', 'Este email ya está registrado. Intenta iniciar sesión.');
    }
    throw new AppError(500, 'SERVER_ERROR', 'Error al crear el usuario.');
  }
  return data;
}

async function updateLastLogin(userId) {
  await supabase.from('users').update({ ultimo_login: new Date().toISOString() }).eq('id', userId);
}

async function storeRefreshToken({ userId, tokenHash, expiresAt }) {
  const { error } = await supabase.from('refresh_tokens').insert({
    user_id: userId,
    token_hash: tokenHash,
    expires_at: expiresAt,
  });
  if (error) throw new AppError(500, 'SERVER_ERROR', 'Error al guardar la sesión.');
}

async function findValidRefreshToken({ userId, tokenHash }) {
  const { data, error } = await supabase
    .from('refresh_tokens')
    .select('*')
    .eq('user_id', userId)
    .eq('token_hash', tokenHash)
    .eq('revoked', false)
    .gt('expires_at', new Date().toISOString())
    .maybeSingle();

  if (error) throw new AppError(500, 'SERVER_ERROR', 'Error al validar la sesión.');
  return data;
}

async function revokeRefreshToken({ userId, tokenHash }) {
  await supabase
    .from('refresh_tokens')
    .update({ revoked: true })
    .eq('user_id', userId)
    .eq('token_hash', tokenHash);
}

async function revokeAllRefreshTokens(userId) {
  await supabase.from('refresh_tokens').update({ revoked: true }).eq('user_id', userId);
}

async function recordLoginAttempt({ userId, email, ipAddress, userAgent, success, errorMessage }) {
  await supabase.from('login_audit').insert({
    user_id: userId || null,
    email,
    ip_address: ipAddress,
    user_agent: userAgent,
    success,
    error_message: errorMessage || null,
  });
}

module.exports = {
  findUserByEmail,
  findUserById,
  createUser,
  updateLastLogin,
  storeRefreshToken,
  findValidRefreshToken,
  revokeRefreshToken,
  revokeAllRefreshTokens,
  recordLoginAttempt,
};
