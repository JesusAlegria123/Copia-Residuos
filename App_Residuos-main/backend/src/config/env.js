require('dotenv').config();

const required = [
  'SUPABASE_URL',
  'SUPABASE_SERVICE_ROLE_KEY',
  'JWT_ACCESS_SECRET',
  'JWT_REFRESH_SECRET',
];

const missing = required.filter((key) => !process.env[key]);
if (missing.length > 0) {
  // eslint-disable-next-line no-console
  console.error(
    `❌ Faltan variables de entorno requeridas: ${missing.join(', ')}\n` +
      'Copia .env.example a .env y complétalo antes de iniciar el servidor.'
  );
  process.exit(1);
}

module.exports = {
  port: process.env.PORT || 8080,
  nodeEnv: process.env.NODE_ENV || 'development',
  supabaseUrl: process.env.SUPABASE_URL,
  supabaseServiceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY,
  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET,
    refreshSecret: process.env.JWT_REFRESH_SECRET,
    accessExpiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  },
  corsOrigins:
    process.env.CORS_ORIGINS === '*'
      ? '*'
      : (process.env.CORS_ORIGINS || '').split(',').map((o) => o.trim()),
};
