# 🚀 Start Here - Next Session Guide

**Last Updated:** November 11, 2025  
**Current Status:** Phase 3 Complete  
**Next Step:** Phase 4 - Agent & Flow Management

---

## FIRST TIME? Get Automatic Reminders!

**Don't open VS Code with `code .` - Use this instead:**

```bash
code ai-platform.code-workspace
```

This opens the workspace with **automatic session reminders** that show the 8-step workflow every time!

📖 **Full instructions:** [`HOW_TO_USE_REMINDER_SYSTEM.md`](HOW_TO_USE_REMINDER_SYSTEM.md)

---

## 🎯 IMPORTANT: Start Every Session Here

### **Run the Session Checklist**

📋 **Open:** `SESSION_CHECKLIST.md`

This checklist ensures you:

- Have Docker running
- Pull latest changes from Git
- Understand what phase you're on
- Follow the roadmap correctly
- Stay aligned with the master plan

** DO NOT skip this step!** It only takes 5 minutes and prevents hours of wasted work.

---

## **Check the Roadmap**

🛣️ **Open:** `docs/guides/ROADMAP.md`

The roadmap shows:

- Overall progress (currently 63.64% - 7 of 11 phases done)
- Detailed breakdown of each phase
- What's complete, in progress, and planned
- Cross-reference checklist
- Success criteria for each phase

**Current Phase:** Phase 8 - LangGraph Execution Service (FastAPI)

---

## **Read the Phase Guide**

📖 **Open:** `docs/guides/PHASE_8_GUIDE.md` (Phase 8 - FastAPI LangGraph Service)

The phase guide provides:

- Step-by-step instructions
- Code examples
- Estimated time for each task
- Technical decisions explained
- Testing criteria

**Follow the guide exactly** - it's designed to prevent common mistakes.

---

## 📚 Simple Documentation System

**Core Documents (Update these ONLY):**

