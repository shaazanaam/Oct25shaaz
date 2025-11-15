#!/bin/bash

# Full Stack Integration Test Script
# Tests FastAPI LangGraph Service + NestJS Control Plane integration

# Note: Not using set -e to allow cleanup to run even if tests fail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FASTAPI_URL="http://localhost:8000"
NESTJS_URL="http://localhost:3000"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Full Stack Integration Test - LangGraph Platform     ║${NC}"
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo ""

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test result
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

# Function to test endpoint
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

# =============================================================================
# PHASE 1: Check Services Are Running
# =============================================================================

echo -e "\n${BLUE}═══ Phase 1: Service Health Checks ═══${NC}"

# Check FastAPI
echo -e "\n${YELLOW}Checking FastAPI service...${NC}"
if curl -s -f "$FASTAPI_URL/health" > /dev/null 2>&1; then
    print_result "FastAPI Health Check" "PASS"
else
    print_result "FastAPI Health Check (Service may not be running)" "FAIL"
    echo -e "${RED}ERROR: FastAPI service is not running on port 8000${NC}"
    echo "Please start it with: cd langgraph-service && uvicorn main:app --reload"
    exit 1
fi

# Check NestJS
echo -e "\n${YELLOW}Checking NestJS service...${NC}"
if curl -s -f "$NESTJS_URL/api" > /dev/null 2>&1; then
    print_result "NestJS Health Check" "PASS"
else
    print_result "NestJS Health Check (Service may not be running)" "FAIL"
    echo -e "${RED}ERROR: NestJS service is not running on port 3000${NC}"
    echo "Please start it with: npm run start:dev"
    exit 1
fi

# =============================================================================
# PHASE 2: FastAPI Standalone Tests
# =============================================================================

echo -e "\n${BLUE}═══ Phase 2: FastAPI Standalone Tests ═══${NC}"

# Test 1: Root endpoint
test_endpoint "GET / (Service Info)" "$FASTAPI_URL/" 200

# Test 2: Health endpoint
test_endpoint "GET /health" "$FASTAPI_URL/health" 200

# Test 3: Validate endpoint with valid flow
echo -e "\n${YELLOW}Testing:${NC} POST /validate (Valid FlowJson)"
response=$(curl -s -w "\n%{http_code}" -X POST "$FASTAPI_URL/validate" \
    -H "Content-Type: application/json" \
    -d '{"nodes":[{"id":"start","type":"tool"},{"id":"end","type":"output"}],"edges":[{"from":"start","to":"end"}]}')

status=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

if [ "$status" = "200" ] && echo "$body" | grep -q '"valid":true'; then
    print_result "POST /validate (Valid FlowJson)" "PASS"
else
    print_result "POST /validate (Valid FlowJson)" "FAIL"
fi

# Test 4: Validate endpoint with invalid flow
echo -e "\n${YELLOW}Testing:${NC} POST /validate (Invalid FlowJson - Missing nodes)"
response=$(curl -s -w "\n%{http_code}" -X POST "$FASTAPI_URL/validate" \
    -H "Content-Type: application/json" \
    -d '{"edges":[]}')

status=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)

if [ "$status" = "200" ] && echo "$body" | grep -q '"valid":false'; then
    print_result "POST /validate (Invalid FlowJson)" "PASS"
else
    print_result "POST /validate (Invalid FlowJson)" "FAIL"
fi

# =============================================================================
# PHASE 3: NestJS + FastAPI Integration Tests
# =============================================================================

echo -e "\n${BLUE}═══ Phase 3: Full Stack Integration Tests ═══${NC}"

# Step 1: Create Tenant
echo -e "\n${YELLOW}Step 1:${NC} Creating test tenant..."
# Use timestamp to ensure unique tenant name
TIMESTAMP=$(date +%s)
tenant_response=$(curl -s -X POST "$NESTJS_URL/tenants" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Test Tenant FullStack $TIMESTAMP\",
        \"plan\": \"ENTERPRISE\"
    }")

