# Full Stack Architecture - 8-Layer AI Platform

**Last Updated:** November 13, 2025  
**Architecture Type:** Microservices with Control Plane + Execution Plane  
**Stack:** NestJS (Node.js) + FastAPI (Python) + React (TypeScript)

---

## Executive Summary

This platform implements a **multi-tenant AI authoring and execution system** using an 8-layer architecture:

- **Control Plane (NestJS):** Metadata management, CRUD operations, security
- **Execution Plane (FastAPI):** LangGraph workflow execution, tool orchestration
- **Frontend (React):** Visual flow authoring, chat interface, admin panel
- **Infrastructure:** Multi-tenant routing, event streaming, monitoring

---

## Architecture Diagram

```
┌───────────────────────────────────────────────────────────────┐
│                     USER INTERFACES                            │
│  React Flow Builder | Chat UI | Admin Panel                   │
└────────────────────┬──────────────────────────────────────────┘
                     │
┌────────────────────▼──────────────────────────────────────────┐
│              NGINX/TRAEFIK (Layer 2)                          │
│  Multi-tenant Routing | Load Balancing | SSL                  │
└────────┬────────────────────────────┬──────────────────────────┘
         │                            │
┌────────▼────────────────┐  ┌───────▼──────────────────────────┐
│   CONTROL PLANE (L3)    │  │   EXECUTION PLANE (L4)           │
│   NestJS/TypeScript     │  │   FastAPI/Python                 │
├─────────────────────────┤  ├──────────────────────────────────┤
│ - Agents CRUD           │  │ - LangGraph Runtime              │
│ - Tools CRUD            │  │ - Workflow Execution             │
│ - Conversations CRUD    │  │ - Streaming Responses (SSE)      │
│ - Documents CRUD        │  │ - State Management               │
│ - Users & Auth          │  │ - Tool Orchestration             │
│ - Multi-tenant Guard    │  │                                  │
│ - JWT Authentication    │  │  Calls NestJS for:               │
│ - Swagger API Docs      │  │  - Agent definitions             │
│                         │  │  - Tool execution                │
│  Exposes REST API       │  │  - Save messages                 │
└────────┬────────────────┘  └───────┬──────────────────────────┘
         │                           │
         │    ┌──────────────────────▼──────────────────────┐
         │    │     MCP INTEGRATION LAYER (L6)              │
         │    │     FastAPI Microservices                   │
         │    ├─────────────────────────────────────────────┤
         │    │ KB Search  │ Ticketing │ LLM    │ Slack    │
         │    │ (Qdrant)   │ (Zammad)  │Gateway │/Teams    │
         │    └──────────────────────────────────────────────┘
         │
┌────────▼──────────────────────────────────────────────────────┐
│             MEMORY & STORAGE LAYER (L7)                       │
├───────────────────────┬──────────────┬────────────────────────┤
│  PostgreSQL           │  Redis       │  MinIO (S3)            │
│  - Agents (flowJson)  │  - Sessions  │  - Documents           │
│  - Tools (configs)    │  - Conv State│  - Templates           │
│  - Conversations      │  - Cache     │  - Uploads             │
│  - Messages           │              │                        │
│  - Users, Tenants     │  Qdrant      │  Git (Gitea)           │
│  - Documents metadata │  - Vectors   │  - Version Control     │
└───────────────────────┴──────────────┴────────────────────────┘
         │
┌────────▼──────────────────────────────────────────────────────┐
│             CORE SERVICES LAYER (L8)                          │
├───────────────┬──────────────────┬────────────────────────────┤
│  Keycloak     │  Prometheus      │  ELK Stack                 │
│  - OAuth2     │  + Grafana       │  - Logs                    │
│  - Multi-     │  - Metrics       │  - Analytics               │
│    tenant     │  - Monitoring    │  - Search                  │
└───────────────┴──────────────────┴────────────────────────────┘
```

---

## What Each Component Does

### Layer 3: Control Plane (NestJS)

**Purpose:** Metadata management and API gateway

**Responsibilities:**
- Store agent definitions (`flowJson` field contains LangGraph workflow)
- Manage tools, users, tenants, conversations
- Handle authentication (JWT) and authorization (RBAC)
- Multi-tenant isolation via `TenantGuard`
- Trigger FastAPI execution
- Store conversation results

