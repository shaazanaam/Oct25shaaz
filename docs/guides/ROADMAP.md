# AI Platform Development Roadmap - FULL STACK

**Project:** Multi-Tenant LangGraph AI Authoring & Execution Platform  
**Architecture:** 8-Layer Full Stack (NestJS Control Plane + FastAPI Execution Plane)  
**Started:** November 5, 2025  
**Last Updated:** November 13, 2025  
**Current Phase:** Phase 5 - Tool Management (Control Plane)  
**Path:** B - Full Production Platform with LangGraph Execution

---

##  Architecture Overview

This project implements an **8-layer multi-tenant AI platform**:

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: Frontend (React)                                  │
│  - Flow Authoring UI | Chat Interface | Event Configuration│
├─────────────────────────────────────────────────────────────┤
│  Layer 2: Proxy & Routing (Nginx/Traefik)                  │
│  - Multi-tenant routing | Load balancing | SSL termination │
├─────────────────────────────────────────────────────────────┤
│  Layer 3: Control Plane (NestJS/TypeScript) ← CURRENT WORK │
│  - Agent/Tool/User CRUD | Metadata management | REST API   │
├─────────────────────────────────────────────────────────────┤
│  Layer 4: Execution Plane (FastAPI/Python)                 │
│  - LangGraph workflow execution | Tool orchestration       │
├─────────────────────────────────────────────────────────────┤
│  Layer 5: Event Layer (Kafka/RabbitMQ)                     │
│  - Webhooks | Scheduled events | External triggers         │
├─────────────────────────────────────────────────────────────┤
│  Layer 6: Integration Layer (MCP Servers)                  │
│  - KB Search | Ticketing | LLM Gateway | External APIs     │
├─────────────────────────────────────────────────────────────┤
│  Layer 7: Memory & Storage (PostgreSQL + Redis + MinIO)    │
│  - Conversation state | Long-term memory | Vector DB       │
├─────────────────────────────────────────────────────────────┤
│  Layer 8: Core Services (Keycloak + Prometheus + ELK)      │
│  - Auth | Multi-tenancy | Monitoring | Logging             │
└─────────────────────────────────────────────────────────────┘
```

### What NestJS Backend Does (Control Plane)
- **Metadata Management:** Store agent definitions, tool configs, user accounts
- **CRUD Operations:** REST API for managing all entities
- **Security:** Multi-tenant isolation, JWT authentication, RBAC
- **Orchestration:** Trigger FastAPI execution, store results
- **Admin Panel Backend:** Powers the management UI

### What FastAPI Backend Does (Execution Plane)
- **LangGraph Runtime:** Execute Python workflows stored as `flowJson`
- **Tool Execution:** Call MCP servers (KB search, ticketing, LLMs)
- **Streaming:** Real-time conversation responses via SSE
- **State Management:** Load/save conversation state to Redis

### End-to-End Data Flow Example

**Scenario:** User asks question → KB lookup → Create ticket

```
1. User types "How do I reset my password?" in chat UI
   
2. React Frontend → POST /conversations/:id/messages

3. NestJS Control Plane
   → Saves message to PostgreSQL
   → Calls FastAPI: POST /execute { agentId, conversationId, message }
   
4. FastAPI Execution Plane
   → Loads agent flowJson from NestJS
   → Executes LangGraph workflow:
      a) KB Lookup Node → Calls MCP KB Search → Qdrant returns top 3 docs
      b) Feedback Check → LLM determines KB didn't help
      c) Ticket Creation → Calls MCP Ticketing → Zammad creates ticket #12345
      d) Slack Notification → Posts to #support channel
   
5. FastAPI saves state to Redis (conversation:{id}:state)
   
6. FastAPI calls NestJS to save assistant response
   
