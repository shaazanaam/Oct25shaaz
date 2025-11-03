Prisma would use the follwog to instantiate the connection with the data base :
            1. schema.prisma for the database schema and the configuration 
            2. env file for  the environment variables like the DATABASE_URL
            3.package.json scripts for the Prisma commands

            you cannot be making a separate file like the prisma.config.tx etc


             So the npx prisma generate  is one of  the most importain  of the Prisma commands.

             1. it reads the schema.prisma file and analyses for the database schema definition including the 
                         data model
                         the database provider
                         Generator configurator

             2. Generates the Prisma Client - Creates a fully typed TypeScript/JavaScript  client that provides 
                   type safe database querries
                   Auto completion in the IDE 
                   Methods for the CRUD operators 
                   Relationship handling 


            3 >   creates the  client in the node module -- the  generated client is typically installed as the @prisma/client and can be imported in  then code 

            in  our specific case it is the 
                        model User {
              id        Int      @id @default(autoincrement())
              email     String   @unique
              name      String?
              createdAt DateTime @default(now())
            }

            after running the prisma generate you use the generated client like the following 


            import {PrismaClient}  from @prisma/client

             const prisma = new PrismaCleint() 


             const users = await prisma.user.findMany()



             npx prisma migrate dev --name init 
              it would conenct to the  docker instance of the postgres and then writes a migration under the prisma/migrations/* and then creates the User table 

               You can also use the npx prisma studio to open the prisma studio to see the GUI



               npx prisma studio


               Opens a browser UI to view and then edit the User rows


## Part 4 — Prisma Client Singleton

Created a singleton pattern for Prisma Client to avoid multiple database connections:

**File:** `src/utils/prisma.js`

**Why we need a singleton:**
- Prevents creating multiple PrismaClient instances
- Avoids "too many connections" errors
- Improves performance by reusing connections
- Handles development vs production environments differently

**How to use it in your application:**
```javascript
const prisma = require('./src/utils/prisma');

// Now you can use prisma anywhere in your app
const users = await prisma.user.findMany();
```

**Key benefits:**
- Single database connection pool
- Better resource management
- Prevents connection leaks
- Development-friendly (survives hot reloads)



OLD vs the New prism.js and the services/prisma.service.ts

You have two different Prisma setups:


OLD (Express.js style): 

//Javascript , CommonJS require/module.exports

const {PrismaClient} = require('@prisma/client');
const prisma = globalForPrism.prisma ||  new PrismaClient();
module.exports = {prisma};


New (NestJS style)----prisma.service.ts


import {Injectable, OnModuleInit} from '@nestjs/common';
import {PrismaClient}  from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClien implements OnModuleInit{
  async onModuleInit(){
    await this.$connect();
  }
}


How to use the old style either in the business logic or the Prisma class

Manual Singletopn 

// utils/prisma.js
const globalForPrisma = globalThis;
const prisma = globalForPrisma.prisma || new PrismaClient();
module.exports = {prisma};

// users.controller.js
const { prisma } = require('../utils/prisma');  // ← Manual import
const getUsers = async () => {
  return await prisma.user.findMany();
};


PRISMA SCHEMA 

this will be the back bone of the project as the platform  will be dependent  upon the follwing:
1. Multi tenancy depends on how you store the tenantId
2. Converstation history /state depends on the conversation +Messages
3. Agent workflow execution depends on the  Agent and its flowJson
4. Knowledge base per tenant depends on the "Document"
5. Integration ( like the ticketing/KM/ Slack ) depend on Tool

Once we do the migration we ill be generating the Prisma client and we then  plug it into the NestJS services 
We can then immediately start building the endpoints like th efollowing :
POST/conversations 
POST/messages
GET/kb/search


So Phase 2 will the locking of the data contracts so that the rest of the app can exists

// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Multi-Tenancy
model Tenant {
  id        String   @id @default(cuid())
  name      String   @unique
  plan      TenantPlan @default(FREE)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  users         User[]
  agents        Agent[]
  tools         Tool[]
  conversations Conversation[]
  documents     Document[]
}

enum TenantPlan {
  FREE
  PRO
  ENTERPRISE
}

// Users & Auth
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  role      UserRole @default(VIEWER)
  tenantId  String
  tenant    Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

enum UserRole {
  ADMIN
  AUTHOR
  VIEWER
}

// LangGraph Flows (Agents)
model Agent {
  id        String      @id @default(cuid())
  name      String
  version   String      @default("0.1.0")
  status    AgentStatus @default(DRAFT)
  flowJson  Json        // LangGraph flow definition
  tenantId  String
  tenant    Tenant      @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  createdAt DateTime    @default(now())
  updatedAt DateTime    @updatedAt
  
  conversations Conversation[]
}

enum AgentStatus {
  DRAFT
  PUBLISHED
  DISABLED
}

// Integration Tools (KB, Ticketing, etc.)
model Tool {
  id           String   @id @default(cuid())
  name         String   @unique
  title        String
  type         ToolType
  inputSchema  Json
  outputSchema Json
  authType     String   // "service_account" | "oauth" | "api_key"
  authConfig   Json     // credentials, tokens
  tenantId     String?
  tenant       Tenant?  @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt
}

enum ToolType {
  KB_SEARCH
  TICKET_CREATE
  SLACK_POST
  TEAMS_POST
  CUSTOM
}

// Conversation State Management
model Conversation {
  id        String   @id @default(cuid())
  agentId   String
  agent     Agent    @relation(fields: [agentId], references: [id], onDelete: Cascade)
  tenantId  String
  tenant    Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  userId    String?  // Optional: who started this conversation
  channel   String?  // "web" | "slack" | "teams"
  state     Json     // LangGraph state
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  messages  Message[]
}

// Message History
model Message {
  id        String       @id @default(cuid())
  role      MessageRole  // "user" | "assistant" | "tool" | "system"
  content   String
  metadata  Json?        // tool calls, feedback, etc.
  convoId   String
  convo     Conversation @relation(fields: [convoId], references: [id], onDelete: Cascade)
  createdAt DateTime     @default(now())
}

enum MessageRole {
  USER
  ASSISTANT
  TOOL
  SYSTEM
}

// Document/KB Management
model Document {
  id        String   @id @default(cuid())
  source    String   // "upload" | "sharepoint" | "confluence"
  uri       String   // S3 path, URL, etc.
  title     String
  metadata  Json     // tags, category, etc.
  tenantId  String
  tenant    Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}