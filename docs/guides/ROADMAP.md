# 🛣️ AI Platform Development Roadmap

**Project:** Multi-Tenant LangGraph AI Authoring Platform  
**Started:** November 5, 2025  
**Last Updated:** November 11, 2025  
**Current Phase:** Phase 4 - Agent & Flow Management

---

## 📊 Progress Overview

```
Phase 1: ████████████████████ 100% ✅ Complete
Phase 2: ████████████████████ 100% ✅ Complete
Phase 3: ████████████████████ 100% ✅ Complete
Phase 4: ░░░░░░░░░░░░░░░░░░░░   0% 🎯 In Progress
Phase 5: ░░░░░░░░░░░░░░░░░░░░   0% ⏳ Planned
Phase 6: ░░░░░░░░░░░░░░░░░░░░   0% ⏳ Planned
Phase 7: ░░░░░░░░░░░░░░░░░░░░   0% ⏳ Planned
Phase 8: ░░░░░░░░░░░░░░░░░░░░   0% ⏳ Planned
```

**Overall Progress:** 37.5% (3 of 8 phases complete)

---

## ✅ Phase 1: Foundation Setup
**Status:** Complete  
**Completed:** November 5, 2025  
**Time Spent:** 2 hours

### Goals
- [x] NestJS 11.1.7 framework setup
- [x] TypeScript 5.9.3 configuration
- [x] Docker Compose with PostgreSQL 16 + Redis 7
- [x] Basic project structure
- [x] Swagger/OpenAPI integration
- [x] Environment configuration
- [x] Health check endpoint

### Deliverables
- ✅ `docker-compose.yml` - Infrastructure as code
- ✅ `tsconfig.json` - TypeScript settings
- ✅ `src/main.ts` - NestJS bootstrap
- ✅ `src/controllers/app.controller.ts` - Health check
- ✅ `.env` - Environment variables

### Key Decisions
- **NestJS over Express:** Chosen for dependency injection, decorators, and enterprise patterns
- **PostgreSQL over MongoDB:** Relational data with JSONB for flexible workflow storage
- **Docker first:** Ensures consistent dev environment across team

### Validation Criteria
- ✅ Server starts on port 3000
- ✅ Swagger UI accessible at `/api`
- ✅ PostgreSQL container running on port 5432
- ✅ Redis container running on port 6379
- ✅ Health check returns 200 OK

---

## ✅ Phase 2: Database Schema & ORM
**Status:** Complete  
**Completed:** November 6, 2025  
**Time Spent:** 3 hours

### Goals
- [x] Design multi-tenant schema
- [x] Create 7 core models (Tenant, User, Agent, Tool, Conversation, Message, Document)
- [x] Define 5 enums (TenantPlan, UserRole, AgentStatus, ToolType, MessageRole)
- [x] Set up Prisma ORM
- [x] Create initial migration
- [x] Generate Prisma Client

### Deliverables
- ✅ `prisma/schema.prisma` - Complete data model
- ✅ `prisma/migrations/20251106022522_ai_platform_schema/` - Migration files
- ✅ `src/services/prisma.service.ts` - Database connection singleton

### Schema Architecture
```
Tenant (Root)
├── Users (1:N, CASCADE)
├── Agents (1:N, CASCADE)
├── Tools (1:N, CASCADE)
├── Conversations (1:N, CASCADE)
│   └── Messages (1:N, CASCADE)
└── Documents (1:N, CASCADE)
```

### Key Decisions
- **CUID over UUID:** Shorter, lexicographically sortable IDs
- **CASCADE deletes:** Ensures tenant deletion cleans up ALL data
- **JSONB for workflows:** Flexibility for LangGraph flow definitions
- **Separate Tool model:** Reusable integrations across agents

### Validation Criteria
- ✅ Migration applied: `npx prisma migrate status`
- ✅ All 7 tables created in PostgreSQL
- ✅ Prisma Studio shows tables: `npm run db:studio`
- ✅ No TypeScript compilation errors

---

## ✅ Phase 3: Multi-Tenancy Foundation
**Status:** Complete  
**Completed:** November 10, 2025  
**Time Spent:** 4 hours

### Subphases

#### Phase 3.1: TenantGuard Security Layer ✅
- [x] Create `src/guards/tenant.guard.ts`
- [x] Implement `CanActivate` interface
- [x] Validate `X-Tenant-Id` header
- [x] Database lookup for tenant verification
- [x] Attach tenant object to request
- [x] Error handling (400 for missing, 403 for invalid)
- [x] Documentation: `TENANT_GUARD_EXPLANATION.md`