7. User sees: "I created ticket #12345 for you."
```

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | React + TypeScript + Vite | Flow builder, chat UI, admin |
| Proxy | Nginx/Traefik | Routing, SSL, load balancing |
| Control Plane | NestJS + TypeScript | Metadata CRUD, security |
| Execution Plane | FastAPI + Python | LangGraph runtime |
| Event Layer | Kafka/RabbitMQ | Event streaming, webhooks |
| Integration | FastAPI microservices | MCP servers for tools |
| Database | PostgreSQL 16 | Relational data, JSONB |
| Cache | Redis 7 | Sessions, state, cache |
| Object Storage | MinIO | Documents, templates |
| Vector DB | Qdrant | Semantic search |
| Version Control | Gitea | Flow versioning |
| Auth | Keycloak | OAuth2, multi-tenancy |
| Monitoring | Prometheus + Grafana | Metrics, dashboards |
| Logging | ELK Stack | Centralized logs |

### Security & Multi-Tenancy

**Authentication Flow:**
1. User logs in → Keycloak issues JWT (contains userId, tenantId, roles)
2. React stores JWT in httpOnly cookie
3. Every API call includes JWT in Authorization header
4. NestJS validates JWT and extracts tenantId
5. TenantGuard ensures user belongs to tenant
6. All queries filtered by tenantId

**Tenant Isolation:**
- **Database:** WHERE tenantId = :tenantId on ALL queries
- **Redis:** Keys prefixed with tenant:{tenantId}:*
- **Qdrant:** Separate collections per tenant
- **MinIO:** Buckets per tenant
- **MCP:** Tenant ID required for all tool calls
- **Secrets:** API keys encrypted with AES-256

---

## Progress Overview

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                    AI PLATFORM DEVELOPMENT PROGRESS                       ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  Overall Progress: [█████████░░░░░░░░░░░░░░░░░░░] 45.45% (5/11 phases)  ║
║                                                                           ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  CONTROL PLANE (NestJS/TypeScript)                    71.43% (5/7)       ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  Phase 1: Foundation                  [████████████████████] 100% ✓      ║
║  Phase 2: Database Schema             [████████████████████] 100% ✓      ║
║  Phase 3: Multi-Tenancy               [████████████████████] 100% ✓      ║
║  Phase 4: Agent Management            [████████████████████] 100% ✓      ║
║  Phase 5: Tool Management             [████████████████████] 100% ✓      ║
║  Phase 6: Conversation API            [░░░░░░░░░░░░░░░░░░░░]   0% ← NOW  ║
║  Phase 7: Document Management         [░░░░░░░░░░░░░░░░░░░░]   0%        ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  EXECUTION PLANE (FastAPI/Python)                      0.00% (0/2)       ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  Phase 8: LangGraph Service           [░░░░░░░░░░░░░░░░░░░░]   0%        ║
║  Phase 9: MCP Integration Layer       [░░░░░░░░░░░░░░░░░░░░]   0%        ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  FRONTEND & INFRASTRUCTURE                             0.00% (0/2)       ║
╠═══════════════════════════════════════════════════════════════════════════╣
║  Phase 10: React Flow UI              [░░░░░░░░░░░░░░░░░░░░]   0%        ║
║  Phase 11: Production Deployment      [░░░░░░░░░░░░░░░░░░░░]   0%        ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                    8-LAYER ARCHITECTURE OVERVIEW                          ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  ┌─────────────────────────────────────────────────────────────────┐     ║
║  │ LAYER 1: Frontend (React)                          [Phase 10]   │     ║
║  │ • Flow Authoring UI  • Chat Interface  • Admin Panel            │     ║
║  └─────────────────────────────────────────────────────────────────┘     ║
║                                   │                                       ║
║                                   ▼                                       ║
║  ┌─────────────────────────────────────────────────────────────────┐     ║
║  │ LAYER 2: Proxy & Routing (Nginx)                   [Phase 11]   │     ║
║  │ • SSL/TLS  • Load Balancing  • Multi-tenant Routing             │     ║
║  └─────────────────────────────────────────────────────────────────┘     ║
║                                   │                                       ║
║                    ┌──────────────┴──────────────┐                        ║
║                    ▼                             ▼                        ║
║  ┌──────────────────────────────┐   ┌───────────────────────────┐        ║
║  │ LAYER 3: Control Plane       │   │ LAYER 4: Execution Plane  │        ║
║  │ NestJS/TypeScript   ✓ DONE   │   │ FastAPI/Python            │        ║
║  │ • Agent CRUD                 │   │ • LangGraph Runtime       │        ║
║  │ • Tool Config                │◄──┤ • Tool Execution          │        ║
║  │ • User/Tenant Mgmt           │──►│ • Streaming Responses     │        ║
║  │ • Metadata Storage           │   │ • State Management        │        ║
║  │ Phases: 1,2,3,4 (COMPLETE)   │   │ Phases: 8,9 (TODO)        │        ║
║  └──────────────────────────────┘   └───────────────────────────┘        ║
║                    │                             │                        ║
║                    └──────────────┬──────────────┘                        ║
║                                   ▼                                       ║
║  ┌─────────────────────────────────────────────────────────────────┐     ║
║  │ LAYER 5: Event Layer (Kafka/RabbitMQ)              [Future]     │     ║
║  │ • Webhooks  • Scheduled Tasks  • External Triggers              │     ║
║  └─────────────────────────────────────────────────────────────────┘     ║
║                                   │                                       ║
║                                   ▼                                       ║
║  ┌─────────────────────────────────────────────────────────────────┐     ║
║  │ LAYER 6: Integration Layer (MCP Servers)           [Phase 9]    │     ║
║  │ • KB Search  • Ticketing  • LLM Gateway  • Notifications        │     ║
║  └─────────────────────────────────────────────────────────────────┘     ║
║                                   │                                       ║
║                                   ▼                                       ║
║  ┌─────────────────────────────────────────────────────────────────┐     ║
║  │ LAYER 7: Memory & Storage                       ✓ Phase 2 DONE │     ║
║  │ • PostgreSQL (metadata)  • Redis (state)  • Qdrant (vectors)    │     ║
║  │ • MinIO (documents)                                              │     ║
║  └─────────────────────────────────────────────────────────────────┘     ║
║                                   │                                       ║
║                                   ▼                                       ║
║  ┌─────────────────────────────────────────────────────────────────┐     ║
║  │ LAYER 8: Core Services                             [Phase 11]   │     ║
║  │ • Keycloak (Auth)  • Prometheus (Metrics)  • ELK (Logs)         │     ║
║  └─────────────────────────────────────────────────────────────────┘     ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

```
CONTROL PLANE (NestJS):
Phase 1: ████████████████████ 100%  Complete  Foundation
Phase 2: ████████████████████ 100%  Complete  Database Schema
Phase 3: ████████████████████ 100%  Complete  Multi-Tenancy
Phase 4: ████████████████████ 100%  Complete  Agent Management
Phase 5: ████████████████████ 100%  Complete  Tool Management
Phase 6: ░░░░░░░░░░░░░░░░░░░░   0%  Current   Conversation API
Phase 7: ░░░░░░░░░░░░░░░░░░░░   0%  Planned   Document Management

