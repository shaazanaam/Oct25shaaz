# Phase 4: Agent & Flow Management

**Status:** COMPLETE  
**Completed:** November 13, 2025  
**Time Spent:** 3 hours  
**Progress:** 100%

---

## What Was Built

A complete **Agents module** that stores and manages LangGraph AI workflow definitions.

### Key Concept:
An "Agent" is a **reusable AI workflow** stored as JSON in the database. Think of it like:
- A recipe for how the AI should behave
- A flowchart that AI follows
- A blueprint for conversation logic

### Example Use Case:
```
Agent: "IT Support Bot v1.0"
├── Step 1: Search knowledge base
├── Step 2: Ask user for feedback
└── Step 3: If negative → Create ticket
```

---

## What Was Created

### Files Built (9 files):

```
src/agents/
├── agents.module.ts              # Module registration - COMPLETE
├── agents.controller.ts          # 6 CRUD endpoints - COMPLETE
├── agents.service.ts             # 6 business logic methods - COMPLETE
└── dto/
    ├── create-agent.dto.ts       # Input validation - COMPLETE
    ├── update-agent.dto.ts       # Update validation - COMPLETE
    └── update-agent-status.dto.ts # Status change validation - COMPLETE

test/
├── test-agents.sh                # Automated test script - COMPLETE
└── README.md                     # Testing docs - COMPLETE

.vscode/
└── tasks.json                    # VS Code test task - COMPLETE
```

---

## Database Schema (Already Exists)

Your Prisma schema already has the Agent model:

```prisma
model Agent {
  id        String      @id @default(cuid())
  name      String
  version   String      @default("0.1.0")
  status    AgentStatus @default(DRAFT)  // DRAFT | PUBLISHED | DISABLED
  flowJson  Json        // ← LangGraph workflow stored here!
  tenantId  String
  tenant    Tenant      @relation(...)
  createdAt DateTime    @default(now())
  updatedAt DateTime    @updatedAt
  
  conversations Conversation[]
}

enum AgentStatus {
  DRAFT      // Being edited, not live
  PUBLISHED  // Active and answering users
  DISABLED   // Turned off
}
```

---

## Key Features to Implement

### 1. CRUD Operations
- Create new agent workflow
- List all agents for a tenant
- Get single agent by ID
- Update agent (name, version, flowJson)
- Change agent status (DRAFT → PUBLISHED)
- Delete agent

### 2. Tenant Isolation
- Apply `TenantGuard` (like you did for Users)
- Filter agents by `tenantId`
- Each tenant sees only THEIR agents

### 3. Version Management
- Store version number (e.g., "1.0.0", "1.1.0")
- Allow updating version when flow changes
- Track when agents were last modified

### 4. Status Control
- DRAFT - Agent being built, not live
- PUBLISHED - Active agent answering real users
- DISABLED - Temporarily turned off

---

## Step-by-Step Plan

### Phase 4.1: Create DTOs (20 min)

#### File 1: `create-agent.dto.ts`
**Validates:**
- `name` (required, string) - "IT Support Bot"
- `version` (optional, string) - "1.0.0" (defaults to "0.1.0")
- `flowJson` (required, object) - The LangGraph workflow
- `tenantId` (required, string) - Which tenant owns this

**Example:**
```typescript
export class CreateAgentDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  version?: string;

  @IsObject()
  @IsNotEmpty()
  flowJson: object;

  @IsString()
  @IsNotEmpty()
  tenantId: string;
}
```

#### File 2: `update-agent.dto.ts`
**All fields optional** (partial updates)

#### File 3: `update-agent-status.dto.ts`
**Validates status changes:**
```typescript
export class UpdateAgentStatusDto {
  @IsEnum(['DRAFT', 'PUBLISHED', 'DISABLED'])
  status: string;
}
```

---

### Phase 4.2: Create Service (30 min)

#### File: `agents.service.ts`

**Methods to implement:**

```typescript
async create(createAgentDto) {
  // Create new agent
  // Handle duplicate name errors
}

async findAll(tenantId: string) {
  // List all agents for tenant
  // Include conversation count
  // Order by updatedAt desc
}

async findOne(id: string, tenantId: string) {
  // Get single agent
  // Verify belongs to tenant
  // Return 404 if not found
}

async update(id: string, tenantId: string, updateAgentDto) {
  // Update agent properties
  // Validate ownership
}

async updateStatus(id: string, tenantId: string, status: string) {
  // Change agent status
  // Validate: Can't publish if flowJson is invalid
}

async remove(id: string, tenantId: string) {
  // Delete agent
  // Check if has active conversations
  // Cascade delete conversations
}
```

**Key considerations:**
- Always filter by `tenantId` (security!)
- Include `_count` for conversations
- Validate flowJson is proper JSON
- Handle Prisma errors (P2002, P2025)

---

### Phase 4.3: Create Controller (20 min)

#### File: `agents.controller.ts`

**Endpoints:**
```typescript
POST   /agents                    // Create new agent
GET    /agents                    // List all agents (tenant-scoped)
GET    /agents/:id                // Get single agent
PATCH  /agents/:id                // Update agent
PATCH  /agents/:id/status         // Change status
DELETE /agents/:id                // Delete agent
GET    /agents/:id/conversations  // (Future) Get agent's conversations
```

**Apply TenantGuard:**
```typescript
@UseGuards(TenantGuard)
@Controller('agents')
export class AgentsController {
  // Extract tenantId from req.tenant.id
}
```

---

### Phase 4.4: Create Module & Register (10 min)

#### File: `agents.module.ts`
```typescript
@Module({
  controllers: [AgentsController],
  providers: [AgentsService, PrismaService],
  exports: [AgentsService],
})
export class AgentsModule {}
```

**Register in `app.module.ts`:**
```typescript
imports: [
  ConfigModule.forRoot({ isGlobal: true }),
  TenantsModule,
  AgentsModule,  // ← Add this
],
```

---

## Testing Checklist

Once built, test in Swagger:

### 1. Create an Agent
```json
POST /agents
Headers: { "X-Tenant-Id": "<your-tenant-id>" }
Body:
{
  "name": "IT Support Bot",
  "version": "1.0.0",
  "flowJson": {
    "nodes": [
      { "id": "kb_search", "type": "tool" },
      { "id": "get_feedback", "type": "user_input" },
      { "id": "create_ticket", "type": "tool" }
    ],
    "edges": [
      { "from": "kb_search", "to": "get_feedback" },
      { "from": "get_feedback", "to": "create_ticket", "condition": "negative" }
    ]
  },
  "tenantId": "<your-tenant-id>"
}
```

### 2. List Agents
```
GET /agents
Headers: { "X-Tenant-Id": "<your-tenant-id>" }
→ Should see your agent with status: DRAFT
```

### 3. Publish Agent
```json
PATCH /agents/<agent-id>/status
Headers: { "X-Tenant-Id": "<your-tenant-id>" }
Body:
{
  "status": "PUBLISHED"
}
```

### 4. Update Agent
```json
PATCH /agents/<agent-id>
Body:
{
  "version": "1.1.0",
  "flowJson": { ... updated flow ... }
}
```

### 5. Test Tenant Isolation
- Create agent for Tenant A
- Try to access with Tenant B's ID
- Should get 404 (not found, because wrong tenant)

---

## Success Criteria

Phase 4 complete when:
- Can create agents with LangGraph flows
- Agents are tenant-scoped (isolation works)
- Can change agent status (DRAFT → PUBLISHED)
- Can update agent version and flow
- Can delete agents
- Swagger documentation complete
- All endpoints protected by TenantGuard

---

## What's Next

After Phase 4, you'll have:
- Multi-tenant platform
- Tenant management
- User management
- **Agent workflow storage**

**Phase 5** will add:
- Conversations module (state management with Redis)
- Message history
- Link conversations to agents

This lets you:
1. User starts conversation
2. System loads Agent's flowJson
3. LangGraph executes the workflow
4. Messages stored in database
5. State cached in Redis

---

## Tips

1. **Start with DTOs** - Get validation right first
2. **Service layer next** - Test database operations
3. **Controller last** - Wire everything together
4. **Test incrementally** - Don't wait until everything is built

**Estimated Time:**
- DTOs: 20 minutes
- Service: 30 minutes
- Controller: 20 minutes
- Module: 10 minutes
- Testing: 20 minutes
**Total: ~1.5-2 hours**

---

**Ready to start Phase 4?** Follow the same pattern you used for Tenants module!
