import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import path from 'path';
import { fileURLToPath } from 'url';
import { config } from './config/env.js';
import authRoutes from './routes/auth.routes.js';
import dataRoutes from './routes/data.routes.js';
import reporteRoutes from './routes/reporte.routes.js';
import unidadRoutes from './routes/unidad.routes.js';
import estadisticasRoutes from './routes/estadisticas.routes.js';
import recoleccionRoutes from './routes/recoleccion.routes.js';
import { errorHandler, notFoundHandler } from './middleware/error.middleware.js';
import { generalLimiter } from './middleware/rateLimiter.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const app = express();

app.set('trust proxy', 1);

app.use(
  helmet({
    crossOriginResourcePolicy: { policy: 'cross-origin' },
  })
);
app.use(
  cors({
    origin: config.cors.origin === '*' ? true : config.cors.origin.split(','),
    credentials: true,
  })
);
app.use(express.json({ limit: '1mb' }));
app.use(generalLimiter);

app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

app.get('/health', (_req, res) => {
  res.json({
    success: true,
    data: {
      status: 'ok',
      service: 'app-residuos-backend',
      timestamp: new Date().toISOString(),
    },
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/reportes', reporteRoutes);
app.use('/api/unidades', unidadRoutes);
app.use('/api/estadisticas', estadisticasRoutes);
app.use('/api/recolecciones', recoleccionRoutes);
app.use('/api', dataRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

export default app;