#### Phase 3.2: Tenants CRUD Module ✅
- [x] Create `src/tenants/` module structure
- [x] Implement TenantsController (5 endpoints)
- [x] Implement TenantsService with business logic
- [x] Create DTOs with validation
  - `create-tenant.dto.ts` - name (required), plan (optional)
  - `update-tenant.dto.ts` - partial updates
- [x] Register module in `app.module.ts`
- [x] Swagger documentation

#### Phase 3.3: Apply Tenant Isolation ✅
- [x] Apply `@UseGuards(TenantGuard)` to UsersController
- [x] Update UsersService to accept `tenantId` parameter
- [x] Add `where: { tenantId }` filters to Prisma queries
- [x] Test tenant isolation
- [x] Update Swagger docs with security requirements

### Deliverables
- ✅ `src/guards/tenant.guard.ts` - Security middleware
- ✅ `src/tenants/` - Complete CRUD module
- ✅ `TENANT_GUARD_EXPLANATION.md` - Architecture documentation
- ✅ Updated `src/controllers/users.controller.ts` - Tenant-aware endpoints
- ✅ Updated `src/services/users.service.ts` - Filtered queries

### API Endpoints Created
```
POST   /tenants        - Create tenant
GET    /tenants        - List tenants (with counts)
GET    /tenants/:id    - Get single tenant
PATCH  /tenants/:id    - Update tenant
DELETE /tenants/:id    - Delete tenant (CASCADE)

GET    /users          - List users (requires X-Tenant-Id)
POST   /users          - Create user
GET    /users/:id      - Get user by ID
```

### Key Decisions
- **Guard over Middleware:** NestJS guards integrate better with DI and route-level control
- **Header-based tenant:** Simple, works with JWT later (Phase 7)
- **400 vs 403:** 400 for missing header (client error), 403 for invalid tenant (authorization)
- **Request attachment:** `req.tenant` pattern keeps controllers clean

### Validation Criteria
- ✅ Can create tenant via POST /tenants
- ✅ Missing X-Tenant-Id returns 400 Bad Request
- ✅ Invalid tenant ID returns 403 Forbidden
- ✅ Valid tenant ID filters data correctly
- ✅ Tenant A cannot see Tenant B's users
- ✅ All DTOs validate input properly

---

## 🎯 Phase 4: Agent & Flow Management
**Status:** In Progress  
**Started:** November 11, 2025  
**Target Completion:** November 12, 2025  
**Estimated Time:** 2-3 hours

### Goals
- [ ] Create Agents CRUD module
- [ ] Store LangGraph workflows as JSON
- [ ] Version management for agents
- [ ] Status control (DRAFT/PUBLISHED/DISABLED)
- [ ] Tenant isolation for agents
- [ ] Relationship with Conversations

### Planned Deliverables
- `src/agents/agents.module.ts`
- `src/agents/agents.controller.ts`
- `src/agents/agents.service.ts`
- `src/agents/dto/create-agent.dto.ts`
- `src/agents/dto/update-agent.dto.ts`
- `src/agents/dto/update-agent-status.dto.ts`

### API Endpoints to Build
```
POST   /agents              - Create new agent workflow
GET    /agents              - List all agents (tenant-scoped)
GET    /agents/:id          - Get agent by ID
PATCH  /agents/:id          - Update agent (name, version, flowJson)
PATCH  /agents/:id/status   - Change status (DRAFT → PUBLISHED)
DELETE /agents/:id          - Delete agent
```

### Tasks Breakdown
- [ ] 4.1: Create DTOs with validation (30 min)
  - [ ] CreateAgentDto (name, version, flowJson, tenantId)
  - [ ] UpdateAgentDto (partial updates)
  - [ ] UpdateAgentStatusDto (status enum validation)
- [ ] 4.2: Implement AgentsService (45 min)
  - [ ] create() - Create agent with duplicate name check
  - [ ] findAll() - List agents for tenant
  - [ ] findOne() - Get single agent
  - [ ] update() - Update agent fields
  - [ ] updateStatus() - Change agent status
  - [ ] remove() - Delete agent
- [ ] 4.3: Implement AgentsController (30 min)
  - [ ] Apply @UseGuards(TenantGuard)
  - [ ] Map all CRUD endpoints
  - [ ] Add Swagger documentation
- [ ] 4.4: Testing & Validation (30 min)
  - [ ] Create test agent with LangGraph flow
  - [ ] Test status transitions
  - [ ] Verify tenant isolation
  - [ ] Test version management

### Key Design Decisions
- **flowJson as Json type:** Prisma JSONB for flexible workflow storage
- **Version as string:** Supports semantic versioning (e.g., "1.2.3")
- **Status enum:** Explicit states prevent invalid workflows from running
- **Tenant scoping:** Use TenantGuard like Users module

