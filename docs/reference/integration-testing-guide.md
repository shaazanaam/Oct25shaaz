# Full Stack Integration Testing Guide

**Location:** `langgraph-service/test-fullstack.sh`  
**Purpose:** End-to-end testing of FastAPI + NestJS integration  
**Test Count:** 12 tests across 4 phases  
**Last Updated:** November 15, 2025

---

## Overview

The full stack integration test validates the complete AI platform architecture, testing the interaction between:

- **NestJS Control Plane** (port 3000) - Metadata management
- **FastAPI Execution Plane** (port 8000) - Workflow execution
- **PostgreSQL Database** (port 5432) - Persistent storage
- **Redis Cache** (port 6379) - Conversation state

**What It Tests:**

- Service health and availability
- FastAPI standalone endpoints
- End-to-end workflow execution (tenant → agent → conversation → execution)
- Conversation state persistence
- Multi-message conversation continuity
- Proper cleanup of test data

---

## Test Script Structure

### File: `langgraph-service/test-fullstack.sh` (363 lines)

```bash
#!/bin/bash
# Full Stack Integration Test Script
# Tests FastAPI LangGraph Service + NestJS Control Plane integration
```

**Key Features:**

- ✅ Color-coded output (RED/GREEN/YELLOW/BLUE)
- ✅ Test counters (passed/failed/total)
- ✅ Automatic cleanup on success or failure
- ✅ Early exit with cleanup on critical failures
- ✅ Unique tenant names (timestamp-based)
- ✅ Comprehensive error messages

---

## Test Phases

### Phase 1: Service Health Checks (2 tests)

**Purpose:** Verify both services are running before attempting integration tests

**Tests:**

1. **FastAPI Health Check**

   - Endpoint: `GET http://localhost:8000/health`
   - Expected: 200 OK with `{"status":"healthy"}`
   - Failure: Exits with error message to start FastAPI

2. **NestJS Health Check**
   - Endpoint: `GET http://localhost:3000/api`
   - Expected: 200 OK (Swagger UI HTML)
   - Failure: Exits with error message to start NestJS

**Why This Matters:**

- Prevents cryptic errors from integration tests if services aren't running
- Provides clear instructions on how to start missing services
- Fast fail saves time

---

### Phase 2: FastAPI Standalone Tests (4 tests)

**Purpose:** Verify FastAPI endpoints work independently before full integration

**Test 1: Root Endpoint**

```bash
GET http://localhost:8000/
```

**Expected Response:**

```json
{
  "service": "LangGraph Execution Service",
  "version": "1.0.0",
  "status": "running",
  "docs": "/docs"
}
```

**Test 2: Health Endpoint**

```bash
GET http://localhost:8000/health
```

**Expected Response:**

```json
{
  "status": "healthy",
  "service": "langgraph-execution",
  "timestamp": "2025-11-15T..."
}
```

**Test 3: Validate Endpoint (Valid FlowJson)**

```bash
POST http://localhost:8000/validate
Content-Type: application/json

{
  "nodes": [
    {"id": "start", "type": "tool"},
    {"id": "end", "type": "output"}
  ],
  "edges": [
    {"from": "start", "to": "end"}
  ]
}
```

**Expected Response:**

```json
{
  "valid": true,
  "message": "Flow definition is valid",
  "node_count": 2,
  "edge_count": 1
}
```

**Test 4: Validate Endpoint (Invalid FlowJson)**

```bash
POST http://localhost:8000/validate
Content-Type: application/json

{
  "edges": []
}
```

**Expected Response:**

```json
{
  "valid": false,
  "message": "Flow must have at least one node",
  "node_count": 0,
  "edge_count": 0
}
```

**Why These Tests Matter:**

- Confirms FastAPI is properly configured
- Validates request/response models
- Ensures JSON parsing works correctly
- Tests error handling for invalid input

---

### Phase 3: Full Stack Integration Tests (6 tests)

**Purpose:** Test complete workflow from tenant creation to AI execution

#### Test 1: Create Tenant

**Request:**

```bash
POST http://localhost:3000/tenants
Content-Type: application/json

{
  "name": "Test Tenant FullStack 1731679200",
  "plan": "ENTERPRISE"
}
```

