# Testing Documentation

This directory contains automated test scripts for the AI Platform APIs.

---

## Test Scripts Overview

### NestJS Control Plane Tests

Located in this directory (`test/`):

- **`test-agents.sh`** - Agent Management API (10 tests)
- **`test-conversations.sh`** - Conversation API (15 tests)
- **`test-documents.sh`** - Document Management API (12 tests)
- **`test-tools.sh`** - Tool Configuration API (12 tests)

### FastAPI Execution Plane Tests

Located in `langgraph-service/`:

- **`test-fullstack.sh`** - Full stack integration testing (12 tests)
  - Tests NestJS + FastAPI + PostgreSQL + Redis integration
  - End-to-end workflow execution
  - See: `docs/reference/integration-testing-guide.md` for comprehensive documentation

---

## Full Stack Integration Testing

**Location:** `langgraph-service/test-fullstack.sh`

**Purpose:** End-to-end testing of the complete AI platform architecture

**What It Tests:**

- ✅ Service health (FastAPI + NestJS)
- ✅ FastAPI standalone endpoints (/, /health, /validate)
- ✅ Full integration flow (tenant → agent → conversation → execute)
- ✅ Conversation state persistence in Redis
- ✅ Multi-message conversation continuity
- ✅ Automatic cleanup of test data

**Documentation:** See **`docs/reference/integration-testing-guide.md`** for:

- Complete test phase breakdown
- Expected request/response examples
- Troubleshooting guide
- CI/CD integration examples
- Redis state verification

**Quick Run:**

```bash
cd langgraph-service
bash test-fullstack.sh
```

**Expected:** 12/12 tests passing (all phases complete)

---

## NestJS Control Plane Testing

### Agent Endpoints Testing (`test-agents.sh`)

**Tests:** 10 scenarios

1. ✓ Server health check
2. ✓ Create Tenant (POST /tenants)
3. ✓ Create Agent (POST /agents)
4. ✓ List All Agents (GET /agents)
5. ✓ Get Single Agent (GET /agents/:id)
6. ✓ Update Agent Status (PATCH /agents/:id/status)
7. ✓ Update Agent (PATCH /agents/:id)
8. ✓ Tenant Isolation Security (verify 404 from different tenant)
9. ✓ Delete Agent (DELETE /agents/:id)
10. ✓ Verify Deletion (confirm 404 after delete)

**Run:**

```bash
./test/test-agents.sh
```

---

### Conversation Endpoints Testing (`test-conversations.sh`)

**Tests:** 15 scenarios

Includes message creation, retrieval, conversation management, and cleanup.

**Run:**

```bash
./test/test-conversations.sh
```

---

### Document Endpoints Testing (`test-documents.sh`)

**Tests:** 12 scenarios

Includes document upload metadata, search functionality, and tenant isolation.

**Run:**

```bash
./test/test-documents.sh
```

---

### Tool Endpoints Testing (`test-tools.sh`)

**Tests:** 12 scenarios

Includes tool registration, configuration, authentication, and tenant isolation.

**Run:**

```bash
./test/test-tools.sh
```

---

## Prerequisites

### All Tests Require:

1. **Docker containers running:**

   ```bash
   docker compose up -d
   ```

   Starts PostgreSQL (5432) and Redis (6379)

2. **NestJS server running:**
   ```bash
   npm run start:dev
   ```
   Runs on http://localhost:3000

### Full Stack Integration Test Also Requires:

3. **FastAPI service running:**

   **Option A - Docker (recommended):**

   ```bash
   docker compose up -d langgraph-service
   ```

   **Option B - Manual:**

   ```bash
   cd langgraph-service
   source venv/Scripts/activate
   uvicorn main:app --reload
   ```

   Runs on http://localhost:8000

---

## Running Tests

### Run Individual Test Suite

```bash
# Agent tests
./test/test-agents.sh

# Conversation tests
./test/test-conversations.sh

# Document tests
./test/test-documents.sh

# Tool tests
./test/test-tools.sh

# Full stack integration
cd langgraph-service && bash test-fullstack.sh
```

### Run All NestJS Tests

```bash
# From project root
for test in test/*.sh; do bash "$test"; done
```

### Run Complete Test Suite (NestJS + FastAPI)

```bash
# Run all NestJS tests
for test in test/*.sh; do bash "$test"; done

# Run full stack integration
cd langgraph-service && bash test-fullstack.sh
```

---

## Test Output

All scripts provide **color-coded output:**

- 🟢 **Green** = Success (PASS)
- 🔴 **Red** = Failure (FAIL)
- 🟡 **Yellow** = Info/Progress
- 🔵 **Blue** = Section headers

**Example:**

