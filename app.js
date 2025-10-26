const express = require('express');
const { loadEnv } = require('./src/config/env');
const errorMiddleware = require('./src/middlewares/error.middleware');
const routes = require('./src/routes');


loadEnv(); // loads .env

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// mount all routes
app.use('/', routes);

// global error handler (kept last)
app.use(errorMiddleware);

app.listen(PORT,()=>{
      console.log('API running on http//localhost"${PORT}');
});