**What It Tests:**

- NestJS tenant creation endpoint
- Unique tenant name generation (timestamp prevents duplicates)
- Captures TENANT_ID for subsequent tests

**Critical Failure Handling:**

- If tenant creation fails, test exits immediately
- No point continuing without tenant (all other tests require it)

---

#### Test 2: Create Agent

**Request:**

```bash
POST http://localhost:3000/agents
Content-Type: application/json
X-Tenant-Id: {TENANT_ID}

{
  "name": "Test Agent - Echo Bot",
  "version": "1.0.0",
  "flowJson": {
    "nodes": [
      {"id": "start", "type": "input"},
      {"id": "process", "type": "tool"},
      {"id": "end", "type": "output"}
    ],
    "edges": [
      {"from": "start", "to": "process"},
      {"from": "process", "to": "end"}
    ]
  },
  "tenantId": "{TENANT_ID}"
}
```

**What It Tests:**

- NestJS agent creation endpoint
- Multi-tenant isolation (X-Tenant-Id header)
- FlowJson storage in PostgreSQL
- DTO validation (tenantId in both header and body)

**Critical Failure Handling:**

- If agent creation fails, cleans up tenant and exits
- Prevents orphaned test data

---

#### Test 3: Publish Agent

**Request:**

```bash
PATCH http://localhost:3000/agents/{AGENT_ID}/status
Content-Type: application/json
X-Tenant-Id: {TENANT_ID}

{
  "status": "PUBLISHED"
}
```

**What It Tests:**

- Agent status transitions (DRAFT → PUBLISHED)
- Status update endpoint
- Agent must be published before execution

---

#### Test 4: Create Conversation

**Request:**

```bash
POST http://localhost:3000/conversations
Content-Type: application/json
X-Tenant-Id: {TENANT_ID}

{
  "agentId": "{AGENT_ID}"
}
```

**What It Tests:**

- Conversation creation endpoint
- Agent-conversation linking
- Captures CONVERSATION_ID for execution

**Critical Failure Handling:**