**Technology:**
- NestJS 11.1.7 (TypeScript)
- Prisma ORM
- PostgreSQL for data persistence
- Swagger/OpenAPI for API docs
- class-validator for DTOs

**Example API Flow:**
```
User creates agent via React UI
 → POST /agents { name, version, flowJson }
 → NestJS validates DTO
 → NestJS stores to PostgreSQL
 → Returns agent ID
```

---

### Layer 4: Execution Plane (FastAPI)

**Purpose:** Execute LangGraph workflows

**Responsibilities:**
- Load agent `flowJson` from NestJS API
- Build LangGraph StateGraph from JSON
- Execute workflow with user message
- Call tools via NestJS tool endpoints
- Save conversation state to Redis
- Stream responses via Server-Sent Events
- Handle errors and retries

**Technology:**
- FastAPI (Python 3.11+)
- LangGraph (LangChain)
- Redis for session state
- httpx for HTTP calls to NestJS

**Example Execution Flow:**
```
User sends chat message
 → NestJS POST /conversations/:id/messages
 → NestJS calls FastAPI POST /execute
 → FastAPI loads flowJson from NestJS
 → FastAPI builds LangGraph
 → Executes: KB Lookup → Ticket Create → Slack Notify
 → Each tool calls NestJS POST /tools/:id/execute
 → FastAPI saves response to Redis
 → FastAPI calls NestJS to save assistant message
 → Returns response to user
```

---

### Layer 6: MCP Integration Layer

**Purpose:** External integrations as microservices

**Components:**

#### 1. KB Search Service
- **Tech:** FastAPI + Qdrant (vector DB)
- **Endpoint:** `POST /search`
- **Function:** Semantic search in knowledge base
- **Input:** Query text, tenant ID, top K
- **Output:** Ranked document chunks

#### 2. Ticketing Service
- **Tech:** FastAPI + Zammad API client
- **Endpoint:** `POST /create_ticket`
- **Function:** Create support tickets
- **Input:** Title, description, group, tenant config
- **Output:** Ticket ID, URL

#### 3. LLM Gateway
- **Tech:** FastAPI + OpenAI/Ollama
- **Endpoint:** `POST /chat/completions`
- **Function:** Proxy to LLM with rate limiting
- **Input:** Messages, model, tenant ID
- **Output:** LLM response

#### 4. Notification Service
- **Tech:** FastAPI + Slack/Teams SDK
- **Endpoint:** `POST /notify`
- **Function:** Send messages to Slack/Teams
- **Input:** Channel, message, tenant webhook
- **Output:** Message ID

---

### Layer 7: Memory & Storage

**PostgreSQL:**
- Durable storage for all entities
- 7 models: Tenant, User, Agent, Tool, Conversation, Message, Document
- Stores `flowJson` (JSONB) for workflows
- Stores tool configs (encrypted API keys)

**Redis:**
- Conversation session state (fast access)
- Cache for frequently accessed data
- Token blacklist for logout
- Rate limiting counters

**MinIO (S3-compatible):**
- Document file storage
- Template storage
- Version control for flows

**Qdrant (Vector DB):**
- Document embeddings for semantic search
- Tenant-scoped collections

**Gitea (Self-hosted Git):**
- Version control for agent flows
- Branching and rollback for workflows

---

### Layer 8: Core Services

**Keycloak:**
- OAuth2/OIDC authentication
- Multi-tenant user management
- SSO for enterprise customers
- Role-based access control

**Prometheus + Grafana:**
- Metrics collection from all services
- Dashboards for performance monitoring
- Alerts for errors/downtime

**ELK Stack:**
- Centralized logging
- Log search and analytics
- Conversation history analysis

---

## Data Flow: End-to-End Example

### Scenario: User asks question → KB lookup → Create ticket

