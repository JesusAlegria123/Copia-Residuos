import dotenv from 'dotenv';

dotenv.config();

const required = ['SUPABASE_URL', 'SUPABASE_SERVICE_ROLE_KEY', 'JWT_SECRET'];

for (const key of required) {
  if (!process.env[key]) {
    console.warn(`[config] Variable de entorno faltante: ${key}`);
  }
}

export const config = {
  port: parseInt(process.env.PORT || '8080', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  supabase: {
    url: process.env.SUPABASE_URL,
    serviceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY,
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'your-super-secret-key-change-in-production',
    accessExpiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
    accessExpiresSeconds: 900,
  },
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
  },
};
