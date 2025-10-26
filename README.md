Backend boiler plate skeleton with the frameworks
1. Runtime -> Node.js(v20+)
2. Framework-> Express.js
3. ORM ->Prisma
4. Database-> PostgreSQL via Docker compose
5. Version control Git
6. API Testing Thunder Clien/Rest Client

---

##  Project Structure
src/
├── config/ # environment & app config
├── controllers/ # request/response logic
├── middlewares/ # cross-cutting middleware (error handling, validation)
├── routes/ # all route definitions
├── services/ # business logic
├── utils/ # helper functions (Prisma client, logger, etc.)
prisma/
├── schema.prisma # Prisma schema & data models



## Setup Instructions

### Clone this repository

git clone https://github.com/<your-username>/Oct25shaaz.git
cd Oct25shaaz


npm install
docker compose up -d
npx prisma generate
npx prisma migrate dev --name init
npm run dev

The server runs by default at:
http://localhost:3000