### Success Criteria
- [ ] Can create agent with LangGraph JSON
- [ ] Agent status transitions work (DRAFT → PUBLISHED → DISABLED)
- [ ] Version field updates correctly
- [ ] Tenant A cannot access Tenant B's agents
- [ ] flowJson validates as proper JSON object
- [ ] Swagger docs show all endpoints

### Reference Guide
See: `PHASE_4_GUIDE.md` for detailed implementation steps

---

## ⏳ Phase 5: Conversations & Messages
**Status:** Planned  
**Target Start:** November 13, 2025  
**Estimated Time:** 3-4 hours

### Goals
- [ ] Create Conversations CRUD module
- [ ] Create Messages module
- [ ] Redis integration for conversation state
- [ ] Link conversations to agents
- [ ] Track message history (user + assistant)
- [ ] Conversation status management (ACTIVE/COMPLETED)

### Planned Features
- Store conversation state in Redis (fast access)
- Persist messages in PostgreSQL (durability)
- Support multi-turn conversations
- Associate conversations with specific agents
- Track metadata (started, ended, message count)

### API Endpoints to Build
```
POST   /conversations           - Start new conversation
GET    /conversations           - List conversations
GET    /conversations/:id       - Get conversation details
PATCH  /conversations/:id       - Update conversation
DELETE /conversations/:id       - End conversation

POST   /conversations/:id/messages   - Send message
GET    /conversations/:id/messages   - Get message history
```

### Technical Considerations
- Redis for state: `conversation:<id>:state` key pattern
- PostgreSQL for messages: Durable storage
- Pagination for message history
- Real-time updates (future: WebSocket support)

---

## ⏳ Phase 6: Tools & Integrations
**Status:** Planned  
**Target Start:** November 15, 2025  
**Estimated Time:** 4-5 hours

### Goals
- [ ] Create Tools CRUD module
- [ ] Implement knowledge base search tool
- [ ] Implement ticket creation tool (Zammad integration)
- [ ] Implement Slack notification tool
- [ ] Dynamic input/output schema validation
- [ ] Secure auth config storage (API keys, OAuth)

### Tool Types to Implement
1. **KB_SEARCH** - Vector search in documents
2. **TICKET_CREATE** - Create support tickets
3. **SLACK_POST** - Send Slack notifications
4. **WEB_SEARCH** - External web search
5. **CUSTOM_API** - Generic HTTP tool

### API Endpoints to Build
```
POST   /tools           - Register new tool
GET    /tools           - List available tools
GET    /tools/:id       - Get tool details
PATCH  /tools/:id       - Update tool config
DELETE /tools/:id       - Remove tool
POST   /tools/:id/test  - Test tool execution
```

### Technical Challenges
- Secure storage of API keys (encryption)
- Dynamic schema validation
- Tool execution sandboxing
- Rate limiting per tool
- Error handling for external APIs

---

## ⏳ Phase 7: Authentication & Authorization (JWT)
**Status:** Planned  
**Target Start:** November 18, 2025  
**Estimated Time:** 3-4 hours

### Goals
- [ ] Implement JWT authentication
- [ ] Create Auth module (login, register, refresh)
- [ ] Combine JWT + TenantGuard
- [ ] Role-based access control (ADMIN/AUTHOR/VIEWER)
- [ ] Password hashing (bcrypt)
- [ ] Token refresh mechanism

### Authentication Flow
```
1. POST /auth/register → Create user account
2. POST /auth/login → Returns JWT token
3. All requests → Include Authorization: Bearer <token>
4. JWT decoded → Extract user + tenant
5. TenantGuard validates tenant from JWT
```

### API Endpoints to Build
```
POST   /auth/register       - Create account
POST   /auth/login          - Get JWT token
POST   /auth/refresh        - Refresh token
POST   /auth/logout         - Invalidate token
GET    /auth/me             - Get current user
PATCH  /auth/password       - Change password
```

### Security Enhancements
- JWT signed with RS256 (public/private key pair)
- Refresh tokens stored in Redis
- Token expiration (15 min access, 7 day refresh)
- RBAC enforcement at service layer

---

## ⏳ Phase 8: LangGraph Service Integration
**Status:** Planned  
**Target Start:** November 20, 2025  
**Estimated Time:** 5-6 hours

### Goals
- [ ] Create Python FastAPI service for LangGraph
- [ ] HTTP API for workflow execution
- [ ] NestJS → FastAPI communication
- [ ] Execute stored agent workflows
- [ ] Stream responses back to client
- [ ] Handle tool calls from LangGraph