EXECUTION PLANE (FastAPI):
Phase 8: ░░░░░░░░░░░░░░░░░░░░   0%  Planned   LangGraph Service
Phase 9: ░░░░░░░░░░░░░░░░░░░░   0%  Planned   MCP Integration Layer

FRONTEND & INFRA:
Phase 10: ░░░░░░░░░░░░░░░░░░░  0%  Planned   React Flow Authoring UI
Phase 11: ░░░░░░░░░░░░░░░░░░░  0%  Planned   Production Deployment
```

**Overall Progress:** 36.36% (4 of 11 phases complete)  
**Control Plane Progress:** 57.14% (4 of 7 phases)  
**Execution Plane Progress:** 0% (0 of 2 phases)  
**Frontend Progress:** 0% (0 of 2 phases)

---

## CONTROL PLANE PHASES (NestJS/TypeScript)

## Phase 1: Foundation Setup
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
-  `docker-compose.yml` - Infrastructure as code
-  `tsconfig.json` - TypeScript settings
-  `src/main.ts` - NestJS bootstrap
-  `src/controllers/app.controller.ts` - Health check
-  `.env` - Environment variables

### Key Decisions
- **NestJS over Express:** Chosen for dependency injection, decorators, and enterprise patterns
- **PostgreSQL over MongoDB:** Relational data with JSONB for flexible workflow storage
- **Docker first:** Ensures consistent dev environment across team

### Validation Criteria
-  Server starts on port 3000
-  Swagger UI accessible at `/api`
-  PostgreSQL container running on port 5432
-  Redis container running on port 6379
-  Health check returns 200 OK

---

##  Phase 2: Database Schema & ORM
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
-  `prisma/schema.prisma` - Complete data model
-  `prisma/migrations/20251106022522_ai_platform_schema/` - Migration files
-  `src/services/prisma.service.ts` - Database connection singleton

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
-  Migration applied: `npx prisma migrate status`
-  All 7 tables created in PostgreSQL
-  Prisma Studio shows tables: `npm run db:studio`
-  No TypeScript compilation errors

---

##  Phase 3: Multi-Tenancy Foundation
**Status:** Complete  
**Completed:** November 10, 2025  
**Time Spent:** 4 hours

### Subphases

#### Phase 3.1: TenantGuard Security Layer 
- [x] Create `src/guards/tenant.guard.ts`
- [x] Implement `CanActivate` interface
- [x] Validate `X-Tenant-Id` header
- [x] Database lookup for tenant verification
- [x] Attach tenant object to request
- [x] Error handling (400 for missing, 403 for invalid)
- [x] Documentation: `TENANT_GUARD_EXPLANATION.md`

#### Phase 3.2: Tenants CRUD Module 
- [x] Create `src/tenants/` module structure
- [x] Implement TenantsController (5 endpoints)
- [x] Implement TenantsService with business logic
- [x] Create DTOs with validation
  - `create-tenant.dto.ts` - name (required), plan (optional)
  - `update-tenant.dto.ts` - partial updates
- [x] Register module in `app.module.ts`
- [x] Swagger documentation

#### Phase 3.3: Apply Tenant Isolation 
- [x] Apply `@UseGuards(TenantGuard)` to UsersController
- [x] Update UsersService to accept `tenantId` parameter
- [x] Add `where: { tenantId }` filters to Prisma queries
- [x] Test tenant isolation
- [x] Update Swagger docs with security requirements

### Deliverables
-  `src/guards/tenant.guard.ts` - Security middleware
-  `src/tenants/` - Complete CRUD module
-  `TENANT_GUARD_EXPLANATION.md` - Architecture documentation
-  Updated `src/controllers/users.controller.ts` - Tenant-aware endpoints
-  Updated `src/services/users.service.ts` - Filtered queries

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
-  Can create tenant via POST /tenants
-  Missing X-Tenant-Id returns 400 Bad Request
-  Invalid tenant ID returns 403 Forbidden
-  Valid tenant ID filters data correctly
-  Tenant A cannot see Tenant B's users
-  All DTOs validate input properly

---

## Phase 4: Agent & Flow Management
**Status:** Complete
**Started:** November 11, 2025  
**Completed:** November 13, 2025  
**Time Spent:** 3 hours

### Goals
- [x] Create Agent DTOs (Phase 4.1)
- [x] Implement AgentsService (Phase 4.2)
- [x] Implement AgentsController (Phase 4.3)
- [x] Testing & Validation (Phase 4.4)

### Tasks Breakdown

#### Phase 4.1: Create Agent DTOs
**Time Spent:** 30 minutes  
**Completed:** November 11, 2025

- [x] `src/agents/dto/create-agent.dto.ts` - Validates name, version, flowJson, tenantId
- [x] `src/agents/dto/update-agent.dto.ts` - PartialType for flexible updates
- [x] `src/agents/dto/update-agent-status.dto.ts` - Status enum validation

#### Phase 4.2: Implement AgentsService
**Time Spent:** 1.5 hours  
**Completed:** November 13, 2025

Methods implemented:
- [x] `create()` - Create new agent with duplicate name detection (P2002 error)
- [x] `findAll(tenantId)` - List all agents for tenant with _count.conversations
- [x] `findOne(id, tenantId)` - Get single agent with ownership validation
- [x] `update(id, tenantId, dto)` - Update agent with conflict detection  
- [x] `updateStatus(id, tenantId, status)` - Change agent status (DRAFT/PUBLISHED/DISABLED)
- [x] `remove(id, tenantId)` - Delete agent (prevents deletion if conversations exist)

#### Phase 4.3: Implement AgentsController
**Time Spent:** 45 minutes  
**Completed:** November 13, 2025

Endpoints created:
- [x] POST /agents - Create agent (requires X-Tenant-Id header)
- [x] GET /agents - List agents (tenant-scoped via TenantGuard)
- [x] GET /agents/:id - Get single agent
- [x] PATCH /agents/:id - Update agent
- [x] PATCH /agents/:id/status - Update status only
- [x] DELETE /agents/:id - Delete agent

#### Phase 4.4: Testing & Validation
**Time Spent:** 45 minutes  
**Completed:** November 13, 2025

- [x] Created automated test script `test/test-agents.sh`
- [x] Added VS Code task for running tests
- [x] Validated all 6 endpoints with proper HTTP status codes
- [x] Verified tenant isolation (404 for cross-tenant access)
- [x] Tested duplicate name detection (409 conflict)
- [x] Confirmed conversation count check on deletion
- [x] Verified status transitions (DRAFT to PUBLISHED)

### Deliverables Created
- [x] `src/agents/dto/create-agent.dto.ts`
- [x] `src/agents/dto/update-agent.dto.ts`
- [x] `src/agents/dto/update-agent-status.dto.ts`
- [x] `src/agents/agents.service.ts` - 6 methods, full error handling
- [x] `src/agents/agents.controller.ts` - 6 endpoints with Swagger docs
- [x] `src/agents/agents.module.ts` - Module registration
- [x] `test/test-agents.sh` - Automated test script
- [x] `test/README.md` - Testing documentation
- [x] `.vscode/tasks.json` - Added test task

### API Endpoints Built
```
POST   /agents              - Create new agent workflow
GET    /agents              - List all agents (tenant-scoped)
GET    /agents/:id          - Get agent by ID
PATCH  /agents/:id          - Update agent (name, version, flowJson)
PATCH  /agents/:id/status   - Change status (DRAFT/PUBLISHED/DISABLED)
DELETE /agents/:id          - Delete agent (blocks if conversations exist)
```

### Validation Criteria
- [x] Can create agent via POST /agents
- [x] Agent requires X-Tenant-Id header (400 if missing)
- [x] Duplicate agent name returns 409 Conflict
- [x] flowJson validates with nodes and edges arrays
- [x] Status enum validates (DRAFT/PUBLISHED/DISABLED)
- [x] Tenant isolation: Agent A cannot access Tenant B's agents (404)
- [x] Cannot delete agent with existing conversations
- [x] List agents includes conversation count (_count.conversations)
- [x] Update agent handles partial updates correctly
- [x] Status transitions work (DRAFT to PUBLISHED)

### Key Decisions
- **flowJson Structure:** Stores LangGraph workflow as JSON with nodes (id, type) and edges (from, to)
- **Status Workflow:** DRAFT (editing) to PUBLISHED (production) to DISABLED (archived)
- **Conversation Protection:** Cannot delete agents with active conversations (data integrity)
- **Tenant Guard:** Applied at controller level for automatic multi-tenant filtering
- **Error Handling:** P2002 for duplicates, P2025 for not found, custom NotFoundException for ownership
- **Testing Strategy:** Automated bash script with 10 test scenarios including security validation

---

## Phase 5: Tool Management & Configuration
**Status:** Complete  
**Completed:** November 13, 2025  
**Time Spent:** 3 hours

### Goals
- [x] Create Tools CRUD module
- [x] Implement tool configuration storage
- [x] Define tool types (KB_SEARCH, TICKET_CREATE, SLACK_POST, TEAMS_POST, CUSTOM)
- [x] Secure storage for API keys/credentials (AES-256 encrypted)
- [x] Dynamic input/output schema validation
- [x] Tool testing endpoint

### Deliverables
-  `src/tools/tools.module.ts`
-  `src/tools/tools.service.ts` - Business logic with encryption
-  `src/tools/tools.controller.ts` - 6 REST endpoints
-  `src/tools/dto/create-tool.dto.ts` - Input validation
-  `src/tools/dto/update-tool.dto.ts` - Partial updates
-  `test/test-tools.sh` - Automated testing script

### API Endpoints Built
```
POST   /tools           - Register new tool
GET    /tools           - List available tools (tenant-scoped)
GET    /tools/:id       - Get tool details (with decrypted authConfig)
PATCH  /tools/:id       - Update tool config
DELETE /tools/:id       - Remove tool
POST   /tools/:id/test  - Test tool execution (placeholder for Phase 9)
```

### Key Features Implemented
- **AES-256 Encryption:** Automatic encryption/decryption of sensitive fields (apiKey, token, clientSecret, password, privateKey)
- **Tenant Isolation:** TenantGuard applied to all endpoints
- **Security:** authConfig hidden in list view, only exposed in single-tool GET
- **Error Handling:** Duplicate detection (409), not found (404), ownership validation
- **Testing:** 12 automated tests including security and isolation validation

### Tool Schema Example
```typescript
{
  name: "kb_search_qdrant",
  title: "Knowledge Base Search",
  type: "KB_SEARCH",
  inputSchema: {
    type: "object",
    properties: {
      query: { type: "string" },
      topK: { type: "number" }
    }
  },
  outputSchema: {
    type: "object",
    properties: {
      results: { type: "array" }
    }
  },
  authType: "api_key",
  authConfig: {
    apiUrl: "http://qdrant:6333",
    apiKey: "<encrypted in database>",
    collection: "knowledge_base"
  }
}
```

### Validation Criteria
-  Can create tool via POST /tools
-  API keys encrypted in database using AES-256
-  Tool listing hides sensitive authConfig
-  Single tool GET returns decrypted authConfig
-  Tenant isolation prevents cross-tenant access
-  Duplicate tool names return 409 Conflict
-  Update endpoint handles partial updates
-  Delete endpoint removes tool successfully
-  Test endpoint validates tool ownership (Phase 9: will call MCP)
-  All 12 automated tests passing

---

##  Phase 6: Conversations & Messages API
**Status:** Planned  
**Layer:** Control Plane (NestJS)  
**Target Start:** November 16, 2025  
**Estimated Time:** 3-4 hours

### Goals
- [ ] Create Conversations CRUD module
- [ ] Create Messages CRUD module
- [ ] Link conversations to agents
- [ ] Track message history (USER/ASSISTANT/SYSTEM roles)
- [ ] Conversation status management (ACTIVE/COMPLETED/ARCHIVED)
- [ ] Integration with Redis for session state

### Deliverables
- `src/conversations/conversations.module.ts`
- `src/conversations/conversations.service.ts`
- `src/conversations/conversations.controller.ts`
- `src/messages/messages.service.ts`
- `src/messages/dto/` - DTOs

### API Endpoints to Build
```
POST   /conversations              - Start new conversation
GET    /conversations              - List conversations (tenant-scoped)
GET    /conversations/:id          - Get conversation with messages
PATCH  /conversations/:id          - Update conversation metadata
DELETE /conversations/:id          - Archive conversation

