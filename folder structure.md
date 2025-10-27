src/
  routes/        = URLs only. Maps HTTP paths to controllers. (no business logic)
  controllers/   = Request/response orchestration. Validates input, calls services.
  services/      = Business logic. Talks to DB layer (Prisma) and other services.
  middlewares/   = Cross-cutting concerns (errors, auth, validation, logging).
  utils/         = Helpers (logger, prisma client singleton, formatters).
  config/        = App/Env/Config loading. Zero business logic here.
prisma/          = Prisma schema, migrations, DB artifacts.
app.js           = App bootstrap. Mounts routes & middlewares, starts server.


the correct order of operation is the the following 

First make sure the .env file exists with the correct DATABASE_URL
Then Start the database : docker-compose up -e
Then Generate the Prisma client npm run db:migrate
Then run the migrations npm run db:migrate
Finally Install npm packages : npm install

so be cautious about npm run db:generate!

--------> You will need the .env file as the Prism client will be  needing the database url Other wise prisma wont connect to generate the client

# 1. Create .env file (see above)
# 2. Start database
docker-compose up -d
# 3. Install packages
npm install
# 4. Generate Prisma client
npm run db:generate
# 5. Run migrations
npm run db:migrate