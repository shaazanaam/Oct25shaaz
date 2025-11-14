# Phase 8: LangGraph Execution Service

**Phase:** 8 of 11  
**Component:** Execution Plane (FastAPI/Python)  
**Estimated Time:** 6-8 hours  
**Prerequisites:** Phases 1-7 Complete (NestJS Control Plane)

## Overview

Build the FastAPI service that executes LangGraph workflows. This is the "engine" of your AI platform that actually runs the workflows defined in agent `flowJson`.

### What You're Building

A Python/FastAPI service that:

1. Loads agent definitions from PostgreSQL
2. Builds LangGraph StateGraph from flowJson
3. Executes Python workflows
4. Manages conversation state in Redis
5. Calls tools via NestJS API
6. Streams responses back to clients

### Why FastAPI + Python?

- **LangGraph** requires Python (no TypeScript version exists)
- **FastAPI** is perfect for async Python microservices
- **LangChain ecosystem** is primarily Python-based
- **NestJS** handles metadata; **FastAPI** handles execution

---

## Architecture Context

### How It Fits

```
React Frontend
    ↓
NestJS Control Plane (TypeScript)
    ├→ Stores agent flowJson
    ├→ Handles multi-tenancy
    ├→ Calls FastAPI to execute →
    |                            ↓
    |                    FastAPI Execution Plane (Python)
    |                        ├→ Loads flowJson
    |                        ├→ Builds LangGraph
    |                        ├→ Executes workflow
    |                        └→ Calls tools via NestJS
    └← Receives results ←┘
```

### Communication Flow

1. **User sends message** → React → NestJS: POST /conversations/:id/messages
2. **NestJS triggers execution** → FastAPI: POST /execute
3. **FastAPI runs workflow** → Calls tools → Saves state
4. **FastAPI returns result** → NestJS saves to database
5. **User sees response** → React displays message

---

## Phase 8 Tasks

### Task 8.1: Project Setup (1 hour)

#### Create Project Structure

```bash
cd /c/Users/shaurya/Oct25shaaz
mkdir langgraph-service
cd langgraph-service
```

#### Files to Create

**1. requirements.txt**

```txt
# FastAPI and ASGI server
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
pydantic-settings==2.1.0

# LangGraph and LangChain
langgraph==0.0.26
langchain==0.1.0
langchain-core==0.1.0
langchain-openai==0.0.2

# Database
sqlalchemy==2.0.23
asyncpg==0.29.0
psycopg2-binary==2.9.9

# Redis for state management
redis==5.0.1
aioredis==2.0.1

# HTTP client for calling NestJS
httpx==0.25.2

# Utilities
python-dotenv==1.0.0
python-json-logger==2.0.7
```

**2. .env**

```env
# Server Configuration
PORT=8000
HOST=0.0.0.0
ENVIRONMENT=development

# Database (PostgreSQL) - Read-only access
DATABASE_URL=postgresql://ai:ai@localhost:5432/ai_platform

# Redis (State Management)
REDIS_URL=redis://localhost:6379/0

# NestJS Control Plane
NEST_API_URL=http://localhost:3000
NEST_API_KEY=

# LLM Configuration (Optional)
OPENAI_API_KEY=
```

**3. Dockerfile**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
```

**4. .gitignore**

```
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv
.env
.env.local
*.log
.pytest_cache/
.coverage
htmlcov/
dist/
build/
*.egg-info/
```

---

### Task 8.2: Configuration Module (30 min)

**Create: config.py**

```python
"""Configuration settings for LangGraph execution service."""

from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Server
    port: int = 8000
    host: str = "0.0.0.0"
    environment: str = "development"

    # Database (Read-only for loading agent definitions)
    database_url: str

    # Redis (State management)
    redis_url: str

    # NestJS Control Plane
    nest_api_url: str
    nest_api_key: Optional[str] = None

    # LLM (Optional - for direct LLM calls)
    openai_api_key: Optional[str] = None

    class Config:
        env_file = ".env"
        case_sensitive = False