POST   /conversations/:id/messages - Add message (triggers FastAPI execution)
GET    /conversations/:id/messages - Get message history (paginated)
```

### Integration Point
- **NestJS → FastAPI:** When message is posted, NestJS calls FastAPI `/execute` endpoint
- **FastAPI → NestJS:** FastAPI saves assistant response back to NestJS via callback

---

##  Phase 7: Document Management & Vector Search
**Status:** Planned  
**Layer:** Control Plane (NestJS) + Integration (MCP)  
**Target Start:** November 18, 2025  
**Estimated Time:** 4-5 hours

### Goals
- [ ] Create Documents CRUD module
- [ ] File upload handling (multipart/form-data)
- [ ] Document chunking service
- [ ] Embedding generation (via MCP server or OpenAI)
- [ ] Vector database integration (Pinecone/Qdrant/Weaviate)
- [ ] Semantic search API

### Deliverables
- `src/documents/documents.module.ts`
- `src/documents/documents.service.ts`
- `src/documents/documents.controller.ts`
- `src/documents/chunking.service.ts`
- MinIO or local file storage setup

### API Endpoints to Build
```
POST   /documents         - Upload document
GET    /documents         - List documents (tenant-scoped)
GET    /documents/:id     - Get document metadata
DELETE /documents/:id     - Delete document + embeddings
POST   /documents/search  - Semantic search across documents
```

### Technical Stack
- **Storage:** MinIO (S3-compatible) for file storage
- **Vector DB:** Qdrant or Pinecone for embeddings
- **Chunking:** LangChain.js text splitters
- **Embeddings:** OpenAI API or local model

---

## EXECUTION PLANE PHASES (FastAPI/Python)

##  Phase 8: LangGraph Execution Service
**Status:** Planned  
**Layer:** Execution Plane (FastAPI/Python)  
**Target Start:** November 20, 2025  
**Estimated Time:** 6-8 hours

### Goals
- [ ] Set up FastAPI Python project
- [ ] Install LangGraph + LangChain libraries
- [ ] Implement workflow executor
- [ ] HTTP endpoints for execution
- [ ] Redis integration for conversation state
- [ ] PostgreSQL read access for agent definitions
- [ ] Streaming responses via Server-Sent Events

### Deliverables
- `langgraph-service/` directory
- `langgraph-service/main.py` - FastAPI app
- `langgraph-service/executor.py` - LangGraph runner
- `langgraph-service/requirements.txt` - Dependencies
- `docker-compose.yml` - Add FastAPI service

### API Endpoints to Build
```python
POST   /execute        - Run agent workflow (sync)
POST   /stream         - Run workflow with SSE streaming
POST   /validate       - Validate flowJson structure
GET    /health         - Service health check
```

### Execution Flow
1. NestJS sends `POST /execute` with `{ agentId, conversationId, message }`
2. FastAPI loads agent's `flowJson` from PostgreSQL
3. FastAPI builds LangGraph StateGraph from JSON
4. FastAPI executes workflow with LangChain
5. FastAPI calls tools via NestJS `/tools/:id/execute` endpoint
6. FastAPI saves conversation state to Redis
7. FastAPI returns assistant response
8. FastAPI calls NestJS `POST /conversations/:id/messages` to save response

### Example LangGraph Workflow
```python
from langgraph.graph import StateGraph, END
from typing import TypedDict

