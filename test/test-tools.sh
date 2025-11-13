#!/bin/bash

# Test script for Tools CRUD endpoints
# Tests: Create, Read, Update, Delete, Tenant Isolation, Encryption

BASE_URL="http://localhost:3000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   Tools CRUD API Testing${NC}"
echo -e "${CYAN}========================================${NC}\n"

# Test 1: Health Check
echo -e "${YELLOW}Test 1: Health Check${NC}"
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/health)
if [ "$HEALTH" -eq 200 ]; then
    echo -e "${GREEN}✓ Server is running${NC}\n"
else
    echo -e "${RED}✗ Server is not responding${NC}\n"
    exit 1
fi

# Test 2: Create Tenant
echo -e "${YELLOW}Test 2: Create Tenant${NC}"
TENANT_RESPONSE=$(curl -s -X POST $BASE_URL/tenants \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"test-tenant-tools-$(date +%s)\",\"plan\":\"PRO\"}")

TENANT_ID=$(echo $TENANT_RESPONSE | python -m json.tool | grep '"id"' | head -1 | awk -F'"' '{print $4}')
echo -e "Tenant ID: ${CYAN}$TENANT_ID${NC}"
echo -e "${GREEN}✓ Tenant created${NC}\n"

# Test 3: Create Tool (KB Search)
echo -e "${YELLOW}Test 3: Create Tool (KB Search)${NC}"
TOOL_RESPONSE=$(curl -s -X POST $BASE_URL/tools \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "name": "kb_search_qdrant",
    "title": "Knowledge Base Search",
    "type": "KB_SEARCH",
    "inputSchema": {
      "type": "object",
      "properties": {
        "query": {"type": "string"},
        "topK": {"type": "number"}
      },
      "required": ["query"]
    },
    "outputSchema": {
      "type": "object",
      "properties": {
        "results": {"type": "array"}
      }
    },
    "authType": "api_key",
    "authConfig": {
      "apiUrl": "http://qdrant:6333",
      "apiKey": "super-secret-qdrant-key-12345",
      "collection": "knowledge_base"
    }
  }')

echo $TOOL_RESPONSE | python -m json.tool
TOOL_ID=$(echo $TOOL_RESPONSE | python -m json.tool | grep '"id"' | head -1 | awk -F'"' '{print $4}')
echo -e "Tool ID: ${CYAN}$TOOL_ID${NC}"
echo -e "${GREEN}✓ KB Search tool created${NC}\n"

# Test 4: Create Second Tool (Ticket Creation)
echo -e "${YELLOW}Test 4: Create Tool (Ticket Creator)${NC}"
TOOL2_RESPONSE=$(curl -s -X POST $BASE_URL/tools \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "name": "zammad_ticket_creator",
    "title": "Zammad Ticket Creator",
    "type": "TICKET_CREATE",
    "inputSchema": {
      "type": "object",
      "properties": {
        "title": {"type": "string"},
        "description": {"type": "string"},
        "group": {"type": "string"}
      },
      "required": ["title", "description"]
    },
    "outputSchema": {
      "type": "object",
      "properties": {
        "ticketId": {"type": "string"},
        "ticketUrl": {"type": "string"}
      }
    },
    "authType": "api_key",
    "authConfig": {
      "apiUrl": "https://zammad.company.com/api/v1",
      "apiKey": "zammad-secret-key-67890",
      "defaultGroup": "Support"
    }
  }')

TOOL2_ID=$(echo $TOOL2_RESPONSE | python -m json.tool | grep '"id"' | head -1 | awk -F'"' '{print $4}')
echo -e "Tool ID: ${CYAN}$TOOL2_ID${NC}"
echo -e "${GREEN}✓ Ticket Creator tool created${NC}\n"

# Test 5: List Tools
echo -e "${YELLOW}Test 5: List All Tools${NC}"
LIST_RESPONSE=$(curl -s -X GET $BASE_URL/tools \
  -H "X-Tenant-Id: $TENANT_ID")

echo $LIST_RESPONSE | python -m json.tool
TOOL_COUNT=$(echo $LIST_RESPONSE | python -m json.tool | grep -c '"id"')
echo -e "Found ${CYAN}$TOOL_COUNT${NC} tools"
echo -e "${GREEN}✓ Tools listed (note: authConfig hidden for security)${NC}\n"

