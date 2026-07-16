const app = require('./app');
const env = require('./config/env');

app.listen(env.port, () => {
  // eslint-disable-next-line no-console
  console.log(`🚀 Servidor escuchando en http://localhost:${env.port}`);
  // eslint-disable-next-line no-console
  console.log(`   Entorno: ${env.nodeEnv}`);
});