class SupportState(TypedDict):
    query: str
    kb_result: str
    feedback: str
    ticket_id: str

def kb_lookup(state):
    # Call NestJS /tools/{kb_tool_id}/execute
    return state

def create_ticket(state):
    # Call NestJS /tools/{ticket_tool_id}/execute
    return state

graph = StateGraph(SupportState)
graph.add_node("kb_lookup", kb_lookup)
graph.add_node("create_ticket", create_ticket)
# ... rest of flow definition
```

### Docker Setup
```yaml
# Add to docker-compose.yml
langgraph-service:
  build: ./langgraph-service
  ports:
    - "8000:8000"
  environment:
    - DATABASE_URL=postgresql://...
    - REDIS_URL=redis://...
    - NEST_API_URL=http://nestjs-api:3000
  depends_on:
    - postgres
    - redis
```

---

##  Phase 9: MCP Integration Layer
**Status:** Planned  
**Layer:** Integration (FastAPI Microservices)  
**Target Start:** November 23, 2025  
**Estimated Time:** 6-8 hours

### Goals
- [ ] Build KB Search MCP server (FastAPI + Elasticsearch/Qdrant)
- [ ] Build Ticketing MCP server (FastAPI + Zammad API)
- [ ] Build Slack/Teams notification MCP server
- [ ] Build LLM Gateway MCP server (OpenAI/Ollama)
- [ ] Implement tool authentication/authorization
- [ ] Rate limiting and error handling

### Deliverables
- `mcp-kb-search/` - Knowledge base search microservice
- `mcp-ticketing/` - Ticket creation microservice
- `mcp-notifications/` - Slack/Teams notifications
- `mcp-llm-gateway/` - LLM proxy service
- Updated `docker-compose.yml` with all MCP services

### MCP Server: KB Search
```python
# mcp-kb-search/main.py
from fastapi import FastAPI
from qdrant_client import QdrantClient

