const { PrismaClient } = require('@prisma/client');

const globalForPrisma = globalThis;
const prisma = globalForPrisma.prisma || new PrismaClient();

if(process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

module.exports = {prisma};

// the singleton reuses one isntance and creating the new PrismaClient() on each save can exhaust DB connections 

