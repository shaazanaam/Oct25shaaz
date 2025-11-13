#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}================================${NC}"
echo -e "${CYAN}  Testing Agent Endpoints${NC}"
echo -e "${CYAN}================================${NC}"

# Check if server is running
echo -e "\n${YELLOW}[0] Checking if server is running...${NC}"
SERVER_CHECK=$(curl -s http://localhost:3000/health 2>&1)
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Server is not running on http://localhost:3000${NC}"
    echo -e "${YELLOW}Please start the server with: npm run start:dev${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Server is running${NC}"

# Test 1: Create Tenant with unique name
echo -e "\n${YELLOW}[1] Creating Tenant...${NC}"
TIMESTAMP=$(date +%s)
TENANT_NAME="Test Company $TIMESTAMP"

TENANT_RESPONSE=$(curl -s -X POST http://localhost:3000/tenants \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$TENANT_NAME\",\"plan\":\"PRO\"}")

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to create tenant${NC}"
    exit 1
fi

echo "$TENANT_RESPONSE" | python -m json.tool 2>/dev/null || echo "$TENANT_RESPONSE"
TENANT_ID=$(echo $TENANT_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$TENANT_ID" ]; then
    echo -e "${RED}✗ Failed to extract Tenant ID${NC}"
    echo -e "${RED}Response was: $TENANT_RESPONSE${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Tenant created with ID: $TENANT_ID${NC}"

# Test 2: Create Agent
echo -e "\n${YELLOW}[2] Creating Agent...${NC}"
AGENT_RESPONSE=$(curl -s -X POST http://localhost:3000/agents \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d "{
    \"name\": \"IT Support Bot\",
    \"version\": \"1.0.0\",
    \"flowJson\": {
      \"nodes\": [
        {\"id\": \"kb_search\", \"type\": \"tool\"},
        {\"id\": \"get_feedback\", \"type\": \"user_input\"},
        {\"id\": \"create_ticket\", \"type\": \"tool\"}
      ],
      \"edges\": [
        {\"from\": \"kb_search\", \"to\": \"get_feedback\"},
        {\"from\": \"get_feedback\", \"to\": \"create_ticket\"}
      ]
    },
    \"tenantId\": \"$TENANT_ID\"
  }")

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to create agent${NC}"
    exit 1
fi

echo "$AGENT_RESPONSE" | python -m json.tool 2>/dev/null || echo "$AGENT_RESPONSE"
AGENT_ID=$(echo $AGENT_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$AGENT_ID" ]; then
    echo -e "${RED}✗ Failed to extract Agent ID${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Agent created with ID: $AGENT_ID${NC}"

# Test 3: List All Agents
echo -e "\n${YELLOW}[3] Listing All Agents...${NC}"
LIST_RESPONSE=$(curl -s -X GET http://localhost:3000/agents \
  -H "X-Tenant-Id: $TENANT_ID")

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to list agents${NC}"
    exit 1
fi

echo "$LIST_RESPONSE" | python -m json.tool 2>/dev/null || echo "$LIST_RESPONSE"
AGENT_COUNT=$(echo $LIST_RESPONSE | grep -o '"id"' | wc -l)
echo -e "${GREEN}✓ Found $AGENT_COUNT agent(s)${NC}"

# Test 4: Get Single Agent
echo -e "\n${YELLOW}[4] Getting Single Agent...${NC}"
GET_RESPONSE=$(curl -s -X GET http://localhost:3000/agents/$AGENT_ID \
  -H "X-Tenant-Id: $TENANT_ID")

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to get agent${NC}"
    exit 1
fi

echo "$GET_RESPONSE" | python -m json.tool 2>/dev/null || echo "$GET_RESPONSE"
echo -e "${GREEN}✓ Successfully retrieved agent${NC}"

# Test 5: Update Agent Status
echo -e "\n${YELLOW}[5] Updating Agent Status to PUBLISHED...${NC}"
STATUS_RESPONSE=$(curl -s -X PATCH http://localhost:3000/agents/$AGENT_ID/status \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{"status":"PUBLISHED"}')

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to update status${NC}"
    exit 1
fi

echo "$STATUS_RESPONSE" | python -m json.tool 2>/dev/null || echo "$STATUS_RESPONSE"
NEW_STATUS=$(echo $STATUS_RESPONSE | grep -o '"status":"[^"]*' | cut -d'"' -f4)
echo -e "${GREEN}✓ Status updated to: $NEW_STATUS${NC}"

# Test 6: Update Agent Name and Version
echo -e "\n${YELLOW}[6] Updating Agent Name and Version...${NC}"
UPDATE_RESPONSE=$(curl -s -X PATCH http://localhost:3000/agents/$AGENT_ID \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{"name":"IT Support Bot v2","version":"1.1.0"}')

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to update agent${NC}"
    exit 1
fi

echo "$UPDATE_RESPONSE" | python -m json.tool 2>/dev/null || echo "$UPDATE_RESPONSE"
echo -e "${GREEN}✓ Agent updated successfully${NC}"

# Test 7: Test Tenant Isolation
echo -e "\n${YELLOW}[7] Testing Tenant Isolation...${NC}"
TENANT2_NAME="Another Company $TIMESTAMP"
TENANT2_RESPONSE=$(curl -s -X POST http://localhost:3000/tenants \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$TENANT2_NAME\",\"plan\":\"FREE\"}")
TENANT2_ID=$(echo $TENANT2_RESPONSE | grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)
echo -e "Created second tenant: $TENANT2_ID"

ISOLATION_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET http://localhost:3000/agents/$AGENT_ID \
  -H "X-Tenant-Id: $TENANT2_ID")
HTTP_CODE=$(echo "$ISOLATION_RESPONSE" | tail -n1)
BODY=$(echo "$ISOLATION_RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "404" ]; then
    echo -e "${GREEN}✓ Tenant isolation working correctly (404 as expected)${NC}"
else
    echo -e "${RED}✗ SECURITY ISSUE: Tenant isolation broken! Got HTTP $HTTP_CODE${NC}"
    echo "$BODY"
fi

# Test 8: Delete Agent
echo -e "\n${YELLOW}[8] Deleting Agent...${NC}"
DELETE_RESPONSE=$(curl -s -X DELETE http://localhost:3000/agents/$AGENT_ID \
  -H "X-Tenant-Id: $TENANT_ID")

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to delete agent${NC}"
    exit 1
fi

echo "$DELETE_RESPONSE" | python -m json.tool 2>/dev/null || echo "$DELETE_RESPONSE"
echo -e "${GREEN}✓ Agent deleted successfully${NC}"

# Verify deletion
echo -e "\n${YELLOW}[9] Verifying deletion...${NC}"
VERIFY_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET http://localhost:3000/agents/$AGENT_ID \
  -H "X-Tenant-Id: $TENANT_ID")
VERIFY_HTTP_CODE=$(echo "$VERIFY_RESPONSE" | tail -n1)

if [ "$VERIFY_HTTP_CODE" = "404" ]; then
    echo -e "${GREEN}✓ Agent successfully deleted (404 confirmed)${NC}"
else
    echo -e "${RED}✗ Agent still exists! Got HTTP $VERIFY_HTTP_CODE${NC}"
fi

# Summary
echo -e "\n${CYAN}================================${NC}"
echo -e "${CYAN}  Test Summary${NC}"
echo -e "${CYAN}================================${NC}"
echo -e "${GREEN}✓ All tests completed!${NC}"
echo -e "\nTenant ID: ${YELLOW}$TENANT_ID${NC}"
echo -e "Agent ID: ${YELLOW}$AGENT_ID${NC}"
echo -e "Second Tenant ID: ${YELLOW}$TENANT2_ID${NC}"