| Document                             | Purpose                      | When to Update              |
| ------------------------------------ | ---------------------------- | --------------------------- |
| **docs/guides/ROADMAP.md**           | ⭐ Single source of truth    | Planning, progress tracking |
| **docs/guides/START_HERE.md**        | Session entry point          | Rarely (structure changes)  |
| **docs/guides/SESSION_CHECKLIST.md** | Pre/post session workflow    | Never (it's a template)     |
| **docs/guides/PHASE_X_GUIDE.md**     | Implementation steps         | When creating new phase     |
| **DEV_SESSION_LOG.md**               | Development notes, decisions | Once per session (at end)   |
| **CHANGELOG.md**                     | Version history              | When committing to git      |
| **README.md**                        | Public project documentation | Major milestones only       |

**Workflow:**

```
START_HERE.md → ROADMAP.md → PHASE_X_GUIDE.md → Code → Update DEV_SESSION_LOG.md → Commit (update CHANGELOG.md)
```

**Documentation Structure:**

- **docs/guides/** - ROADMAP.md (source of truth) + phase guides
- **docs/reference/** - Technical references (rarely updated)
- **docs/system/** - Workflow documentation (static)
- **DEV_SESSION_LOG.md** - Session notes (update at end of session)
- **CHANGELOG.md** - What changed (update when committing)

---

## What You've Completed

### Phase 1: Foundation ✅

- NestJS 11.1.7 installed and configured
- Docker Compose with PostgreSQL + Redis
- TypeScript configuration
- Basic project structure

### Phase 2: Core Data Models ✅

- Complete Prisma schema with 7 models
- Database migration: `20251106022522_ai_platform_schema`
- All tables created in PostgreSQL
- Prisma Client generated

### Phase 3: Multi-Tenancy Foundation ✅

- Phase 3.1: TenantGuard security layer
- Phase 3.2: Tenants CRUD module
- Phase 3.3: Applied guard to Users endpoints
- Complete tenant isolation implemented

### Phase 4: Agent Management ✅

- Agent DTOs with validation
- AgentsService with 6 methods
- AgentsController with 6 endpoints
- Tenant-scoped agent operations
- Automated test script

### Phase 5: Tool Management ✅

- Tools CRUD module
- Tool type enum (KB_SEARCH, TICKET_CREATE, etc.)
- AES-256 encryption for API keys
- Dynamic schema validation
- 12 automated tests

### Phase 6: Conversations API ✅

- Conversations CRUD
- Messages CRUD with role enum
- Conversation state tracking
- Agent ownership validation
- 15 automated tests

### Phase 7: Document Management ✅

- Documents CRUD module
- Document source types (upload, sharepoint, etc.)
- Basic text search
- Metadata storage with JSONB
- 12 automated tests

**Control Plane:** 100% Complete (7 of 7 phases) ✅

---

## 🎯 Next Session: Phase 8 - LangGraph Execution Service

### What You'll Build

**Goal:** Create FastAPI service that executes LangGraph workflows using agent flowJson

### Quick Start for Phase 4

#### 1. Run Session Checklist

```bash
# Open SESSION_CHECKLIST.md and follow Pre-Session steps
# - Verify Docker running
# - Git pull latest
# - Check database status
# - Read PHASE_4_GUIDE.md
```

#### 2. Understand What an Agent Is

An "Agent" = A stored AI workflow (like a recipe for AI behavior)

Example:

```json
{
  "name": "IT Support Bot",
  "version": "1.0.0",
  "flowJson": {
    "nodes": [
      { "id": "kb_search", "type": "tool" },
      { "id": "get_feedback", "type": "user_input" },
      { "id": "create_ticket", "type": "tool" }
    ]
  }
}
```

#### 3. Create Files in This Order

**3.1 Create DTOs (30 minutes)**

- `src/agents/dto/create-agent.dto.ts` - Validation for new agents
- `src/agents/dto/update-agent.dto.ts` - Partial updates
- `src/agents/dto/update-agent-status.dto.ts` - Status changes

**3.2 Create Service (45 minutes)**

- `src/agents/agents.service.ts` - Business logic (CRUD operations)

**3.3 Create Controller (30 minutes)**

- `src/agents/agents.controller.ts` - API endpoints
- Apply `@UseGuards(TenantGuard)` for tenant isolation

**3.4 Create Module (15 minutes)**

- `src/agents/agents.module.ts` - Wire everything together
- Register in `app.module.ts`

**3.5 Test (30 minutes)**

- Use Swagger UI at `http://localhost:3000/api`
- Test all CRUD operations
- Verify tenant isolation

**Total Time:** ~2.5 hours

---

## 🛠️ Quick Commands

```bash
# Start infrastructure
docker compose up -d

# Start dev server
npm run start:dev

# Open Prisma Studio (view database)
npm run db:studio

# Check migration status
npm run db:migrate:status

# Build project (check for errors)
npm run build
```

---

## 🎯 Phase 4 Success Criteria

You'll know you're done when:

- Can create agent with JSON workflow via POST /agents
- Agent status transitions work (DRAFT → PUBLISHED → DISABLED)
- Tenant A cannot access Tenant B's agents
- Version field updates correctly
- All endpoints documented in Swagger
- Prisma queries filter by tenantId

---

## 📖 Detailed Phase 4 Instructions

**See:** `PHASE_4_GUIDE.md` for complete step-by-step implementation

This guide includes:

- Exact code to write
- Where to put each file
- What each function should do
- Testing instructions
- Common mistakes to avoid

---

## 🚨 Important Reminders

1. **Follow the roadmap** - Don't skip ahead or go off-plan
2. **Use SESSION_CHECKLIST.md** - Start and end every session with it
3. **Test as you go** - Don't write 5 files before testing
4. **Document decisions** - Update DEV_SESSION_LOG.md with your thinking
5. **Commit often** - Small commits are better
6. **Apply TenantGuard** - Every module needs tenant isolation
7. **Update ROADMAP.md** - Mark tasks complete as you finish them

---

## 🎯 This Session's Goal

**By end of session, you should have:**

- Agents module fully functional
- Can store LangGraph workflows as JSON
- Agent status management working
- Tenant isolation for agents
- All tests passing
- Documentation updated

**Estimated Time:** 2-3 hours

---

## 🔄 After This Session

When Phase 4 is complete:

1. Update `ROADMAP.md` - Mark Phase 4 as
2. Update `CHANGELOG.md` - Document changes
3. Update `README.md` - Update roadmap section
4. Commit and push to GitHub
5. Come back to this file - it will guide you to Phase 5

---

## 💡 Pro Tips

- **Read before coding:** Spend 10 min reading PHASE_4_GUIDE.md
- **Swagger is your friend:** Test every endpoint immediately
- **Copy existing patterns:** Look at how Tenants module is structured
- **Use Prisma Studio:** Visually verify data is correct
- **Don't guess:** If stuck, re-read the guide

---

## 🎯 Next Phase Preview (Phase 5)

After Agent module is done, you'll build:

- **Conversations module** - Store conversation state
- **Messages module** - Chat history
- **Redis integration** - Fast conversation state access
- **Link conversations to agents** - Track which workflow is running

But don't think about that yet - focus on Phase 4! 🚀

---

**Remember:** You've already completed 37.5% of the project. Phase 4 will bring you to 50%. You're doing great! Keep following the roadmap and you'll have a production-ready AI platform soon. 💪

---

## 📂 Current Project Structure

```
Oct25shaaz/
├── src/
│   ├── main.ts                      ← NestJS entry point
│   ├── app.module.ts                ← Root module
│   ├── guards/
│   │   └── tenant.guard.ts          ←  Multi-tenant security
│   ├── tenants/
│   │   ├── tenants.module.ts        ←  Tenant management
│   │   ├── tenants.controller.ts
│   │   ├── tenants.service.ts
│   │   └── dto/
│   │       ├── create-tenant.dto.ts
│   │       └── update-tenant.dto.ts
│   ├── controllers/
│   │   ├── app.controller.ts
│   │   └── users.controller.ts      ←  Protected with TenantGuard
│   ├── services/
│   │   ├── prisma.service.ts        ← Database singleton
│   │   └── users.service.ts         ←  Tenant-scoped queries
│   ├── dto/
│   │   └── create-user.dto.ts
│   └── agents/                      ← 🎯 CREATE THIS for Phase 4
│       ├── agents.module.ts
│       ├── agents.controller.ts
│       ├── agents.service.ts
│       └── dto/
├── prisma/
│   ├── schema.prisma                ←  7 models defined
│   └── migrations/
│       └── 20251106022522_ai_platform_schema/
├── docs/
│   ├── guides/
│   │   ├── ROADMAP.md               ← 🎯 Master plan
│   │   ├── SESSION_CHECKLIST.md     ← 🎯 Session workflow
│   │   ├── PHASE_4_GUIDE.md         ← Phase 4 implementation guide
│   │   └── START_HERE.md            ← You are here
│   ├── reference/
│   │   ├── tenant-guard-implementation.md ← TenantGuard technical reference
│   │   ├── folder structure.md
│   │   └── project notes.md
│   └── system/
│       └── DOCUMENTATION_GUIDE.md
├── DEV_SESSION_LOG.md               ← Development notes
├── CHANGELOG.md                     ← Version history
├── .env                             ← Environment config
├── docker-compose.yml
└── package.json
```

---

## 🔑 Environment Variables

**File:** `.env`

```env
DATABASE_URL="postgresql://ai:ai@localhost:5432/ai_platform"
REDIS_URL="redis://localhost:6379"
PORT=3000
NODE_ENV=development
JWT_SECRET=your-secret-key
```

---

## 🧪 Quick Health Check Commands

```bash
# 1. Check containers
docker ps

# 2. Test NestJS server
npm run start:dev
# Server should start on http://localhost:3000

# 3. Check Swagger docs
# Open: http://localhost:3000/api

# 4. Test health endpoint
curl http://localhost:3000/health

# 5. View database
npm run db:studio
```

---

## 📝 Important Notes

### Multi-Tenancy Pattern

Every request (except auth/public endpoints) must include:

```
X-Tenant-Id: clxxxx...
```

### Data Isolation

All models are linked to `Tenant` with `onDelete: Cascade`:

- Deleting a tenant deletes ALL their data (users, agents, conversations, etc.)
- This is intentional for data isolation

### PrismaService Already Exists

You already have `src/services/prisma.service.ts` - just import it:

```typescript
import { PrismaService } from "../services/prisma.service";
```

---

## 🐛 Common Issues & Solutions

### Issue: Docker containers not running

```bash
# Check if Docker Desktop is running (Windows)
# Then:
docker-compose up -d
```

### Issue: Port 3000 already in use

```bash
# Kill existing process or change PORT in .env
PORT=3001 npm run start:dev
```

### Issue: Database connection error

```bash
# Verify PostgreSQL is running:
docker logs oct25shaaz-postgres-1

# Test connection:
npm run db:studio
```

### Issue: Prisma Client out of sync

```bash
# Regenerate Prisma Client:
npm run db:generate
```

---

---

## 📚 Additional Resources

1. **Prisma Docs:** https://www.prisma.io/docs/concepts/components/prisma-client
2. **NestJS Docs:** https://docs.nestjs.com/
3. **Phase 4 Guide:** `PHASE_4_GUIDE.md` - Detailed instructions
4. **Roadmap:** `ROADMAP.md` - Full project plan
5. **Database Schema:** `prisma/schema.prisma`

---

## 🚀 You're Ready!

Everything is set up and Phase 3 is complete. Just follow the roadmap system:

1. **Open SESSION_CHECKLIST.md** - Run pre-session checklist
2. **Open ROADMAP.md** - Understand Phase 4
3. **Open PHASE_4_GUIDE.md** - Follow step-by-step
4. **Code** - Implement agents module
5. **Test** - Use Swagger UI
6. **Document** - Update DEV_SESSION_LOG.md
7. **Commit** - Push changes to Git

**You got this!** 🚀