app = FastAPI()
qdrant = QdrantClient(host="qdrant", port=6333)

@app.post("/search")
async def search_kb(query: str, tenant_id: str, top_k: int = 5):
    # Vector search in Qdrant with tenant filter
    results = qdrant.search(
        collection_name=f"kb_{tenant_id}",
        query_vector=get_embedding(query),
        limit=top_k
    )
    return {"results": results}
```

### MCP Server: Ticketing (Zammad)
```python
# mcp-ticketing/main.py
from fastapi import FastAPI
import httpx

app = FastAPI()

@app.post("/create_ticket")
async def create_ticket(
    tenant_id: str,
    title: str,
    description: str,
    group: str
):
    # Get Zammad config for tenant from NestJS
    config = await get_tenant_tool_config(tenant_id, "TICKET_CREATE")
    
    # Call Zammad API
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{config['apiUrl']}/tickets",
            headers={"Authorization": f"Bearer {config['apiKey']}"},
            json={"title": title, "body": description, "group": group}
        )
    return response.json()
```

### Architecture Diagram
```
LangGraph Service → MCP KB Search → Qdrant Vector DB
                 → MCP Ticketing → Zammad API
                 → MCP LLM Gateway → OpenAI/Ollama
                 → MCP Notifications → Slack/Teams API
