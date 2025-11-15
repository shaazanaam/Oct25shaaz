# Docker Container Architecture

**Last Updated:** November 15, 2025  
**Phase:** 8 - LangGraph Execution Service  
**Status:** Production-Ready Containerization Complete

---

## Overview

The AI platform uses **Docker containers** running **locally on your computer** to provide consistent, isolated environments for each service. Think of containers as lightweight, portable packages that include everything needed to run a service.

### What Are Containers?

**Containers are NOT in the cloud** - they run on your local machine using your computer's resources (CPU, RAM, disk). Docker Desktop manages these containers, but they're executing on your hardware.

**Think of it like this:**

```
Your Physical Computer
├── Windows OS (your main operating system)
├── Docker Desktop (container manager)
└── Containers (isolated mini-environments)
    ├── PostgreSQL (running on your RAM/CPU)
    ├── Redis (running on your RAM/CPU)
    └── FastAPI (running on your RAM/CPU)
```

---

## Current Architecture

### Services Running

We have **3 containerized services** + **1 manual service**:

```
┌─────────────────────────────────────────────────────────────┐
│                    DOCKER CONTAINERS                        │
│                  (Running on Your Computer)                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────┐          │
│  │  1. PostgreSQL Database                      │          │
│  │  Container: ai-platform-postgres             │          │
│  │  Port: 5432                                  │          │
│  │  Image: postgres:16                          │          │
│  │  Purpose: Store all metadata                │          │
│  │  Used By: NestJS (write) + FastAPI (read)   │          │
│  └──────────────────────────────────────────────┘          │
│                         │                                   │
│                         ▼                                   │
│  ┌──────────────────────────────────────────────┐          │
│  │  2. Redis Cache                              │          │
│  │  Container: ai-platform-redis                │          │
│  │  Port: 6379                                  │          │
│  │  Image: redis:7                              │          │
│  │  Purpose: Store conversation state           │          │
│  │  Used By: FastAPI only                       │          │
│  │  TTL: 24 hours                               │          │
│  └──────────────────────────────────────────────┘          │
│                         │                                   │
│                         ▼                                   │
│  ┌──────────────────────────────────────────────┐          │
│  │  3. FastAPI LangGraph Service                │          │
│  │  Container: ai-platform-langgraph            │          │
│  │  Port: 8000                                  │          │
│  │  Image: langgraph-service:latest             │          │
│  │  Purpose: Execute AI workflows               │          │
│  │  Size: ~400MB (optimized multi-stage build)  │          │
│  └──────────────────────────────────────────────┘          │
│                         │                                   │
└─────────────────────────┼───────────────────────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │  4. NestJS Control Plane            │
        │  NOT containerized (runs manually)  │
        │  Port: 3000                         │
        │  Command: npm run start:dev         │
        │  Purpose: Manage metadata & APIs    │
        └─────────────────────────────────────┘
```

---

## Container Details

### 1. PostgreSQL Container

**Container Name:** `ai-platform-postgres`  
**Image:** `postgres:16` (official PostgreSQL image)  
**Port Mapping:** `5432:5432` (host:container)

**Purpose:**

- Stores all application metadata
- Tenants, users, agents, tools, conversations, messages, documents

**Resources Used (Your Computer):**

