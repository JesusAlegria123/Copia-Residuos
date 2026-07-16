const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const env = require('./config/env');
const apiRoutes = require('./routes');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

const app = express();

app.use(helmet());
app.use(
  cors({
    origin: env.corsOrigins,
  })
);
app.use(express.json());

app.get('/health', (req, res) => {
  res.status(200).json({ success: true, message: 'API de Residuos UNSAAC operativa.' });
});

app.use('/api', apiRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
