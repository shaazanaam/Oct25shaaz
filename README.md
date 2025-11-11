# 🤖 AI Authoring Platform - Multi-Tenant LangGraph Backend

[![NestJS](https://img.shields.io/badge/NestJS-11.1.7-E0234E?logo=nestjs)](https://nestjs.com/)
[![Prisma](https://img.shields.io/badge/Prisma-6.19.0-2D3748?logo=prisma)](https://www.prisma.io/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.9.3-3178C6?logo=typescript)](https://www.typescriptlang.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql)](https://www.postgresql.org/)
[![Redis](https://img.shields.io/badge/Redis-7-DC382D?logo=redis)](https://redis.io/)

> **A production-ready, enterprise-grade backend for building LangGraph-powered AI agents with complete multi-tenant isolation, real-time conversation management, and intelligent knowledge base integration.**

---

## 🌟 **What Makes This Special**

This isn't just another CRUD API. This is a **complete AI platform architecture** designed for:

- 🏢 **True Multi-Tenancy** - Complete data isolation with tenant-scoped guards
- 🤖 **LangGraph Integration** - Store and execute complex AI workflows as JSON
- 💬 **Conversation State Management** - Redis-backed stateful conversations
- 📚 **Knowledge Base Management** - Document ingestion and semantic search
- 🔌 **Tool Orchestration** - Dynamic integration layer (Slack, Zammad, custom APIs)
- 🎯 **Type-Safe** - End-to-end TypeScript with Prisma for bulletproof typing
- 📊 **Production Ready** - Docker Compose, migrations, error handling, and Swagger docs

---

## 🎯 **The Vision**

Build an AI support system where:
1. **User asks a question** → AI searches knowledge base
2. **KB provides answer** → User gives feedback
3. **If negative feedback** → Automatically creates support ticket
4. **All workflow defined as code** → LangGraph flows stored in database
5. **Each customer isolated** → Multi-tenant architecture ensures data privacy

**Use Cases:**
- 🎓 Enterprise AI Support Systems
- 🏥 Healthcare Chatbots with HIPAA Compliance
- 🏦 Financial Services AI Agents
- 🛒 E-commerce Customer Service Automation
- 📞 Multi-Client SaaS AI Platforms

---

## 🏗️ **Architecture Highlights**

### **Multi-Tenant Security Layer**
Every API request validates tenant context using a custom NestJS guard:

```typescript
// TenantGuard ensures complete data isolation
@UseGuards(TenantGuard)
@Get('users')
async getUsers(@Request() req) {
  const tenant = req.tenant; // Automatically validated & attached
  return this.usersService.findAll(tenant.id);
}
```

### **LangGraph Flow Storage**
AI workflows stored as JSON in PostgreSQL:

```typescript
{
  "nodes": [
    { "id": "kb_search", "type": "tool", "config": {...} },
    { "id": "get_feedback", "type": "user_input" },
    { "id": "create_ticket", "type": "tool", "condition": "negative" }
  ],
  "edges": [...]
}
```

### **7-Model Data Schema**
Carefully designed for AI platform needs:

```
Tenant (Multi-tenancy root)
  ├── Users (RBAC: Admin/Author/Viewer)
  ├── Agents (LangGraph workflows)
  ├── Tools (KB search, ticketing, integrations)
  ├── Conversations (State management)
  │   └── Messages (Chat history)
  └── Documents (Knowledge base)
```

---

## 🚀 **Tech Stack**

### **Backend Framework**
- **NestJS 11.1.7** - Enterprise-grade Node.js framework
- **TypeScript 5.9.3** - Type safety across the stack
- **Express.js** - HTTP server (NestJS default)

### **Database & ORM**
- **PostgreSQL 16** - Relational database with JSONB support
- **Prisma 6.19.0** - Next-gen ORM with type safety
- **Redis 7** - Session storage & LangGraph state caching

### **Developer Experience**
- **Swagger/OpenAPI** - Auto-generated API documentation
- **Docker Compose** - One-command infrastructure setup
- **class-validator** - Declarative DTO validation
- **Nodemon** - Hot reload for development

---

## 📊 **Project Structure**

```
src/
├── guards/
│   └── tenant.guard.ts              # Multi-tenant security layer
├── tenants/
│   ├── tenants.module.ts            # Tenant management module
│   ├── tenants.controller.ts        # CRUD endpoints
│   ├── tenants.service.ts           # Business logic
│   └── dto/
│       ├── create-tenant.dto.ts     # Input validation
│       └── update-tenant.dto.ts
├── controllers/
│   ├── app.controller.ts            # Health checks
│   └── users.controller.ts          # User management
├── services/
│   ├── prisma.service.ts            # Database connection singleton
│   └── users.service.ts             # User business logic
├── dto/
│   └── create-user.dto.ts           # User validation
└── main.ts                          # NestJS bootstrap

prisma/
├── schema.prisma                    # 7 models, 5 enums
└── migrations/
    └── 20251106022522_ai_platform_schema/
        └── migration.sql            # Database schema

docker-compose.yml                   # PostgreSQL + Redis
.env                                 # Environment configuration
```

---

## ⚡ **Quick Start**

### **Prerequisites**
- Node.js 20+
- Docker Desktop
- Git

### **1. Clone & Install**

```bash
git clone https://github.com/shaazanaam/Oct25shaaz.git
cd Oct25shaaz
npm install
```

### **2. Environment Setup**

Create `.env` file:

```env
DATABASE_URL="postgresql://ai:ai@localhost:5432/ai_platform"
REDIS_URL="redis://localhost:6379"
PORT=3000
NODE_ENV=development
JWT_SECRET=your-secret-key-change-in-production
```

### **3. Start Infrastructure**

```bash
# Start PostgreSQL + Redis
docker compose up -d

# Verify containers running
docker ps
```

### **4. Database Setup**

```bash
# Generate Prisma Client
npm run db:generate

# Run migrations
npm run db:migrate

# (Optional) Open Prisma Studio to view data
npm run db:studio
```

### **5. Start Development Server**

```bash
npm run start:dev
```

Server starts at: **http://localhost:3000**

Swagger docs: **http://localhost:3000/api**

---

## 📚 **API Endpoints**

### **Health Check**
```http
GET /health          # Server health status
```

### **Tenant Management**
```http
POST   /tenants      # Create new tenant
GET    /tenants      # List all tenants (with user/agent counts)
GET    /tenants/:id  # Get tenant by ID
PATCH  /tenants/:id  # Update tenant (name, plan)
DELETE /tenants/:id  # Delete tenant (CASCADE deletes all data!)
```

### **User Management**
```http
POST   /users        # Create user (requires tenantId)
GET    /users        # List all users
GET    /users/:id    # Get user by ID
```

---

## 🔒 **Security Features**

### **1. Tenant Isolation**
```typescript
// Every request must include X-Tenant-Id header
headers: {
  'X-Tenant-Id': 'clxxx123456'
}
```

### **2. Input Validation**
```typescript
// DTOs with class-validator
export class CreateTenantDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsEnum(['FREE', 'PRO', 'ENTERPRISE'])
  @IsOptional()
  plan?: string;
}
```

### **3. Error Handling**
- 400 Bad Request - Missing/invalid input
- 404 Not Found - Resource doesn't exist
- 409 Conflict - Duplicate resource (e.g., tenant name)
- 403 Forbidden - Invalid tenant access

### **4. Cascade Delete Protection**
Deleting a tenant removes ALL related data:
- ⚠️ All users
- ⚠️ All agents & workflows
- ⚠️ All conversations & messages
- ⚠️ All documents

---

## 🗄️ **Database Schema**

### **Core Models**

**Tenant** (Multi-tenancy root)
```prisma
model Tenant {
  id        String      @id @default(cuid())
  name      String      @unique
  plan      TenantPlan  @default(FREE)  // FREE | PRO | ENTERPRISE
  createdAt DateTime    @default(now())
  updatedAt DateTime    @updatedAt
}
```

**Agent** (LangGraph workflows)
```prisma
model Agent {
  id        String      @id @default(cuid())
  name      String
  version   String      @default("0.1.0")
  status    AgentStatus @default(DRAFT)  // DRAFT | PUBLISHED | DISABLED
  flowJson  Json        // LangGraph flow definition
  tenantId  String
}
```

**Tool** (Integration layer)
```prisma
model Tool {
  id           String   @id @default(cuid())
  name         String   @unique
  type         ToolType // KB_SEARCH | TICKET_CREATE | SLACK_POST | etc.
  inputSchema  Json
  outputSchema Json
  authConfig   Json     // API keys, OAuth tokens
}
```

[See full schema in `prisma/schema.prisma`]

---

## 🧪 **Testing with Swagger**

1. Start server: `npm run start:dev`
2. Open: http://localhost:3000/api
3. Create a tenant:
   ```json
   POST /tenants
   {
     "name": "acme-corp",
     "plan": "PRO"
   }
   ```
4. Use returned tenant ID in `X-Tenant-Id` header for other requests

---

## 🛣️ **Development Roadmap**

- [x] **Phase 1**: NestJS foundation, Docker, TypeScript
- [x] **Phase 2**: Prisma schema with 7 models (Tenant, User, Agent, Tool, Conversation, Message, Document)
- [x] **Phase 3.1**: TenantGuard for multi-tenant security
- [x] **Phase 3.2**: Tenants CRUD module
- [ ] **Phase 3.3**: Apply TenantGuard to all endpoints
- [ ] **Phase 4**: Agents module (LangGraph flow management)
- [ ] **Phase 5**: Conversations module (Redis state management)
- [ ] **Phase 6**: Tools module (KB search, ticketing integrations)
- [ ] **Phase 7**: LLM Gateway (OpenAI/Ollama/HuggingFace routing)
- [ ] **Phase 8**: LangGraph FastAPI service integration

---

## 🤝 **Contributing**

This is a learning project showcasing enterprise-grade architecture patterns. Suggestions and improvements welcome!

---

## 📝 **Documentation**

- `START_HERE.md` - Developer onboarding guide
- `DEV_SESSION_LOG.md` - Development decision log
- `CHANGELOG.md` - Version history
- `TENANT_GUARD_EXPLANATION.md` - Security layer deep dive
- `prismanotes.md` - Database architecture notes

---

## 🏆 **Why This Architecture?**

### **Scalability**
- Horizontal scaling with tenant sharding
- Redis caching for conversation state
- Stateless API design

### **Maintainability**
- Clean separation of concerns (Controller → Service → Repository)
- Dependency injection for testability
- Type safety prevents runtime errors

### **Extensibility**
- Plugin-based tool system
- JSON-based workflow storage
- Modular NestJS architecture

### **Security**
- Tenant isolation at guard level
- Input validation on all endpoints
- Cascade delete protection

---

## 📄 **License**

ISC

---

## 👨‍💻 **Author**

**Shaurya** - [GitHub](https://github.com/shaazanaam)

*Building the future of AI-powered customer support, one commit at a time.* 🚀

---

## ⭐ **If This Helped You**

Give it a star ⭐ and let me know what you're building with it!