- ~500MB RAM
- ~200MB disk space (data stored at `C:\ProgramData\Docker\volumes\oct25shaaz_pg\`)
- Shares your CPU cores

**Health Check:**

- Command: `pg_isready` (checks if PostgreSQL is accepting connections)
- Interval: Every 5 seconds
- Status: 🟢 Healthy

**Environment Variables:**

```yaml
POSTGRES_USER: ai
POSTGRES_PASSWORD: ai
POSTGRES_DB: ai_platform
```

**Why Containerized?**

- Consistent PostgreSQL 16 version across all developers
- Easy setup (no manual installation)
- Isolated from other PostgreSQL instances
- Easy cleanup (delete container, data gone)

---

### 2. Redis Container

**Container Name:** `ai-platform-redis`  
**Image:** `redis:7` (official Redis image)  
**Port Mapping:** `6379:6379`

**Purpose:**

- Stores conversation state (messages, context, history)
- Temporary cache with 24-hour TTL (auto-expires old conversations)

**Resources Used (Your Computer):**

- ~50MB RAM
- ~10MB disk space (in-memory database)
- Minimal CPU usage

**Health Check:**

- Command: `redis-cli ping` (expects PONG response)
- Interval: Every 5 seconds
- Status: 🟢 Healthy

**Key Pattern:**

```
conversation:{tenantId}:{conversationId}:state
```

**Why Redis?**

- Fast in-memory access for conversation state
- Built-in TTL (automatic cleanup after 24 hours)
- Supports complex data structures (lists, hashes)

---

### 3. FastAPI LangGraph Service

**Container Name:** `ai-platform-langgraph`  
**Image:** `langgraph-service:latest` (custom-built)  
**Port Mapping:** `8000:8000`  
**Build Time:** ~54 seconds  
**Image Size:** ~400MB (multi-stage build optimization)

**Purpose:**

- Execute AI workflows defined in LangGraph
- Load agent definitions from PostgreSQL
- Save conversation state to Redis
- Call NestJS API for tool execution

**Resources Used (Your Computer):**

- ~200MB RAM (Python + FastAPI + libraries)
- ~400MB disk space (Docker image)
- CPU usage varies based on workflow execution

**Health Check:**

- Command: `curl http://localhost:8000/health`
- Interval: Every 30 seconds
- Timeout: 10 seconds
- Status: 🟢 Healthy

**Environment Variables:**

```yaml
DATABASE_URL: postgresql://ai:ai@postgres:5432/ai_platform
REDIS_URL: redis://redis:6379
NEST_API_URL: http://host.docker.internal:3000
PORT: 8000
```

**Why Multi-Stage Build?**

- Stage 1 (builder): Installs compilation tools (gcc, build tools) + all Python packages
- Stage 2 (runtime): Copies only necessary files, removes build tools
- Result: 55% size reduction (900MB → 400MB)

---

## Shared Resources

### PostgreSQL (Shared by NestJS + FastAPI)

**NestJS (Control Plane):**

- **Access:** Read + Write
- **Operations:** Create tenants, agents, users, tools, conversations
- **Connection:** Direct via Prisma ORM
- **URL:** `postgresql://ai:ai@localhost:5432/ai_platform`

**FastAPI (Execution Plane):**

- **Access:** Read-only
- **Operations:** Load agent flowJson definitions
- **Connection:** Async SQLAlchemy
- **URL:** `postgresql://ai:ai@postgres:5432/ai_platform` (container name)

**Why Shared?**

- Single source of truth for agent definitions
- NestJS manages metadata, FastAPI executes workflows
- Tenant isolation enforced in both services

---

### Redis (FastAPI Only)

**FastAPI:**

- **Access:** Read + Write
- **Operations:** Load/save conversation state
- **Connection:** Async Redis client
- **URL:** `redis://redis:6379`

**NestJS:**

- **Access:** None currently
- **Future:** May use for session storage, caching

**Why Separate?**

- Conversation state is execution-plane concern
- Temporary data (24h TTL) doesn't need PostgreSQL
- Fast access for real-time conversations

---

## Networking

### Container-to-Container Communication

**How containers talk to each other:**

```
FastAPI Container
  │
  ├─→ PostgreSQL: Uses hostname "postgres" (Docker DNS)
  │   URL: postgresql://ai:ai@postgres:5432/ai_platform
  │
  └─→ Redis: Uses hostname "redis" (Docker DNS)
      URL: redis://redis:6379
```

Docker creates a private network (`oct25shaaz_default`) where containers can find each other by name.

---

### Container-to-Host Communication

**How FastAPI calls NestJS (running on host machine):**

```
FastAPI Container
  │
  └─→ NestJS (host machine): Uses "host.docker.internal"
      URL: http://host.docker.internal:3000
```

`host.docker.internal` is a special Docker hostname that resolves to your computer's IP address from inside a container.

---

### Port Mapping

**How you access containers from your browser/terminal:**

```
Your Computer (localhost)
  │
  ├─→ localhost:3000  → NestJS (running directly)
  ├─→ localhost:5432  → PostgreSQL container
  ├─→ localhost:6379  → Redis container
  └─→ localhost:8000  → FastAPI container
```

Port mapping format: `host_port:container_port`

Example: `5432:5432` means port 5432 on your computer → port 5432 inside container

---

## Health Checks

All containers have health checks to ensure they're running correctly.

### PostgreSQL Health Check

```yaml
test: ["CMD-SHELL", "pg_isready"]
interval: 5s
timeout: 5s
retries: 5
```

**What it does:**

- Runs `pg_isready` command inside container
- Checks every 5 seconds
- If 5 failures in a row → container marked unhealthy

---

### Redis Health Check

```yaml
test: ["CMD", "redis-cli", "ping"]
interval: 5s
timeout: 5s
retries: 5
```

**What it does:**

- Runs `redis-cli ping` inside container
- Expects `PONG` response
- Container unhealthy if ping fails

---

### FastAPI Health Check

```yaml
test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
interval: 30s
timeout: 10s
retries: 3
start_period: 40s
```

**What it does:**

- Calls HTTP GET /health endpoint
- Expects 200 OK with JSON response
- Gives 40 seconds for Python to start up
- Checks every 30 seconds after startup

---

## Dependencies

**Startup Order:**

```
1. PostgreSQL starts first
   ↓ (waits for healthy)
2. Redis starts
   ↓ (waits for both healthy)
3. FastAPI starts (depends on postgres + redis)
```

Defined in docker-compose.yml:

```yaml
langgraph-service:
  depends_on:
    postgres:
      condition: service_healthy
    redis:
      condition: service_healthy
```

**Why Important?**

- FastAPI can't start without database connection
- Prevents errors from trying to connect to services that aren't ready
- Automatic retry if dependencies fail

---

## Resource Usage Summary

**On Your Computer:**

| Container  | RAM    | Disk   | CPU      |
| ---------- | ------ | ------ | -------- |
| PostgreSQL | ~500MB | ~200MB | Low      |
| Redis      | ~50MB  | ~10MB  | Very Low |
| FastAPI    | ~200MB | ~400MB | Variable |
| **Total**  | ~750MB | ~610MB | -        |

**NestJS (manual):**

- RAM: ~300MB
- Disk: node_modules (~200MB)

**Grand Total:** ~1GB RAM, ~810MB disk

This is running on **your computer**, not the cloud. Docker Desktop uses your Windows resources to run these containers.

---

## Persistence

### What Happens If Containers Stop?

**PostgreSQL:**

- ✅ Data persists (stored in Docker volume `oct25shaaz_pg`)
- All tenants, agents, conversations remain
- Restart container → data still there

**Redis:**

- ❌ Data may be lost (in-memory cache)
- Conversation state lost on restart
- Not a problem (24h TTL, temporary data)

**FastAPI:**

- ✅ Application code persists (in Docker image)
- No data stored in container (stateless)
- Restart → rebuilds from image

---

### Volume Locations (Windows)

**PostgreSQL Data:**

```
C:\ProgramData\Docker\volumes\oct25shaaz_pg\_data\
```

**Docker Images:**

```
C:\ProgramData\Docker\windowsfilter\
```

---

## Security

### Non-Root User (FastAPI)

The FastAPI container runs as user `appuser` (UID 1000), not root:

```dockerfile
RUN useradd -m -u 1000 appuser
USER appuser
```

**Why?**

- Root inside container = root on host (security risk)
- Limited permissions reduce attack surface
- Best practice for production containers

---

### Network Isolation

Containers are isolated from your host network:

- Can only access exposed ports (5432, 6379, 8000)
- Cannot access other services on your computer
- Private network for inter-container communication

---

## Commands

### View Running Containers

```bash
docker ps
```

Output:

```
CONTAINER ID   IMAGE                     STATUS      PORTS
abc123         postgres:16               Up 2 hours  5432:5432
def456         redis:7                   Up 2 hours  6379:6379
ghi789         langgraph-service:latest  Up 1 hour   8000:8000
```

---

### View Container Logs

```bash
# PostgreSQL
docker logs ai-platform-postgres

# Redis
docker logs ai-platform-redis

# FastAPI
docker logs ai-platform-langgraph
```

---

### View Resource Usage

```bash
docker stats
```

Shows real-time CPU, RAM, network usage for each container.

---

### Restart Containers

```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart langgraph-service
```

---

### Stop/Start Containers

```bash
# Stop all
docker-compose down

# Start all
docker-compose up -d

# -d = detached (runs in background)
```

---

### Rebuild FastAPI Container

```bash
# After changing Dockerfile or code
docker-compose build langgraph-service

# Rebuild and restart
docker-compose up -d --build langgraph-service
```

---

## Future Enhancements (Phase 11)

When deployed to production:

1. **Container Orchestration:** Kubernetes will manage containers across multiple servers
2. **Cloud Resources:** Containers will run on AWS/Azure/GCP (not your computer)
3. **Horizontal Scaling:** Multiple FastAPI containers behind load balancer
4. **Database Clustering:** PostgreSQL replicas for high availability
5. **Redis Cluster:** Multi-node Redis for fault tolerance
6. **Monitoring:** Prometheus scrapes metrics from all containers
7. **Logging:** All container logs sent to centralized ELK stack

---

## Troubleshooting

### Container Won't Start

**Check logs:**

```bash
docker logs ai-platform-langgraph
```

**Check health:**

```bash
docker inspect ai-platform-langgraph | grep -A 10 Health
```

**Restart:**

```bash
docker-compose restart langgraph-service
```

---

### Can't Connect to Database

**From NestJS (host):**

```
URL: postgresql://ai:ai@localhost:5432/ai_platform
```

**From FastAPI (container):**

```
URL: postgresql://ai:ai@postgres:5432/ai_platform
```

**Test connection:**

```bash
# From host
psql -h localhost -U ai -d ai_platform

# From inside container
docker exec -it ai-platform-postgres psql -U ai -d ai_platform
```

---

### Port Already in Use

Error: `Bind for 0.0.0.0:5432 failed: port is already allocated`

**Solution:**

```bash
# Find process using port
netstat -ano | findstr :5432

# Stop the process or change port in docker-compose.yml
ports:
  - "5433:5432"  # Use different host port
```

---

### Container Keeps Restarting

**Check logs:**

```bash
docker logs ai-platform-langgraph --tail 50
```

**Common causes:**

- Database connection failure → Check DATABASE_URL
- Redis connection failure → Check REDIS_URL
- Python syntax error → Check logs for traceback
- Missing dependencies → Rebuild image

---

## Summary

**What You Have:**

- 3 Docker containers running **locally on your computer**
- PostgreSQL storing all metadata
- Redis caching conversation state
- FastAPI executing AI workflows
- All containers healthy and communicating

**What Containers Provide:**

- Consistent environment (same PostgreSQL version everywhere)
- Easy setup (one command to start everything)
- Isolation (doesn't interfere with other projects)
- Portability (same containers work in production)

**Key Concept:**
Containers are **lightweight processes** running on your machine, sharing your CPU/RAM/disk. They're not virtual machines (heavier) and they're not in the cloud (remote). Docker Desktop is just a management tool - the actual execution happens on your Windows computer.

---

**Next Steps:**

1. Verify all containers healthy: `docker ps`
2. Run integration tests: `bash langgraph-service/test-fullstack.sh`
3. Check logs if issues: `docker logs <container-name>`
4. Proceed to implementing real LangGraph execution (Phase 8 Task 4)
