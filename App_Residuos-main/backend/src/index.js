import app from './app.js';
import { config } from './config/env.js';

app.listen(config.port, () => {
  console.log(`Servidor escuchando en http://localhost:${config.port}`);
  console.log(`Auth API: http://localhost:${config.port}/api/auth`);
  console.log(`Entorno: ${config.nodeEnv}`);
});