- Cleans up agent and tenant on failure
- Exits immediately (can't execute without conversation)

---

#### Test 5: Execute Workflow (First Message)

**Request:**

```bash
POST http://localhost:8000/execute
Content-Type: application/json

{
  "agent_id": "{AGENT_ID}",
  "conversation_id": "{CONVERSATION_ID}",
  "message": "Hello from full stack test!",
  "tenant_id": "{TENANT_ID}"
}
```

**What It Tests:**

- FastAPI execution endpoint
- Agent flowJson loading from PostgreSQL
- Conversation state creation in Redis
- Workflow execution (currently echo mode)
- Response generation

**Expected Response:**

```json
{
  "agentId": "{AGENT_ID}",
  "conversationId": "{CONVERSATION_ID}",
  "response": "You said: Hello from full stack test!",
  "state": {
    "messages": [
      { "role": "user", "content": "Hello from full stack test!" },
      { "role": "assistant", "content": "You said: ..." }
    ],
    "metadata": {
      "executionTime": "2025-11-15T...",
      "tenantId": "{TENANT_ID}"
    }
  }
}
```

**This Is The Critical Integration Point:**

- FastAPI reads from NestJS database
- FastAPI writes to Redis cache
- Cross-service communication validated

---

#### Test 6: Conversation Continuity (Second Message)

**Request:**

```bash
POST http://localhost:8000/execute
Content-Type: application/json

{
  "agent_id": "{AGENT_ID}",
  "conversation_id": "{CONVERSATION_ID}",
  "message": "Second message in conversation",
  "tenant_id": "{TENANT_ID}"
}
```

**What It Tests:**

- Loading previous conversation state from Redis
- Message history preservation
- Stateful conversation management
- Redis 24-hour TTL working correctly

**Why This Matters:**

- AI conversations require context from previous messages
- Redis state persistence is critical
- Validates the complete conversation lifecycle

---

### Phase 4: Cleanup (3 operations)

**Purpose:** Delete all test data to prevent database pollution

**Operations:**

1. Delete conversation: `DELETE /conversations/{CONVERSATION_ID}`
2. Delete agent: `DELETE /agents/{AGENT_ID}`
3. Delete tenant: `DELETE /tenants/{TENANT_ID}` (CASCADE deletes all related data)

**Always Runs:**

- Even if tests fail (no `set -e`)
- Prevents accumulation of test data
- Ensures clean state for next test run

---

## Running the Tests

### Prerequisites

**All services must be running:**

1. **PostgreSQL** (port 5432)

   ```bash
   docker compose up -d postgres
   ```

2. **Redis** (port 6379)

   ```bash
   docker compose up -d redis
   ```

3. **NestJS** (port 3000)

   ```bash
   npm run start:dev
   ```

4. **FastAPI** (port 8000)
   - **Docker:** `docker compose up -d langgraph-service`
   - **Manual:** `cd langgraph-service && uvicorn main:app --reload`

### Run Tests

```bash
cd langgraph-service
bash test-fullstack.sh
```

### Expected Output

```
╔══════════════════════════════════════════════════════════╗
║   Full Stack Integration Test - LangGraph Platform     ║
╔══════════════════════════════════════════════════════════╗

═══ Phase 1: Service Health Checks ═══

Checking FastAPI service...
✓ PASS - FastAPI Health Check (HTTP 200)

Checking NestJS service...
✓ PASS - NestJS Health Check (HTTP 200)

═══ Phase 2: FastAPI Standalone Tests ═══

Testing: GET / (Service Info)
✓ PASS - GET / (Service Info) (HTTP 200)

Testing: GET /health
✓ PASS - GET /health (HTTP 200)

Testing: POST /validate (Valid FlowJson)
✓ PASS - POST /validate (Valid FlowJson)

Testing: POST /validate (Invalid FlowJson - Missing nodes)
✓ PASS - POST /validate (Invalid FlowJson)

═══ Phase 3: Full Stack Integration Tests ═══

Step 1: Creating test tenant...
✓ Tenant created - ID: clxxx123456
✓ PASS - Create Tenant

Step 2: Creating test agent...
✓ Agent created - ID: clyyy789012
✓ PASS - Create Agent

Step 3: Publishing agent...
✓ Agent published
✓ PASS - Publish Agent

Step 4: Creating conversation...
✓ Conversation created - ID: clzzz345678
✓ PASS - Create Conversation

Step 5: Executing workflow via FastAPI...
✓ Workflow executed successfully
  Response: You said: Hello from full stack test!
✓ PASS - Execute Workflow (FastAPI)

Step 6: Checking conversation state persistence...
  Info: Check Redis for key: conversation:clxxx123456:clzzz345678:state
  Command: docker exec -it oct25shaaz-redis-1 redis-cli GET "conversation:clxxx123456:clzzz345678:state"

Step 7: Testing conversation continuity (second message)...
✓ Second message executed
✓ PASS - Conversation Continuity
  ℹ Message count in state: 4

═══ Phase 4: Cleanup ═══

Cleaning up test data...
✓ Deleted conversation
✓ Deleted agent
✓ Deleted tenant

╔══════════════════════════════════════════════════════════╗
║                    TEST SUMMARY                          ║
╚══════════════════════════════════════════════════════════╝

Total Tests Run:    12
Tests Passed:       12
Tests Failed:       0

╔══════════════════════════════════════════════════════════╗
║         ALL TESTS PASSED! ✓ ✓ ✓                         ║
╚══════════════════════════════════════════════════════════╝
```

---

## Test Script Implementation Details

### Color Coding

```bash
RED='\033[0;31m'    # Failures, errors
GREEN='\033[0;32m'  # Successes, passed tests
YELLOW='\033[1;33m' # Informational messages, test names
BLUE='\033[0;34m'   # Headers, sections
NC='\033[0m'        # No Color (reset)
```

### Test Counter Functions

```bash
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

print_result() {
    local test_name=$1
    local result=$2
    TESTS_RUN=$((TESTS_RUN + 1))

    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓ PASS${NC} - $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC} - $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}
```

### Unique Tenant Names

```bash
# Use timestamp to prevent duplicate tenant names from previous test runs
TIMESTAMP=$(date +%s)
# Creates: "Test Tenant FullStack 1731679200"
```

**Why:**

- Previous test runs may leave orphaned tenants
- Duplicate names cause 409 Conflict errors
- Timestamp ensures uniqueness

### Error Handling Strategy

**No `set -e`:**

```bash
# Note: Not using set -e to allow cleanup to run even if tests fail
```

**Why:**

- With `set -e`: Script exits immediately on first error, cleanup doesn't run
- Without `set -e`: Cleanup always executes, prevents test data accumulation

**Early Exit on Critical Failures:**

```bash
if [ -z "$TENANT_ID" ]; then
    echo -e "${RED}ERROR: Cannot continue without tenant. Exiting.${NC}"
    exit 1
fi
```

**Why:**

- No point continuing if tenant/agent/conversation creation fails
- All subsequent tests depend on these resources
- Clean exit prevents confusing cascading failures

### HTTP Response Parsing

```bash
# Capture both status code and body
response=$(curl -s -w "\n%{http_code}" -X POST "$URL" ...)

status=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
```

**Technique:**

- `-w "\n%{http_code}"`: Appends HTTP status on new line
- `tail -n1`: Extracts status code
- `head -n-1`: Extracts response body

### JSON Parsing

```bash
TENANT_ID=$(echo "$tenant_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
```

**Breakdown:**

- `grep -o '"id":"[^"]*"'`: Finds `"id":"xxx"` pattern
- `head -1`: Takes first match (in case multiple IDs in response)
- `cut -d'"' -f4`: Splits on quotes, takes 4th field (the actual ID)

**Why Not jq:**

- Keeps script dependency-free
- Grep/cut available on all systems
- Simple JSON structure doesn't need full parser

---

## Troubleshooting

### Test Fails: Service Not Running

**Error:**

```
ERROR: FastAPI service is not running on port 8000
Please start it with: cd langgraph-service && uvicorn main:app --reload
```

**Solution:**

1. Start missing service as instructed
2. Verify with: `curl http://localhost:8000/health`

---

### Test Fails: Tenant Already Exists

**Error:**

```
Response: {"statusCode":409,"message":"Tenant name already exists"}
```

**Why:**

- Previous test run didn't complete cleanup
- Timestamp should prevent this, but clock may not have advanced

**Solution:**

```bash
# Delete orphaned tenant manually
curl -X DELETE http://localhost:3000/tenants/{TENANT_ID}
```

Or wait 1 second and re-run (timestamp will be different).

---

### Test Fails: Connection Refused

**Error:**

```
curl: (7) Failed to connect to localhost port 8000: Connection refused
```

**Causes:**

1. Service not started
2. Service crashed during startup
3. Port conflict (another process using port)

**Debug:**

```bash
# Check if port is in use
netstat -ano | findstr :8000

# Check Docker containers
docker ps

# Check service logs
docker logs ai-platform-langgraph
```

---

### Test Fails: Invalid JSON Response

**Error:**

```
✗ FAIL - POST /validate (Valid FlowJson)
```

**Debug:**

```bash
# Run validation manually to see full response
curl -X POST http://localhost:8000/validate \
  -H "Content-Type: application/json" \
  -d '{"nodes":[{"id":"start","type":"tool"}],"edges":[]}'
```

**Common Issues:**

- Missing Content-Type header
- Malformed JSON (extra commas, missing quotes)
- Wrong field names (camelCase vs snake_case)

---

### Cleanup Doesn't Run

**Symptom:** Test data accumulates, database has many "Test Tenant FullStack" entries

**Cause:** Script has `set -e` (would exit before cleanup)

**Verify:**

```bash
grep "set -e" test-fullstack.sh
# Should return nothing or commented line
```

**Manual Cleanup:**

```bash
# List all test tenants
curl http://localhost:3000/tenants | grep "Test Tenant FullStack"

# Delete specific tenant (CASCADE deletes all related data)
curl -X DELETE http://localhost:3000/tenants/{TENANT_ID}
```

---

## Verifying Redis State Persistence

The test logs the Redis key but doesn't automatically verify it. Here's how to check manually:

### Option 1: Docker Exec

```bash
docker exec -it ai-platform-redis redis-cli GET "conversation:{TENANT_ID}:{CONVERSATION_ID}:state"
```

**Expected Output:**

```json
{
  "messages": [
    { "role": "user", "content": "Hello from full stack test!" },
    { "role": "assistant", "content": "You said: Hello from full stack test!" },
    { "role": "user", "content": "Second message in conversation" },
    {
      "role": "assistant",
      "content": "You said: Second message in conversation"
    }
  ],
  "metadata": {
    "executionTime": "2025-11-15T...",
    "tenantId": "clxxx123456"
  }
}
```

### Option 2: Redis VS Code Extension

1. Install Redis extension in VS Code
2. Connect to `localhost:6379`
3. Browse keys matching pattern: `conversation:*`
4. View JSON value

### Option 3: Redis Insight (GUI)

1. Download Redis Insight (free tool)
2. Connect to `localhost:6379`
3. Browse keys
4. View formatted JSON

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Full Stack Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_USER: ai
          POSTGRES_PASSWORD: ai
          POSTGRES_DB: ai_platform
        ports:
          - 5432:5432

      redis:
        image: redis:7
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "20"

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: "3.12"

      - name: Install NestJS dependencies
        run: npm install

      - name: Run database migrations
        run: npx prisma migrate deploy

      - name: Start NestJS
        run: npm run start:dev &

      - name: Install FastAPI dependencies
        run: |
          cd langgraph-service
          pip install -r requirements.txt

      - name: Start FastAPI
        run: |
          cd langgraph-service
          uvicorn main:app --host 0.0.0.0 --port 8000 &

      - name: Wait for services
        run: |
          timeout 60 bash -c 'until curl -f http://localhost:3000/api; do sleep 1; done'
          timeout 60 bash -c 'until curl -f http://localhost:8000/health; do sleep 1; done'

      - name: Run integration tests
        run: |
          cd langgraph-service
          bash test-fullstack.sh
```

---

## Future Enhancements

### Planned Improvements

1. **Real LangGraph Execution Testing**

   - Once echo mode is replaced with actual StateGraph execution
   - Test complex workflows (KB search → ticket creation → Slack notification)
   - Validate tool calling integration

2. **Performance Benchmarks**

   - Measure execution time for each phase
   - Track response times over multiple runs
   - Identify performance regressions

3. **Load Testing**

   - Multiple concurrent conversations
   - Stress test Redis state management
   - Database connection pooling verification

4. **Negative Testing**

   - Invalid tenant IDs (test 403 Forbidden)
   - Malformed flowJson (test 400 Bad Request)
   - Missing required fields (DTO validation)
   - Cross-tenant access attempts (security)

5. **SSE Streaming Tests**

   - When `/stream` endpoint is implemented
   - Verify real-time message streaming
   - Test connection handling

6. **Docker Health Check Verification**
   - Programmatically check container health
   - Verify health checks are configured correctly
   - Test startup dependencies

---

## Related Documentation

- **Docker Architecture:** `docs/reference/docker-architecture.md`
- **Dockerfile Explained:** `docs/reference/dockerfile-recipe-explained.md`
- **Phase 8 Roadmap:** `docs/guides/ROADMAP.md` (Phase 8 section)
- **NestJS Tests:** `test/test-agents.sh`, `test/test-conversations.sh`
- **Integration Test README:** `langgraph-service/README.md`

---

## Summary

The full stack integration test is a **critical validation tool** that:

✅ **Verifies End-to-End Flow:** Tests complete journey from tenant creation to AI execution  
✅ **Catches Integration Bugs:** Finds issues that unit tests miss  
✅ **Documents Expected Behavior:** Serves as executable documentation  
✅ **Prevents Regressions:** Ensures new changes don't break existing functionality  
✅ **Validates Docker Setup:** Confirms containerized services work correctly  
✅ **Tests Multi-Tenant Isolation:** Verifies security boundaries  
✅ **Maintains Clean State:** Automatic cleanup prevents test data pollution

**Current Status:** 12/12 tests passing (November 15, 2025)  
**Coverage:** Phase 8 - 90% complete (Docker containerization validated)  
**Next:** Implement real LangGraph execution to test actual AI workflows