```
1. User types "How do I reset my password?" in chat UI
   
2. React Frontend
   → POST /conversations/:id/messages
   → Body: { role: "USER", content: "How do I..." }
   
3. NestJS Control Plane
   → Saves message to PostgreSQL
   → Calls FastAPI: POST /execute
   → Body: { agentId, conversationId, message }
   
4. FastAPI Execution Plane
   → Loads agent from NestJS: GET /agents/:id
   → Parses flowJson into LangGraph StateGraph
   → Executes workflow:
   
   4a. KB Lookup Node
       → Calls NestJS: POST /tools/{kb_tool_id}/execute
       → NestJS calls MCP KB Search: POST /search
       → Qdrant returns top 3 docs
       → LangGraph receives KB results
   
   4b. Feedback Check Node
       → LLM determines KB didn't help
       → Routes to ticket creation
   
   4c. Ticket Creation Node
       → Calls NestJS: POST /tools/{ticket_tool_id}/execute
       → NestJS calls MCP Ticketing: POST /create_ticket
       → Zammad API creates ticket #12345
       → LangGraph receives ticket ID
   
   4d. Slack Notification Node
       → Calls NestJS: POST /tools/{slack_tool_id}/execute
       → NestJS calls MCP Notifications: POST /notify
       → Slack receives message in #support channel
   
5. FastAPI saves state to Redis
   → Key: conversation:{conversationId}:state
   → Value: { ticket_id: "12345", ... }
   
6. FastAPI calls NestJS to save assistant response
   → POST /conversations/:id/messages
   → Body: { role: "ASSISTANT", content: "I created ticket #12345..." }
   
7. NestJS returns response to React UI
   → User sees: "I created ticket #12345 for you."
```

---

## Technology Stack Summary

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | React + TypeScript + Vite | Flow builder, chat UI, admin |
| Proxy | Nginx/Traefik | Routing, SSL, load balancing |
| Control Plane | NestJS + TypeScript | Metadata CRUD, security, orchestration |
| Execution Plane | FastAPI + Python | LangGraph runtime, workflow execution |
| Event Layer | Kafka/RabbitMQ | Event streaming, webhooks |
| Integration | FastAPI microservices | MCP servers for tools |
| Database | PostgreSQL 16 | Relational data, JSONB for flows |
| Cache | Redis 7 | Sessions, state, cache |
| Object Storage | MinIO | Documents, templates |
| Vector DB | Qdrant | Semantic search embeddings |
| Version Control | Gitea | Git for flow versioning |
| Auth | Keycloak | OAuth2, multi-tenancy |
| Monitoring | Prometheus + Grafana | Metrics, dashboards |
| Logging | ELK Stack | Centralized logs, analytics |

---

## Why This Architecture?

### Separation of Concerns
- **NestJS handles metadata** → What agents exist, what tools are configured
- **FastAPI handles execution** → Actually run the LangGraph workflows
- **MCP handles integrations** → Isolated services for KB, tickets, LLMs

### Scalability
- Control plane and execution plane scale independently
- MCP services can be replicated per tenant
- Stateless services (NestJS, FastAPI) behind load balancer

### Technology Fit
- **LangGraph requires Python** → Must use FastAPI for execution
- **NestJS excels at CRUD APIs** → Perfect for control plane
- **React for rich UIs** → Visual flow builder needs component library

### Multi-Tenancy
- Tenant isolation at every layer
- Each tenant has own:
  - Database rows (filtered by tenantId)
  - Redis keys (namespaced)
  - Qdrant collection
  - Tool configurations

---

## Security Model

### Authentication Flow
```
1. User logs in → Keycloak issues JWT
2. JWT contains: userId, tenantId, roles
3. React stores JWT in httpOnly cookie
4. Every API call includes JWT in Authorization header
5. NestJS validates JWT signature
6. NestJS extracts tenantId from JWT
7. TenantGuard ensures user belongs to tenant
8. Service layer filters all queries by tenantId
```

### Tenant Isolation
- **Database:** WHERE tenantId = :tenantId on ALL queries
- **Redis:** Keys prefixed with tenant:{tenantId}:*
- **Qdrant:** Separate collections per tenant
- **MinIO:** Buckets per tenant
- **MCP:** Tenant ID required for all tool calls

### Secrets Management
- API keys encrypted in PostgreSQL (AES-256)
- Environment variables for service credentials
- Kubernetes Secrets or Vault in production

---

## Next Steps

1. **Finish Control Plane (NestJS)** → Phases 4-7
2. **Build Execution Plane (FastAPI)** → Phases 8-9
3. **Build Frontend (React)** → Phase 10
4. **Deploy to Production (Kubernetes)** → Phase 11

---

**Document Owner:** Development Team  
**Related Docs:** `ROADMAP.md`, `PHASE_X_GUIDE.md`, `README.md`