# Global settings instance
settings = Settings()
```

---

### Task 8.3: Database Module (1 hour)

**Create: database.py**

```python
"""Database connection and queries for loading agent definitions."""

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text
from typing import Optional, Dict, Any
import logging

from config import settings

logger = logging.getLogger(__name__)

# Database engine and session
engine = None
async_session_maker = None


async def init_db():
    """Initialize database connection pool."""
    global engine, async_session_maker

    # Convert postgresql:// to postgresql+asyncpg://
    db_url = settings.database_url.replace('postgresql://', 'postgresql+asyncpg://')

    engine = create_async_engine(
        db_url,
        echo=settings.environment == "development",
        pool_size=5,
        max_overflow=10,
        pool_pre_ping=True  # Verify connections before using
    )

    async_session_maker = sessionmaker(
        engine,
        class_=AsyncSession,
        expire_on_commit=False
    )

    logger.info("Database connection pool initialized")


async def get_agent_by_id(agent_id: str, tenant_id: str) -> Optional[Dict[str, Any]]:
    """
    Load agent definition from database.

    Args:
        agent_id: Agent ID to load
        tenant_id: Tenant ID for multi-tenant isolation

    Returns:
        Agent data including flowJson, or None if not found
    """
    async with async_session_maker() as session:
        try:
            query = text(\"\"\"
                SELECT id, name, version, status, "flowJson", "tenantId",
                       "createdAt", "updatedAt"
                FROM "Agent"
                WHERE id = :agent_id AND "tenantId" = :tenant_id
            \"\"\")

            result = await session.execute(
                query,
                {"agent_id": agent_id, "tenant_id": tenant_id}
            )

            row = result.fetchone()

            if not row:
                logger.warning(f"Agent {agent_id} not found for tenant {tenant_id}")
                return None

            # Convert row to dict
            agent_data = {
                "id": row[0],
                "name": row[1],
                "version": row[2],
                "status": row[3],
                "flowJson": row[4],  # This is already a dict from JSONB
                "tenantId": row[5],
                "createdAt": row[6].isoformat() if row[6] else None,
                "updatedAt": row[7].isoformat() if row[7] else None
            }

            logger.info(f"Loaded agent {agent_id} (version {agent_data['version']})")
            return agent_data

        except Exception as e:
            logger.error(f"Error loading agent {agent_id}: {str(e)}")
            raise
```

---

### Task 8.4: Redis Client Module (45 min)

**Create: redis_client.py**

```python
"""Redis client for conversation state management."""

import redis.asyncio as redis
from typing import Optional, Dict, Any
import json
import logging

from config import settings

logger = logging.getLogger(__name__)

# Global Redis client
redis_client: Optional[redis.Redis] = None


async def init_redis():
    """Initialize Redis connection."""
    global redis_client

    try:
        redis_client = await redis.from_url(
            settings.redis_url,
            encoding="utf-8",
            decode_responses=True,
            max_connections=10
        )

        # Test connection
        await redis_client.ping()
        logger.info("Redis connection established")

    except Exception as e:
        logger.error(f"Failed to connect to Redis: {str(e)}")
        raise


async def get_redis() -> redis.Redis:
    """Get Redis client instance."""
    if redis_client is None:
        raise RuntimeError("Redis client not initialized")
    return redis_client


async def save_conversation_state(
    conversation_id: str,
    tenant_id: str,
    state: Dict[str, Any],
    ttl: int = 86400  # 24 hours default
) -> bool:
    """
    Save conversation state to Redis.

    Args:
        conversation_id: Conversation ID
        tenant_id: Tenant ID for key namespacing
        state: State dictionary to save
        ttl: Time-to-live in seconds

    Returns:
        True if saved successfully
    """
    try:
        key = f"conversation:{tenant_id}:{conversation_id}:state"

        # Serialize state to JSON
        state_json = json.dumps(state, default=str)

        # Save to Redis with TTL
        await redis_client.setex(key, ttl, state_json)

        logger.info(f"Saved state for conversation {conversation_id}")
        return True

    except Exception as e:
        logger.error(f"Error saving conversation state: {str(e)}")
        return False


async def load_conversation_state(
    conversation_id: str,
    tenant_id: str
) -> Optional[Dict[str, Any]]:
    """
    Load conversation state from Redis.

    Args:
        conversation_id: Conversation ID
        tenant_id: Tenant ID for key namespacing

    Returns:
        State dictionary or None if not found
    """
    try:
        key = f"conversation:{tenant_id}:{conversation_id}:state"

        state_json = await redis_client.get(key)

        if not state_json:
            logger.info(f"No cached state for conversation {conversation_id}")
            return None

        # Deserialize from JSON
        state = json.loads(state_json)

        logger.info(f"Loaded state for conversation {conversation_id}")
        return state

    except Exception as e:
        logger.error(f"Error loading conversation state: {str(e)}")
        return None
```

---

### Task 8.5: LangGraph Executor (2-3 hours)

**Create: executor.py**

```python
"""LangGraph workflow executor."""

from typing import Dict, Any, Optional
from langgraph.graph import StateGraph, END
from langchain_core.messages import HumanMessage, AIMessage
import logging
import httpx

from config import settings
from redis_client import save_conversation_state, load_conversation_state

logger = logging.getLogger(__name__)


def validate_flow_json(flow_json: Dict[str, Any]) -> Dict[str, Any]:
    """
    Validate flowJson structure.

    Args:
        flow_json: Flow definition to validate

    Returns:
        Validation result with errors if any
    """
    errors = []

    # Check required top-level keys
    if "nodes" not in flow_json:
        errors.append("Missing 'nodes' array")
    if "edges" not in flow_json:
        errors.append("Missing 'edges' array")

    # Validate nodes
    if "nodes" in flow_json:
        nodes = flow_json["nodes"]
        if not isinstance(nodes, list):
            errors.append("'nodes' must be an array")
        else:
            node_ids = set()
            for i, node in enumerate(nodes):
                if "id" not in node:
                    errors.append(f"Node at index {i} missing 'id'")
                else:
                    node_ids.add(node["id"])
                if "type" not in node:
                    errors.append(f"Node {node.get('id', i)} missing 'type'")

    # Validate edges
    if "edges" in flow_json:
        edges = flow_json["edges"]
        if not isinstance(edges, list):
            errors.append("'edges' must be an array")
        else:
            for i, edge in enumerate(edges):
                if "from" not in edge:
                    errors.append(f"Edge at index {i} missing 'from'")
                if "to" not in edge:
                    errors.append(f"Edge at index {i} missing 'to'")

    return {
        "valid": len(errors) == 0,
        "errors": errors,
        "node_count": len(flow_json.get("nodes", [])),
        "edge_count": len(flow_json.get("edges", []))
    }


async def execute_workflow(
    agent_id: str,
    conversation_id: str,
    tenant_id: str,
    flow_json: Dict[str, Any],
    user_message: str,
    metadata: Optional[Dict[str, Any]] = None
) -> Dict[str, Any]:
    """
    Execute a LangGraph workflow.

    Args:
        agent_id: Agent ID
        conversation_id: Conversation ID for state management
        tenant_id: Tenant ID
        flow_json: LangGraph flow definition
        user_message: User's input message
        metadata: Additional metadata

    Returns:
        Execution result with response and state
    """
    try:
        logger.info(f"Executing workflow for agent {agent_id}")

        # Validate flow
        validation = validate_flow_json(flow_json)
        if not validation["valid"]:
            raise ValueError(f"Invalid flow: {validation['errors']}")

        # Load previous state from Redis
        previous_state = await load_conversation_state(conversation_id, tenant_id)

        # Initialize state
        initial_state = {
            "messages": previous_state.get("messages", []) if previous_state else [],
            "user_message": user_message,
            "response": "",
            "metadata": metadata or {}
        }

        # Add user message
        initial_state["messages"].append({
            "role": "USER",
            "content": user_message
        })

        # TODO: Build and execute LangGraph StateGraph from flow_json
        # For now, return a simple echo response
        assistant_response = f"[Echo] You said: {user_message}"

        # Add assistant response to state
        initial_state["messages"].append({
            "role": "ASSISTANT",
            "content": assistant_response
        })
        initial_state["response"] = assistant_response

        # Save state to Redis
        await save_conversation_state(conversation_id, tenant_id, initial_state)

        logger.info(f"Workflow execution completed for agent {agent_id}")

        return {
            "response": assistant_response,
            "state": initial_state,
            "messages_count": len(initial_state["messages"])
        }

    except Exception as e:
        logger.error(f"Workflow execution failed: {str(e)}", exc_info=True)
        raise
```

---

### Task 8.6: FastAPI Main Application (1-2 hours)

**Create: main.py**

```python
"""
LangGraph Execution Service - FastAPI Application

This service executes LangGraph workflows defined in agent flowJson.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
import logging
from datetime import datetime

from config import settings
from database import get_agent_by_id, init_db
from redis_client import init_redis
from executor import execute_workflow, validate_flow_json

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="LangGraph Execution Service",
    description="Executes AI workflows using LangGraph",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Request/Response Models
class ExecuteRequest(BaseModel):
    """Request to execute an agent workflow."""
    agent_id: str = Field(..., description="Agent ID to execute")
    conversation_id: str = Field(..., description="Conversation ID for state management")
    message: str = Field(..., description="User message to process")
    tenant_id: str = Field(..., description="Tenant ID for multi-tenant isolation")
    metadata: Optional[Dict[str, Any]] = Field(default={}, description="Additional metadata")


class ExecuteResponse(BaseModel):
    """Response from workflow execution."""
    conversation_id: str
    agent_id: str
    response: str
    state: Optional[Dict[str, Any]] = None
    execution_time_ms: float
    timestamp: str


# Startup and Shutdown Events
@app.on_event("startup")
async def startup_event():
    """Initialize connections on startup."""
    logger.info("Starting LangGraph Execution Service...")
    await init_db()
    await init_redis()
    logger.info("LangGraph Execution Service started successfully")


# API Endpoints

@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": "langgraph-execution",
        "timestamp": datetime.utcnow().isoformat()
    }


@app.post("/execute", response_model=ExecuteResponse)
async def execute_agent(request: ExecuteRequest):
    """Execute an agent workflow synchronously."""
    start_time = datetime.utcnow()

    try:
        # Load agent from database
        agent = await get_agent_by_id(request.agent_id, request.tenant_id)
        if not agent:
            raise HTTPException(status_code=404, detail=f"Agent {request.agent_id} not found")

        # Check agent status
        if agent.get("status") != "PUBLISHED":
            raise HTTPException(
                status_code=400,
                detail=f"Agent is not published. Current status: {agent.get('status')}"
            )

        # Execute workflow
        result = await execute_workflow(
            agent_id=request.agent_id,
            conversation_id=request.conversation_id,
            tenant_id=request.tenant_id,
            flow_json=agent["flowJson"],
            user_message=request.message,
            metadata=request.metadata
        )

        # Calculate execution time
        execution_time = (datetime.utcnow() - start_time).total_seconds() * 1000

        return ExecuteResponse(
            conversation_id=request.conversation_id,
            agent_id=request.agent_id,
            response=result["response"],
            state=result.get("state"),
            execution_time_ms=execution_time,
            timestamp=datetime.utcnow().isoformat()
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Execution error: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Execution failed: {str(e)}")


@app.post("/validate")
async def validate_flow(flow_json: Dict[str, Any]):
    """Validate flowJson structure without executing."""
    validation_result = validate_flow_json(flow_json)

    if validation_result["valid"]:
        return {"valid": True, "message": "Flow definition is valid"}
    else:
        return {
            "valid": False,
            "message": "Flow definition has errors",
            "errors": validation_result.get("errors", [])
        }


@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "service": "LangGraph Execution Service",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs"
    }
```

---

### Task 8.7: Docker Integration (30 min)

**Update: docker-compose.yml**

Add FastAPI service to your existing docker-compose.yml:

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: ai
      POSTGRES_PASSWORD: ai
      POSTGRES_DB: ai_platform
    ports: ["5432:5432"]
    volumes: [pg:/var/lib/postgresql/data]

  redis:
    image: redis:7
    ports: ["6379:6379"]

  langgraph-service:
    build: ./langgraph-service
    ports: ["8000:8000"]
    environment:
      - DATABASE_URL=postgresql://ai:ai@postgres:5432/ai_platform
      - REDIS_URL=redis://redis:6379/0
      - NEST_API_URL=http://host.docker.internal:3000
      - ENVIRONMENT=development
    depends_on:
      - postgres
      - redis
    volumes:
      - ./langgraph-service:/app
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload

volumes: { pg: {} }
```

---

### Task 8.8: Testing (1 hour)

#### Manual Testing Steps

**1. Install Python Dependencies**

```bash
cd langgraph-service
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

**2. Run FastAPI Locally**

```bash
# In langgraph-service/
uvicorn main:app --reload
```

**3. Test Health Endpoint**

```bash
curl http://localhost:8000/health
```

**4. Test with Docker**

```bash
# In project root
docker compose up -d
```

**5. View Logs**

```bash
docker compose logs langgraph-service
```

**6. Test Execution**

```bash
curl -X POST http://localhost:8000/execute \
  -H "Content-Type: application/json" \
  -d '{
    "agent_id": "YOUR_AGENT_ID",
    "conversation_id": "test-conv-1",
    "message": "Hello",
    "tenant_id": "YOUR_TENANT_ID"
  }'
```

---

## Success Criteria

Phase 8 is complete when:

- ✅ FastAPI service starts without errors
- ✅ /health endpoint returns 200 OK
- ✅ Can load agent from PostgreSQL
- ✅ FlowJson validation works
- ✅ Basic execution returns a response
- ✅ Conversation state saves to Redis
- ✅ Docker container runs properly
- ✅ Service accessible at http://localhost:8000

---

## Common Issues & Solutions

### Issue: Python version mismatch

**Solution:** Use Python 3.11+

```bash
python --version
```

### Issue: Database connection fails

**Solution:** Check DATABASE_URL and ensure PostgreSQL is running

```bash
docker ps | grep postgres
```

### Issue: Redis connection fails

**Solution:** Verify Redis is running

```bash
docker ps | grep redis
redis-cli ping
```

### Issue: Import errors

**Solution:** Ensure all dependencies installed

```bash
pip install -r requirements.txt
```

---

## Next Steps

After Phase 8 is complete:

1. **Update ROADMAP.md** - Mark Phase 8 as complete (72.73%)
2. **Update CHANGELOG.md** - Document Phase 8 changes
3. **Test End-to-End** - NestJS → FastAPI → Response
4. **Move to Phase 9** - Build MCP Integration Layer

---

## Related Documentation

- **Architecture Overview:** `docs/guides/ROADMAP.md` - Phases 8-9
- **NestJS Agents API:** `src/agents/` - Agent CRUD operations
- **Database Schema:** `prisma/schema.prisma` - Agent model
- **LangGraph Docs:** https://python.langchain.com/docs/langgraph

---

**Estimated Time:** 6-8 hours  
**Difficulty:** Moderate (new technology stack)  
**Reward:** Working AI workflow execution! 🚀