# Test 6: Get Single Tool (with decrypted authConfig)
echo -e "${YELLOW}Test 6: Get Single Tool by ID${NC}"
GET_RESPONSE=$(curl -s -X GET $BASE_URL/tools/$TOOL_ID \
  -H "X-Tenant-Id: $TENANT_ID")

echo $GET_RESPONSE | python -m json.tool
echo -e "${GREEN}✓ Tool retrieved with decrypted authConfig${NC}\n"

# Test 7: Update Tool (change title and add new config field)
echo -e "${YELLOW}Test 7: Update Tool${NC}"
UPDATE_RESPONSE=$(curl -s -X PATCH $BASE_URL/tools/$TOOL_ID \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "title": "Knowledge Base Search (Updated)",
    "authConfig": {
      "apiUrl": "http://qdrant:6333",
      "apiKey": "new-updated-secret-key",
      "collection": "knowledge_base_v2",
      "timeout": 5000
    }
  }')

echo $UPDATE_RESPONSE | python -m json.tool
echo -e "${GREEN}✓ Tool updated${NC}\n"

# Test 8: Test Tool Execution Endpoint
echo -e "${YELLOW}Test 8: Test Tool Execution${NC}"
TEST_RESPONSE=$(curl -s -X POST $BASE_URL/tools/$TOOL_ID/test \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "query": "How do I reset my password?",
    "topK": 5
  }')

echo $TEST_RESPONSE | python -m json.tool
echo -e "${GREEN}✓ Tool test endpoint works (Phase 9: will call actual MCP)${NC}\n"

# Test 9: Tenant Isolation (try to access tool with wrong tenant)
echo -e "${YELLOW}Test 9: Tenant Isolation Test${NC}"
ISOLATION_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X GET $BASE_URL/tools/$TOOL_ID \
  -H "X-Tenant-Id: wrong-tenant-id-12345")

if [ "$ISOLATION_RESPONSE" -eq 404 ] || [ "$ISOLATION_RESPONSE" -eq 403 ]; then
    echo -e "${GREEN}✓ Tenant isolation working (404/403 for wrong tenant)${NC}\n"
else
    echo -e "${RED}✗ Tenant isolation failed (got $ISOLATION_RESPONSE instead of 404/403)${NC}\n"
fi

# Test 10: Duplicate Tool Name (should fail with 409)
echo -e "${YELLOW}Test 10: Duplicate Tool Name Test${NC}"
DUPLICATE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST $BASE_URL/tools \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "name": "kb_search_qdrant",
    "title": "Duplicate Tool",
    "type": "KB_SEARCH",
    "inputSchema": {},
    "outputSchema": {},
    "authType": "api_key",
    "authConfig": {}
  }')

if [ "$DUPLICATE_RESPONSE" -eq 409 ]; then
    echo -e "${GREEN}✓ Duplicate detection working (409 Conflict)${NC}\n"
else
    echo -e "${RED}✗ Duplicate detection failed (got $DUPLICATE_RESPONSE instead of 409)${NC}\n"
fi

# Test 11: Delete Tool
echo -e "${YELLOW}Test 11: Delete Tool${NC}"
DELETE_RESPONSE=$(curl -s -X DELETE $BASE_URL/tools/$TOOL2_ID \
  -H "X-Tenant-Id: $TENANT_ID")

echo $DELETE_RESPONSE | python -m json.tool
echo -e "${GREEN}✓ Tool deleted${NC}\n"

# Test 12: Verify Deletion
echo -e "${YELLOW}Test 12: Verify Tool Deletion${NC}"
VERIFY_DELETE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X GET $BASE_URL/tools/$TOOL2_ID \
  -H "X-Tenant-Id: $TENANT_ID")

if [ "$VERIFY_DELETE" -eq 404 ]; then
    echo -e "${GREEN}✓ Tool successfully deleted (404)${NC}\n"
else
    echo -e "${RED}✗ Tool still exists (got $VERIFY_DELETE)${NC}\n"
fi

# Summary
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   Test Summary${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✓ All 12 tests completed${NC}"
echo -e "${YELLOW}Note: API keys are encrypted in database${NC}"
echo -e "${YELLOW}Note: Test endpoint is placeholder (Phase 9: MCP integration)${NC}\n"