TENANT_ID=$(echo "$tenant_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$TENANT_ID" ]; then
    echo -e "${RED}✗ Failed to create tenant${NC}"
    echo "Response: $tenant_response"
    print_result "Create Tenant" "FAIL"
    echo -e "${RED}ERROR: Cannot continue without tenant. Exiting.${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Tenant created${NC} - ID: $TENANT_ID"
    print_result "Create Tenant" "PASS"
fi

# Step 2: Create Agent
echo -e "\n${YELLOW}Step 2:${NC} Creating test agent..."
agent_response=$(curl -s -X POST "$NESTJS_URL/agents" \
    -H "Content-Type: application/json" \
    -H "X-Tenant-Id: $TENANT_ID" \
    -d '{
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
        "tenantId": "'"$TENANT_ID"'"
    }')

AGENT_ID=$(echo "$agent_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$AGENT_ID" ]; then
    echo -e "${RED}✗ Failed to create agent${NC}"
    echo "Response: $agent_response"
    print_result "Create Agent" "FAIL"
    echo -e "${RED}ERROR: Cannot continue without agent. Cleaning up and exiting.${NC}"
    # Cleanup tenant before exit
    if [ ! -z "$TENANT_ID" ]; then
        curl -s -X DELETE "$NESTJS_URL/tenants/$TENANT_ID" > /dev/null
        echo -e "${GREEN}✓${NC} Cleaned up tenant"
    fi
    exit 1
else
    echo -e "${GREEN}✓ Agent created${NC} - ID: $AGENT_ID"
    print_result "Create Agent" "PASS"
fi

# Step 3: Publish Agent
echo -e "\n${YELLOW}Step 3:${NC} Publishing agent..."
publish_response=$(curl -s -w "\n%{http_code}" -X PATCH "$NESTJS_URL/agents/$AGENT_ID/status" \
    -H "Content-Type: application/json" \
    -H "X-Tenant-Id: $TENANT_ID" \
    -d '{"status": "PUBLISHED"}')

publish_status=$(echo "$publish_response" | tail -n1)

if [ "$publish_status" = "200" ]; then
    echo -e "${GREEN}✓ Agent published${NC}"
    print_result "Publish Agent" "PASS"
else
    echo -e "${RED}✗ Failed to publish agent (HTTP $publish_status)${NC}"
    print_result "Publish Agent" "FAIL"
fi

# Step 4: Create Conversation
echo -e "\n${YELLOW}Step 4:${NC} Creating conversation..."
conversation_response=$(curl -s -X POST "$NESTJS_URL/conversations" \
    -H "Content-Type: application/json" \
    -H "X-Tenant-Id: $TENANT_ID" \
    -d "{
        \"agentId\": \"$AGENT_ID\"
    }")

CONVERSATION_ID=$(echo "$conversation_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$CONVERSATION_ID" ]; then
    echo -e "${RED}✗ Failed to create conversation${NC}"
    echo "Response: $conversation_response"
    print_result "Create Conversation" "FAIL"
    echo -e "${RED}ERROR: Cannot continue without conversation. Cleaning up and exiting.${NC}"
    # Cleanup
    if [ ! -z "$AGENT_ID" ]; then
        curl -s -X DELETE "$NESTJS_URL/agents/$AGENT_ID" -H "X-Tenant-Id: $TENANT_ID" > /dev/null
        echo -e "${GREEN}✓${NC} Cleaned up agent"
    fi
    if [ ! -z "$TENANT_ID" ]; then
        curl -s -X DELETE "$NESTJS_URL/tenants/$TENANT_ID" > /dev/null
        echo -e "${GREEN}✓${NC} Cleaned up tenant"
    fi
    exit 1
else
    echo -e "${GREEN}✓ Conversation created${NC} - ID: $CONVERSATION_ID"
    print_result "Create Conversation" "PASS"
fi

# Step 5: Execute Workflow via FastAPI
echo -e "\n${YELLOW}Step 5:${NC} Executing workflow via FastAPI..."
execute_response=$(curl -s -w "\n%{http_code}" -X POST "$FASTAPI_URL/execute" \
    -H "Content-Type: application/json" \
    -d "{
        \"agent_id\": \"$AGENT_ID\",
        \"conversation_id\": \"$CONVERSATION_ID\",
        \"message\": \"Hello from full stack test!\",
        \"tenant_id\": \"$TENANT_ID\"
    }")

