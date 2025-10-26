src/
  routes/        = URLs only. Maps HTTP paths to controllers. (no business logic)
  controllers/   = Request/response orchestration. Validates input, calls services.
  services/      = Business logic. Talks to DB layer (Prisma) and other services.
  middlewares/   = Cross-cutting concerns (errors, auth, validation, logging).
  utils/         = Helpers (logger, prisma client singleton, formatters).
  config/        = App/Env/Config loading. Zero business logic here.
prisma/          = Prisma schema, migrations, DB artifacts.
app.js           = App bootstrap. Mounts routes & middlewares, starts server.