### Architecture
```
Client → NestJS API → FastAPI Service → LangGraph → LLM (OpenAI/Ollama)
                  ↓
              PostgreSQL (store flows)
                  ↓
              Redis (conversation state)
```

### LangGraph Service API
```
POST   /execute        - Run agent workflow
POST   /stream         - Stream execution results
POST   /validate       - Validate flowJson structure
GET    /health         - Service health check
```

### Integration Points
- NestJS stores workflows in PostgreSQL
- FastAPI reads flowJson and executes
- Results streamed back via Server-Sent Events
- Tool calls routed back to NestJS tools module

---

## 🎯 Future Phases (Backlog)

### Phase 9: Document Management & Vector Search
- Document upload and processing
- Text chunking and embedding generation
- Vector database integration (Pinecone/Qdrant)
- Semantic search API

### Phase 10: Real-time Features
- WebSocket support for live conversations
- Server-Sent Events for streaming responses
- Real-time agent status updates
- Live collaboration features

### Phase 11: Analytics & Monitoring
- Conversation analytics dashboard
- Agent performance metrics
- Tool usage statistics
- Error tracking and logging (Sentry integration)

### Phase 12: Deployment & DevOps
- Kubernetes deployment manifests
- CI/CD pipeline (GitHub Actions)
- Multi-environment setup (dev/staging/prod)
- Database backups and disaster recovery

---

## 📋 Cross-Reference Checklist

Use this checklist **before starting each coding session** to stay on track:

### Pre-Session Checklist
- [ ] Read `ROADMAP.md` - Confirm current phase
- [ ] Read phase-specific guide (e.g., `PHASE_4_GUIDE.md`)
- [ ] Check `DEV_SESSION_LOG.md` - Review last session notes
- [ ] Review `CHANGELOG.md` - See recent changes
- [ ] Check Docker containers: `docker ps`
- [ ] Verify database migration status: `npm run db:migrate:status`
- [ ] Pull latest changes: `git pull origin main`

### During Development
- [ ] Follow the phase guide step-by-step
- [ ] Update `DEV_SESSION_LOG.md` with decisions made
- [ ] Mark roadmap tasks as complete in this file
- [ ] Test each feature before moving to next task
- [ ] Document complex logic in code comments

### Post-Session Checklist
- [ ] Update `ROADMAP.md` progress percentages
- [ ] Add entry to `CHANGELOG.md` with changes made
- [ ] Update `README.md` roadmap section if phase complete
- [ ] Commit changes with descriptive message
- [ ] Push to repository: `git push origin main`
- [ ] Update `START_HERE.md` with next session plan

---

## 📊 Phase Tracking Template

Copy this template to `DEV_SESSION_LOG.md` when starting a new phase:

```markdown
## 📝 Phase X: [Phase Name] - [Date]

### Session Goal
[What you're building today]

### Pre-Session Status
- [ ] Docker running
- [ ] Database migrated
- [ ] Previous phase verified complete
- [ ] Read phase guide

### Tasks
- [ ] Task 1 (estimated time)
- [ ] Task 2 (estimated time)
- [ ] Task 3 (estimated time)

### Decisions Made
**Q:** [Question or problem]
**Decision:** [What you decided]
**Reasoning:** [Why this approach]

### Blockers Encountered
[Any issues that slowed progress]

### Next Session
[What to start with tomorrow]
```

---

## 🔗 Document Cross-Reference

| Document | Purpose | Update Frequency |
|----------|---------|------------------|
| `ROADMAP.md` (this file) | Master plan, progress tracking | After each phase |
| `START_HERE.md` | Quick start for next session | Daily |
| `DEV_SESSION_LOG.md` | Development notes, decisions | During session |
| `CHANGELOG.md` | Version history | After each commit |
| `README.md` | Public documentation | When phase completes |
| `PHASE_X_GUIDE.md` | Step-by-step instructions | Before phase starts |

---

## 🎯 Success Metrics

### Code Quality
- [ ] All endpoints have Swagger documentation
- [ ] All DTOs use class-validator
- [ ] All services have error handling
- [ ] TypeScript strict mode with no errors
- [ ] No console.log statements (use Logger)

### Testing
- [ ] Manual testing via Swagger UI
- [ ] Test tenant isolation for all modules
- [ ] Test error cases (400, 403, 404, 409)
- [ ] Test with multiple tenants simultaneously

### Documentation
- [ ] Code has JSDoc comments for complex functions
- [ ] README.md reflects current features
- [ ] Each phase has explanation doc (like TENANT_GUARD_EXPLANATION.md)
- [ ] API examples in documentation

---

**Last Updated:** November 11, 2025  
**Next Review:** After Phase 4 completion  
**Maintained By:** Development Team