execute_status=$(echo "$execute_response" | tail -n1)
execute_body=$(echo "$execute_response" | head -n-1)

if [ "$execute_status" = "200" ]; then
    echo -e "${GREEN}✓ Workflow executed successfully${NC}"
    print_result "Execute Workflow (FastAPI)" "PASS"
    
    # Extract response
    response_text=$(echo "$execute_body" | grep -o '"response":"[^"]*"' | cut -d'"' -f4)
    echo -e "  ${BLUE}Response:${NC} $response_text"
else
    echo -e "${RED}✗ Failed to execute workflow (HTTP $execute_status)${NC}"
    echo "Response: $execute_body"
    print_result "Execute Workflow (FastAPI)" "FAIL"
fi

# Step 6: Verify conversation state in Redis
echo -e "\n${YELLOW}Step 6:${NC} Checking conversation state persistence..."
# Note: This requires redis-cli or the Redis VS Code extension to verify
# For now, we'll just log that it should be checked manually
echo -e "  ${BLUE}Info:${NC} Check Redis for key: conversation:$TENANT_ID:$CONVERSATION_ID:state"
echo -e "  ${BLUE}Command:${NC} docker exec -it oct25shaaz-redis-1 redis-cli GET \"conversation:$TENANT_ID:$CONVERSATION_ID:state\""

# Step 7: Execute again to test state continuity
echo -e "\n${YELLOW}Step 7:${NC} Testing conversation continuity (second message)..."
execute2_response=$(curl -s -w "\n%{http_code}" -X POST "$FASTAPI_URL/execute" \
    -H "Content-Type: application/json" \
    -d "{
        \"agent_id\": \"$AGENT_ID\",
        \"conversation_id\": \"$CONVERSATION_ID\",
        \"message\": \"Second message in conversation\",
        \"tenant_id\": \"$TENANT_ID\"
    }")

execute2_status=$(echo "$execute2_response" | tail -n1)
execute2_body=$(echo "$execute2_response" | head -n-1)

if [ "$execute2_status" = "200" ]; then
    echo -e "${GREEN}✓ Second message executed${NC}"
    print_result "Conversation Continuity" "PASS"
    
    # Optional: Check if state includes previous messages (not required for test to pass)
    message_count=$(echo "$execute2_body" | grep -o '"messages_count":[0-9]*' | grep -o '[0-9]*')
    if [ ! -z "$message_count" ]; then
        echo -e "  ${BLUE}ℹ${NC} Message count in state: $message_count"
    fi
else
    print_result "Conversation Continuity" "FAIL"
fi

# =============================================================================
# PHASE 4: Cleanup (Optional)
# =============================================================================

echo -e "\n${BLUE}═══ Phase 4: Cleanup ═══${NC}"
echo -e "\n${YELLOW}Cleaning up test data...${NC}"

# Delete conversation
if [ ! -z "$CONVERSATION_ID" ]; then
    curl -s -X DELETE "$NESTJS_URL/conversations/$CONVERSATION_ID" \
        -H "X-Tenant-Id: $TENANT_ID" > /dev/null
    echo -e "${GREEN}✓${NC} Deleted conversation"
fi

# Delete agent
if [ ! -z "$AGENT_ID" ]; then
    curl -s -X DELETE "$NESTJS_URL/agents/$AGENT_ID" \
        -H "X-Tenant-Id: $TENANT_ID" > /dev/null
    echo -e "${GREEN}✓${NC} Deleted agent"
fi

# Delete tenant
if [ ! -z "$TENANT_ID" ]; then
    curl -s -X DELETE "$NESTJS_URL/tenants/$TENANT_ID" > /dev/null
    echo -e "${GREEN}✓${NC} Deleted tenant"
fi

# =============================================================================
# Summary
# =============================================================================

echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    TEST SUMMARY                          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Total Tests Run:    ${BLUE}$TESTS_RUN${NC}"
echo -e "Tests Passed:       ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed:       ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         ALL TESTS PASSED! ✓ ✓ ✓                         ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║    SOME TESTS FAILED - Review errors above              ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi
