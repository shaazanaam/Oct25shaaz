# Technology Study Guide

**Learning path for the Multi-Tenant LangGraph AI Platform**

This guide explains every technology used in the project, why we chose it, and what you should study to understand and extend the platform.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Backend Technologies](#backend-technologies)
3. [Database & State Management](#database--state-management)
4. [AI & LangGraph Stack](#ai--langgraph-stack)
5. [Frontend Technologies](#frontend-technologies)
6. [DevOps & Infrastructure](#devops--infrastructure)
7. [Learning Roadmap](#learning-roadmap)
8. [Recommended Resources](#recommended-resources)

---

## Architecture Overview

### Two-Microservice Design

**Why we split the backend into two services:**

```
NestJS (TypeScript)          FastAPI (Python)
Control Plane                Execution Plane
├─ CRUD operations          ├─ LangGraph workflows
├─ Multi-tenant security    ├─ LLM integrations
├─ Metadata storage         ├─ Tool execution
└─ REST API for frontend    └─ State management
```

**Reason for separation:**

- **LangGraph only works in Python** (not available in JavaScript/TypeScript)
- NestJS excels at CRUD, security, and database management
- FastAPI excels at async Python and AI library integration
- Each service can be scaled independently
- Clear separation of concerns (metadata vs execution)

---

## Backend Technologies

### NestJS (TypeScript) - Control Plane

**What it is:** Enterprise-grade Node.js framework inspired by Angular

**What we use it for:**

- Managing agents, tools, users, tenants, conversations, documents
- Multi-tenant security (TenantGuard)
- REST API for React frontend
- Triggering FastAPI execution

**Why we chose it:**

- TypeScript for type safety
- Dependency injection (clean architecture)
- Built-in Swagger documentation
- Module-based structure (scalable)
- Excellent PostgreSQL integration via Prisma

**What to study:**

1. **TypeScript Basics** (2-4 hours)

   - Types, interfaces, generics
   - Async/await
   - Decorators (`@Injectable()`, `@Controller()`, etc.)

2. **NestJS Core Concepts** (8-12 hours)

   - Modules, Controllers, Services
   - Dependency Injection
   - Guards (TenantGuard, AuthGuard)
   - DTOs and validation (class-validator)
   - Exception filters

3. **NestJS Advanced** (4-6 hours)
   - Middleware vs Guards vs Interceptors
   - Request lifecycle
   - Custom decorators
   - Swagger/OpenAPI integration

**Study Resources:**

- Official docs: https://docs.nestjs.com
- Free course: https://www.udemy.com/course/nestjs-zero-to-hero/
- Our code: `src/` directory (read `src/agents/`, `src/guards/`)

---

### FastAPI (Python) - Execution Plane

**What it is:** Modern Python web framework with automatic API documentation

**What we use it for:**

- Executing LangGraph workflows
- Loading agents from PostgreSQL
- Managing conversation state in Redis
- Validating flowJson structures

**Why we chose it:**

- **LangGraph requires Python** (no choice here!)
- Async support (like Node.js)
- Automatic Swagger docs (like NestJS)
- Pydantic for validation (like TypeScript types)
- Fast performance (comparable to Node.js)

**What to study:**

1. **Python Basics** (if coming from TypeScript) (4-6 hours)

   - Type hints (similar to TypeScript types)
   - Async/await (`async def`, `await`)
   - List comprehensions
   - Decorators (`@app.get()`, `@validator`, etc.)

2. **FastAPI Fundamentals** (6-8 hours)

   - Path operations (`@app.get()`, `@app.post()`)
   - Pydantic models (like DTOs in NestJS)
   - Request/response models
   - Dependency injection
   - Background tasks

3. **FastAPI Advanced** (4-6 hours)
   - Async database connections (SQLAlchemy async)
   - Middleware and CORS
   - WebSockets and SSE (Server-Sent Events)
   - Error handling

**Study Resources:**

- Official docs: https://fastapi.tiangolo.com
- Tutorial: https://fastapi.tiangolo.com/tutorial/
- Our code: `langgraph-service/` directory (read `main.py`, `executor.py`)

---

### Prisma ORM (TypeScript)

**What it is:** Next-generation ORM with type-safe database access

**What we use it for:**

- Database schema definition (`schema.prisma`)
- Type-safe queries in NestJS
- Database migrations
- Seeding data

**Why we chose it:**

- Auto-generated TypeScript types
- Intuitive schema syntax
- Excellent PostgreSQL support
- Built-in migrations
- Relation handling (join queries)

**What to study:**

1. **Prisma Basics** (3-5 hours)

   - Schema definition (models, fields, relations)
   - Prisma Client (CRUD operations)
   - Migrations (`npx prisma migrate dev`)
   - Prisma Studio (GUI for data)

2. **Prisma Advanced** (2-4 hours)
   - Relations (one-to-many, many-to-many)
   - Aggregations (`_count`, `_avg`, etc.)
   - Transactions
   - Middleware (logging, soft deletes)

**Study Resources:**

- Official docs: https://www.prisma.io/docs
- Our schema: `prisma/schema.prisma` (7 models, 5 enums)

---

## Database & State Management

### PostgreSQL 16 (Relational Database)

**What it is:** Enterprise-grade open-source relational database

**What we use it for:**

- Storing all persistent data (tenants, users, agents, tools, conversations, documents)
- JSONB for flexible data (`flowJson`, `config`, `metadata`)
- Full-text search
- ACID transactions

**Why we chose it:**

- Industry standard for production apps
- JSONB support (store LangGraph workflows as JSON)
- Excellent performance and reliability
- Free and open-source
- Great TypeScript/Python support

**What to study:**

1. **SQL Basics** (4-6 hours)

   - SELECT, INSERT, UPDATE, DELETE
   - WHERE, JOIN, ORDER BY, GROUP BY
   - Indexes and performance

2. **PostgreSQL Features** (3-5 hours)
   - JSONB data type (storing JSON efficiently)
   - Full-text search (`to_tsvector`, `to_tsquery`)
   - UUID primary keys (vs auto-increment)
   - Transactions and ACID

**Study Resources:**

- PostgreSQL tutorial: https://www.postgresqltutorial.com
- Our schema: `prisma/schema.prisma` (see migrations in `prisma/migrations/`)

---

### Redis 7 (In-Memory Cache)

**What it is:** In-memory key-value store

**What we use it for:**

- Conversation state storage (ephemeral data)
- Session management
- Caching frequent queries
- Rate limiting

**Why we chose it:**

- Lightning-fast (in-memory)
- Automatic expiration (TTL - Time To Live)
- Perfect for temporary data
- Simple key-value model
- Async Python/Node.js clients

**What to study:**

1. **Redis Basics** (2-4 hours)

   - SET, GET, DEL commands
   - Expiration (EXPIRE, TTL)
   - Data types (strings, lists, sets, hashes)
   - Key patterns (namespacing: `conversation:{id}:state`)

2. **Redis with Applications** (2-3 hours)
   - Redis client libraries (ioredis for Node, redis-py for Python)
   - Async operations
   - JSON serialization/deserialization

**Study Resources:**

- Redis tutorial: https://redis.io/docs/getting-started/
- Our code: `langgraph-service/redis_client.py`

---

## AI & LangGraph Stack

### LangGraph (Python)

**What it is:** Framework for building stateful, multi-actor AI workflows as graphs

**What we use it for:**

- Defining AI workflows as directed graphs (nodes + edges)
- Orchestrating multi-step agent behavior
- State management across workflow execution
- Conditional routing (if/else logic in workflows)

**Why we chose it:**

- **Core requirement:** Best way to build complex AI workflows
- Built on LangChain (huge ecosystem)
- Graph-based (visual, intuitive)
- Stateful (remembers conversation context)
- **Python-only** (hence the FastAPI service)

**What to study:**

1. **LangGraph Fundamentals** (6-8 hours)

   - StateGraph concept (nodes, edges, state)
   - Creating nodes (functions that transform state)
   - Adding edges (connecting nodes)
   - Conditional edges (routing logic)
   - Checkpointing (state persistence)

2. **LangGraph Patterns** (4-6 hours)
   - Agent pattern (ReAct: Reason + Act)
   - Human-in-the-loop
   - Multi-agent collaboration
   - Tool calling within graphs

**Study Resources:**

- Official docs: https://langchain-ai.github.io/langgraph/
- Tutorials: https://langchain-ai.github.io/langgraph/tutorials/
- Example: Our `langgraph-service/executor.py` (TODO: implement StateGraph)

---

### LangChain (Python)

**What it is:** Framework for developing LLM-powered applications

**What we use it for:**

- LLM integrations (OpenAI, Ollama, Anthropic)
- Prompt templates
- Memory management
- Tool/function calling
- Document loaders and retrievers

**Why we chose it:**

- Industry standard for LLM apps
- LangGraph is built on top of LangChain
- Huge library of integrations
- Active community

**What to study:**

1. **LangChain Basics** (8-12 hours)

   - LLMs and Chat Models
   - Prompt Templates
   - Chains (LLMChain, SimpleSequentialChain)
   - Memory (ConversationBufferMemory, etc.)
   - Tools and Agents

2. **LangChain Advanced** (6-8 hours)
   - Custom tools
   - Retrieval (RAG - Retrieval-Augmented Generation)
   - Callbacks (streaming, logging)
   - LangSmith (debugging and monitoring)

**Study Resources:**

- Official docs: https://python.langchain.com/docs/get_started/introduction
- Free course: https://www.deeplearning.ai/short-courses/langchain-for-llm-application-development/

---

### Pydantic (Python)

**What it is:** Data validation library using Python type hints

**What we use it for:**

- Request/response models in FastAPI
- Settings management (config.py)
- Data validation (like class-validator in NestJS)
- Type safety in Python

**Why we chose it:**

- FastAPI is built on Pydantic
- Similar to TypeScript interfaces
- Automatic validation
- Great error messages

**What to study:**

1. **Pydantic Basics** (2-4 hours)
   - Models (like TypeScript interfaces)
   - Field types and validation
   - Optional fields
   - Validators (custom validation logic)

**Study Resources:**

- Official docs: https://docs.pydantic.dev
- Our code: `langgraph-service/main.py` (see request/response models)

---

## Frontend Technologies

### React + TypeScript (Planned - Phase 10)

**What it is:** Component-based UI library with type safety

**What we'll use it for:**

- Flow authoring UI (drag-and-drop LangGraph builder)
- Chat interface (testing agents)
- Admin panel (managing tenants, users, tools)

**Why we'll choose it:**

- Industry standard for complex UIs
- TypeScript for type safety
- Huge ecosystem (React Flow for graph visualization)
- Component reusability

**What to study:**

1. **React Basics** (8-12 hours)

   - Components (functional components)
   - Props and state
   - Hooks (useState, useEffect, useContext)
   - Event handling

2. **React with TypeScript** (4-6 hours)

   - Typing props and state
   - Generic components
   - Type inference

3. **React Flow** (4-6 hours) - For visual workflow editor
   - Nodes and edges
   - Custom nodes
   - Event handling
   - Layout algorithms

**Study Resources:**

- React docs: https://react.dev
- React Flow: https://reactflow.dev
- TypeScript with React: https://react-typescript-cheatsheet.netlify.app

---

## DevOps & Infrastructure

### Docker (Containerization)

**What it is:** Platform for packaging applications in containers

**What we use it for:**

- Running PostgreSQL locally
- Running Redis locally
- (Future) Containerizing NestJS and FastAPI services

**Why we chose it:**

- Consistent development environment
- Easy deployment
- Isolation (no conflicts with system packages)
- Standard for microservices

**What to study:**

1. **Docker Basics** (4-6 hours)
   - Images vs containers
   - Dockerfile (building images)
   - docker-compose.yml (multi-container apps)
   - Volumes (data persistence)

**Study Resources:**

- Docker docs: https://docs.docker.com/get-started/
- Our setup: `docker-compose.yml` (PostgreSQL + Redis)

---

### Git & GitHub (Version Control)

**What it is:** Distributed version control system

**What we use it for:**

- Tracking code changes
- Collaboration
- Branching and merging
- Code review

**What to study:**

1. **Git Basics** (3-5 hours)
   - Commits, branches, merges
   - Pull requests
   - Resolving conflicts
   - .gitignore

**Study Resources:**

- Git tutorial: https://www.atlassian.com/git/tutorials
- Interactive: https://learngitbranching.js.org

---

## Learning Roadmap

### If You're New to Backend Development

**Week 1-2: TypeScript & NestJS Basics**

1. Learn TypeScript fundamentals (4 hours)
2. Complete NestJS tutorial (12 hours)
3. Read our NestJS code (`src/agents/`, `src/guards/`)
4. Build a simple CRUD API

**Week 3: Database & Prisma**

1. Learn SQL basics (6 hours)
2. Learn Prisma ORM (5 hours)
3. Study our schema (`prisma/schema.prisma`)
4. Practice migrations

**Week 4: Python & FastAPI**

1. Learn Python basics (if coming from TypeScript) (6 hours)
2. Complete FastAPI tutorial (8 hours)
3. Read our FastAPI code (`langgraph-service/`)
4. Build a simple API

**Week 5-6: AI Stack (LangChain & LangGraph)**

1. Learn LangChain basics (12 hours)
2. Learn LangGraph fundamentals (8 hours)
3. Build simple agent workflow
4. Study our executor logic

**Week 7-8: Frontend (React)**

1. Learn React basics (12 hours)
2. Learn React with TypeScript (6 hours)
3. Learn React Flow (6 hours)
4. Build simple flow editor

### If You're Experienced

**Priority 1: Understanding the Architecture**

- Read: `docs/guides/ROADMAP.md`
- Read: `DEV_SESSION_LOG.md`
- Study: `prisma/schema.prisma` (database design)
- Study: `src/guards/tenant.guard.ts` (multi-tenancy)

**Priority 2: LangGraph (The Core)**

- LangGraph official tutorial (8 hours)
- Build a simple agent workflow
- Study: `langgraph-service/executor.py` (our implementation)

**Priority 3: Extending the Platform**

- Add new tool types (study `src/tools/`)
- Implement real LangGraph execution (replace echo mode)
- Add SSE streaming support
- Build React Flow UI

---

## Recommended Resources

### Books

**Backend:**

- "Node.js Design Patterns" by Mario Casciaro (NestJS patterns)
- "Fluent Python" by Luciano Ramalho (Python deep dive)

**AI:**

- "Building LLM Apps" by LangChain team (free online)
- "Hands-On Large Language Models" by Jay Alammar (LLMs explained)

**Architecture:**

- "Designing Data-Intensive Applications" by Martin Kleppmann
- "Microservices Patterns" by Chris Richardson

### Online Courses

**Free:**

- NestJS Zero to Hero (Udemy)
- FastAPI Tutorial (official docs)
- LangChain for LLM App Development (DeepLearning.AI)
- React Official Tutorial

**Paid:**

- "Complete NestJS Developer" (Udemy)
- "FastAPI - The Complete Course" (Udemy)
- "LangChain: Develop LLM powered applications" (Udemy)

### Documentation (Best Learning Source!)

**Always start here:**

1. NestJS: https://docs.nestjs.com
2. FastAPI: https://fastapi.tiangolo.com
3. Prisma: https://www.prisma.io/docs
4. LangGraph: https://langchain-ai.github.io/langgraph/
5. LangChain: https://python.langchain.com

---

## Technologies We Used and Why

### Complete Stack Summary

| Technology     | Why We Use It                                      | What to Study                       |
| -------------- | -------------------------------------------------- | ----------------------------------- |
| **NestJS**     | TypeScript CRUD API, multi-tenant security         | Controllers, services, guards, DTOs |
| **FastAPI**    | Python execution plane (LangGraph requires Python) | Path operations, Pydantic, async    |
| **PostgreSQL** | Relational database, JSONB support                 | SQL, JSONB, transactions            |
| **Redis**      | Fast state storage, TTL support                    | Key-value store, expiration         |
| **Prisma**     | Type-safe ORM, migrations                          | Schema, migrations, relations       |
| **LangGraph**  | AI workflow orchestration (core feature)           | StateGraph, nodes, edges            |
| **LangChain**  | LLM integrations, tools, memory                    | LLMs, chains, tools, agents         |
| **TypeScript** | Type safety for NestJS and React                   | Types, interfaces, generics         |
| **Python**     | Required for LangGraph/LangChain                   | Type hints, async/await             |
| **Pydantic**   | Data validation in Python                          | Models, validators                  |
| **Docker**     | Containerization, dev environment                  | Dockerfile, docker-compose          |
| **React**      | Frontend UI (planned)                              | Components, hooks, TypeScript       |

---

## What to Study Next

Based on your current progress (Phase 8 - 80% complete):

### Immediate (To Complete Phase 8)

1. **LangGraph StateGraph Building** (4-6 hours)

   - How to convert flowJson to StateGraph
   - Creating nodes from JSON definitions
   - Adding edges dynamically
   - Study: https://langchain-ai.github.io/langgraph/tutorials/introduction/

2. **Tool Execution** (2-3 hours)

   - Calling NestJS API from FastAPI
   - Using httpx for async HTTP calls
   - Handling tool responses

3. **Docker** (2-3 hours)
   - Writing Dockerfile for FastAPI
   - Updating docker-compose.yml
   - Multi-container networking

### Next Phase (Phase 9 - MCP Integration)

1. **MCP (Model Context Protocol)** (6-8 hours)

   - What MCP is
   - Building MCP servers
   - Tool integration patterns

2. **Qdrant Vector Database** (4-6 hours)
   - Vector embeddings
   - Semantic search
   - Python client library

### Future Phases

1. **React Flow** (Phase 10)

   - Visual workflow editor
   - Custom nodes
   - State management (Zustand/Redux)

2. **Kubernetes** (Phase 11)
   - Container orchestration
   - Deployments and services
   - Scaling strategies

---

## Study Tips

### For TypeScript Developers Learning Python

**Similarities:**

- Both have type hints (TypeScript types ≈ Python type hints)
- Both have async/await
- Both have decorators (`@Injectable()` ≈ `@app.get()`)
- Both have classes and interfaces

**Differences:**

- Python uses indentation (no `{}` braces)
- Python has list comprehensions (`[x for x in list]`)
- Python doesn't need semicolons
- Python imports are different (`from X import Y`)

**Quick Translation:**

```typescript
// TypeScript
interface User {
  name: string;
  age: number;
}

async function getUser(id: string): Promise<User> {
  return await db.findOne(id);
}
```

```python
# Python
class User(BaseModel):
    name: str
    age: int

async def get_user(id: str) -> User:
    return await db.find_one(id)
```

### For Python Developers Learning TypeScript

**Similarities:**

- Type hints work similarly
- Async/await syntax is almost identical
- OOP concepts transfer directly

**Differences:**

- TypeScript uses `{}` braces (not indentation)
- Need semicolons (optional but common)
- Interfaces are common (vs Python's duck typing)
- `const`/`let` instead of just variable names

### General Study Strategy

1. **Read official docs first** (most accurate and complete)
2. **Build small projects** (learning by doing is fastest)
3. **Read our codebase** (see real-world patterns)
4. **Use AI assistants** (ChatGPT, GitHub Copilot for quick questions)
5. **Join communities** (Discord, Reddit, StackOverflow)

---

## Summary

**Core Technologies to Master:**

1. **NestJS** - For understanding the control plane
2. **FastAPI** - For understanding the execution plane
3. **LangGraph** - For understanding AI workflows (THE CORE FEATURE)
4. **PostgreSQL + Prisma** - For understanding data storage
5. **Redis** - For understanding state management

**Total Learning Time (Rough Estimate):**

- **Beginner:** 200-300 hours (full stack + AI)
- **Experienced Backend:** 100-150 hours (focus on AI stack)
- **Experienced AI:** 50-80 hours (focus on architecture)

**Best Starting Point:**

1. Read `docs/guides/ROADMAP.md` (understand architecture)
2. Study `prisma/schema.prisma` (understand data model)
3. Read `src/agents/` (understand NestJS patterns)
4. Read `langgraph-service/` (understand FastAPI patterns)
5. Complete LangGraph tutorial (understand core feature)

---

**Remember:** You don't need to master everything at once. Focus on what you need for your next task, and learn incrementally. The documentation and codebase are your best learning resources!

**Current Status:** Phase 8 - 80% Complete  
**Next Learning Goal:** LangGraph StateGraph implementation  
**Estimated Time:** 6-8 hours of focused study + coding