```
═══ Phase 1: Service Health Checks ═══

Checking FastAPI service...
✓ PASS - FastAPI Health Check (HTTP 200)

Checking NestJS service...
✓ PASS - NestJS Health Check (HTTP 200)

...

╔══════════════════════════════════════════════════════════╗
║                    TEST SUMMARY                          ║
╚══════════════════════════════════════════════════════════╝

Total Tests Run:    12
Tests Passed:       12
Tests Failed:       0
```

---

## Troubleshooting

### Error: "Server is not running"

**Cause:** NestJS not started

**Solution:**

```bash
npm run start:dev
```

Verify: http://localhost:3000/api should show Swagger UI

---

### Error: "FastAPI service is not running"

**Cause:** FastAPI not started (full stack test only)

**Solution:**

```bash
# Option 1: Docker
docker compose up -d langgraph-service

# Option 2: Manual
cd langgraph-service
uvicorn main:app --reload
```

Verify: http://localhost:8000/health should return `{"status":"healthy"}`

---

### Error: "Connection refused" (PostgreSQL/Redis)

**Cause:** Docker containers not running

**Solution:**

```bash
docker compose up -d
docker ps  # Verify containers are running
```

---

### Error: "Tenant already exists" (409 Conflict)

**Cause:** Previous test run didn't complete cleanup

**Solution:**

**Option 1 - Automated (full stack test):**

- Test automatically uses unique timestamp-based names
- Should not occur unless run twice in same second

**Option 2 - Manual cleanup:**

```bash
# List tenants
curl http://localhost:3000/tenants

# Delete orphaned test tenant
curl -X DELETE http://localhost:3000/tenants/{TENANT_ID}
```

---

### Error: "curl: command not found"

**Cause:** Curl not installed

**Solution:**

- Windows: Use Git Bash (includes curl)
- Or install curl for Windows
- Or use WSL (Windows Subsystem for Linux)

---

### Tests Pass Locally But Fail in CI/CD

**Common Issues:**

1. **Service startup timing:** Add wait loops in CI config

   ```bash
   timeout 60 bash -c 'until curl -f http://localhost:3000/api; do sleep 1; done'
   ```

2. **Port conflicts:** CI environment may have services on same ports

3. **Database state:** Ensure fresh database for each CI run

---

## Test Development Guidelines

### Adding New Tests

1. Follow existing script structure (4 phases)
2. Use color-coded output functions
3. Include cleanup phase
4. Use unique identifiers (timestamps) for test data
5. Test both happy path and error cases
6. Verify tenant isolation

### Example Test Function

```bash
test_endpoint() {
    local name=$1
    local url=$2
    local expected_status=$3

    echo -e "\n${YELLOW}Testing:${NC} $name"

    status=$(curl -s -o /dev/null -w "%{http_code}" "$url")

    if [ "$status" = "$expected_status" ]; then
        print_result "$name (HTTP $status)" "PASS"
        return 0
    else
        print_result "$name (Expected $expected_status, got $status)" "FAIL"
        return 1
    fi
}
```

---

## Documentation

- **Integration Testing Guide:** `docs/reference/integration-testing-guide.md`

  - Comprehensive documentation for full stack integration test
  - Phase-by-phase breakdown
  - Expected request/response examples
  - Troubleshooting guide
  - CI/CD integration

- **Docker Architecture:** `docs/reference/docker-architecture.md`

  - Container setup and configuration
  - Network connectivity
  - Health checks

- **API Documentation:** http://localhost:3000/api (Swagger UI)
  - Interactive API documentation
  - Try endpoints directly in browser

---

## Current Test Status (November 15, 2025)

### NestJS Control Plane

- ✅ Agent Management: 10/10 passing
- ✅ Conversation Management: 15/15 passing
- ✅ Document Management: 12/12 passing
- ✅ Tool Management: 12/12 passing

### FastAPI Execution Plane

- ✅ Full Stack Integration: 12/12 passing
- ✅ All 4 phases complete (health, standalone, integration, cleanup)
- ✅ Docker containerization validated
- ✅ Redis state persistence confirmed

**Total:** 61 automated tests, all passing

---

## Future Enhancements

1. **Real LangGraph Execution Testing**

   - Once echo mode is replaced
   - Test complex workflows (KB → ticket → Slack)

2. **Performance Benchmarks**

   - Track execution times
   - Identify regressions

3. **Load Testing**

   - Concurrent conversations
   - Redis connection pooling

4. **Security Testing**

   - Cross-tenant access attempts
   - Invalid authentication tokens
   - SQL injection attempts

5. **SSE Streaming Tests**
   - When `/stream` endpoint implemented
   - Real-time message streaming

---

## Support

For issues or questions:

1. Check this README
2. Review integration testing guide: `docs/reference/integration-testing-guide.md`
3. Check Docker architecture: `docs/reference/docker-architecture.md`
4. Review ROADMAP: `docs/guides/ROADMAP.md`