```

---

## FRONTEND & INFRASTRUCTURE PHASES

##  Phase 10: React Flow Authoring UI
**Status:** Planned  
**Layer:** Frontend (React/TypeScript)  
**Target Start:** November 26, 2025  
**Estimated Time:** 8-10 hours

### Goals
- [ ] Create React app with Vite
- [ ] Visual flow builder (React Flow library)
- [ ] Drag-and-drop node editor
- [ ] Convert visual graph to LangGraph JSON
- [ ] Agent management UI (list, create, edit)
- [ ] Tool configuration UI
- [ ] Chat interface for testing agents
- [ ] Authentication UI (login/register)

### Tech Stack
- **Framework:** React 18 + TypeScript
- **Build:** Vite
- **UI Library:** Shadcn/ui + Tailwind CSS
- **Flow Editor:** React Flow (visual graph editor)
- **State:** Zustand or Jotai
- **API Client:** TanStack Query (React Query)

### Pages to Build
1. **Dashboard** - Overview of agents, conversations, tools
2. **Flow Builder** - Visual LangGraph editor
3. **Agent Manager** - List/Create/Edit agents
4. **Tool Manager** - Configure integrations
5. **Conversations** - View conversation history
6. **Documents** - Upload and manage KB documents
7. **Settings** - Tenant settings, API keys

### Flow Builder Features
- Drag-and-drop nodes (KB Lookup, Ticket Create, Conditional, etc.)
- Connect nodes with edges
- Configure node parameters (forms)
- Validate graph structure
- Export to `flowJson` format
- Import existing flows
- Test execution in playground

---

##  Phase 11: Production Deployment & DevOps
**Status:** Planned  
**Layer:** Infrastructure (Kubernetes/Docker/CI/CD)  
**Target Start:** December 1, 2025  
**Estimated Time:** 6-8 hours

### Goals
- [ ] Kubernetes deployment manifests
- [ ] Helm charts for easy deployment
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Multi-environment setup (dev/staging/prod)
- [ ] Database migrations in production
- [ ] Secrets management (Vault or K8s Secrets)
- [ ] Monitoring setup (Prometheus + Grafana)
- [ ] Logging setup (ELK or Loki)
- [ ] SSL/TLS certificates (Let's Encrypt)
- [ ] Nginx Ingress for routing

### Infrastructure Stack
- **Container Orchestration:** Kubernetes (GKE/EKS/AKS or self-hosted)
- **Reverse Proxy:** Nginx Ingress Controller
- **Auth:** Keycloak (OAuth2/OIDC)
- **Monitoring:** Prometheus + Grafana
- **Logging:** ELK Stack (Elasticsearch, Logstash, Kibana)
- **Secrets:** Sealed Secrets or HashiCorp Vault
- **CI/CD:** GitHub Actions

### Deployment Architecture
```
┌─────────────────────────────────────────────────┐
│  Nginx Ingress (SSL Termination)                │
│  *.aiplatform.com → Route by subdomain          │
├─────────────────────────────────────────────────┤
│  Frontend (React SPA)                           │
│  Static hosting via Nginx                       │
├─────────────────────────────────────────────────┤
│  NestJS API (3 replicas)                        │
│  HPA: Scale 1-10 based on CPU                   │
├─────────────────────────────────────────────────┤
│  FastAPI LangGraph Service (2 replicas)         │
│  HPA: Scale 1-5 based on requests               │
├─────────────────────────────────────────────────┤
│  MCP Services (1 replica each)                  │
│  KB Search | Ticketing | LLM Gateway            │
├─────────────────────────────────────────────────┤
│  Data Layer                                     │
│  PostgreSQL (StatefulSet) | Redis (StatefulSet) │
│  Qdrant (Vector DB) | MinIO (Object Storage)    │
├─────────────────────────────────────────────────┤
│  Observability                                  │
│  Prometheus | Grafana | ELK | Jaeger (tracing) │
└─────────────────────────────────────────────────┘
```

---

## Development Workflow & Checklists

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

## Quick Reference: What to Build When

### Now (November 13-14): Complete Control Plane Foundation
- ✅ Phase 4: Finish Agent CRUD (3 more tasks)
- ⏭️ Phase 5: Tool Management (4 hours)
- ⏭️ Phase 6: Conversations API (4 hours)
- ⏭️ Phase 7: Document Management (5 hours)

**Milestone:** NestJS control plane complete = Full REST API for metadata

---

### Next (November 20-25): Build Execution Plane
- ⏭️ Phase 8: FastAPI + LangGraph Service (8 hours)
- ⏭️ Phase 9: MCP Integration Layer (8 hours)

**Milestone:** Working end-to-end KB→Ticket flow execution

---

### Later (November 26+): Frontend & Production
- ⏭️ Phase 10: React Flow Authoring UI (10 hours)
- ⏭️ Phase 11: Production Deployment (8 hours)

**Milestone:** Full production-ready AI platform

---

## 📊 Success Metrics

### Code Quality
- [ ] All endpoints have Swagger documentation
- [ ] All DTOs use class-validator
- [ ] All services have error handling
- [ ] TypeScript strict mode with no errors
- [ ] Python type hints for all FastAPI endpoints
- [ ] No console.log statements (use Logger)

### Testing
- [ ] Manual testing via Swagger UI
- [ ] Test tenant isolation for all modules
- [ ] Test error cases (400, 403, 404, 409)
- [ ] Test with multiple tenants simultaneously
- [ ] End-to-end flow execution tests

### Documentation
- [ ] Code has JSDoc/docstring comments
- [ ] README.md reflects current features
- [ ] Each phase has explanation doc
- [ ] API examples in documentation
- [ ] Architecture diagrams updated

---

**Last Updated:** November 13, 2025  
**Next Review:** After Phase 4 completion  
**Maintained By:** Development Team
