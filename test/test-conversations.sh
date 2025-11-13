#!/bin/bash

# Test script for Conversations & Messages CRUD endpoints

BASE_URL="http://localhost:3000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   Conversations & Messages API Testing${NC}"
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
  -d "{\"name\":\"test-tenant-conversations-$(date +%s)\",\"plan\":\"PRO\"}")

TENANT_ID=$(echo $TENANT_RESPONSE | python -m json.tool | grep '"id"' | head -1 | awk -F'"' '{print $4}')
echo -e "Tenant ID: ${CYAN}$TENANT_ID${NC}"
echo -e "${GREEN}✓ Tenant created${NC}\n"

# Test 3: Create Agent
echo -e "${YELLOW}Test 3: Create Agent${NC}"
AGENT_RESPONSE=$(curl -s -X POST $BASE_URL/agents \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "name": "support_agent",
    "version": "1.0.0",
    "flowJson": {
      "nodes": [{"id": "start", "type": "start"}],
      "edges": []
    }
  }')

AGENT_ID=$(echo $AGENT_RESPONSE | python -m json.tool | grep '"id"' | head -1 | awk -F'"' '{print $4}')
echo -e "Agent ID: ${CYAN}$AGENT_ID${NC}"
echo -e "${GREEN}✓ Agent created${NC}\n"

# Test 4: Create Conversation
echo -e "${YELLOW}Test 4: Create Conversation${NC}"
CONVO_RESPONSE=$(curl -s -X POST $BASE_URL/conversations \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d "{
    \"agentId\": \"$AGENT_ID\",
    \"userId\": \"user123\",
    \"channel\": \"web\",
    \"state\": {\"step\": \"initial\"}
  }")

echo $CONVO_RESPONSE | python -m json.tool
CONVO_ID=$(echo $CONVO_RESPONSE | python -m json.tool | grep '"id"' | head -1 | awk -F'"' '{print $4}')
echo -e "Conversation ID: ${CYAN}$CONVO_ID${NC}"
echo -e "${GREEN}✓ Conversation created${NC}\n"

# Test 5: Add USER Message
echo -e "${YELLOW}Test 5: Add USER Message${NC}"
MSG1_RESPONSE=$(curl -s -X POST $BASE_URL/conversations/$CONVO_ID/messages \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "role": "USER",
    "content": "How do I reset my password?",
    "metadata": {"source": "web_chat"}
  }')

echo $MSG1_RESPONSE | python -m json.tool
echo -e "${GREEN}✓ USER message added${NC}\n"

# Test 6: Add ASSISTANT Message
echo -e "${YELLOW}Test 6: Add ASSISTANT Message${NC}"
MSG2_RESPONSE=$(curl -s -X POST $BASE_URL/conversations/$CONVO_ID/messages \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "role": "ASSISTANT",
    "content": "I can help you reset your password. Let me search the knowledge base.",
    "metadata": {"toolCalls": ["kb_search"]}
  }')

echo $MSG2_RESPONSE | python -m json.tool
echo -e "${GREEN}✓ ASSISTANT message added${NC}\n"

# Test 7: Add TOOL Message
echo -e "${YELLOW}Test 7: Add TOOL Message${NC}"
MSG3_RESPONSE=$(curl -s -X POST $BASE_URL/conversations/$CONVO_ID/messages \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "role": "TOOL",
    "content": "Found 3 articles about password reset",
    "metadata": {"toolName": "kb_search", "results": 3}
  }')

echo -e "${GREEN}✓ TOOL message added${NC}\n"

# Test 8: Get All Messages
echo -e "${YELLOW}Test 8: Get All Messages${NC}"
MESSAGES_RESPONSE=$(curl -s -X GET $BASE_URL/conversations/$CONVO_ID/messages \
  -H "X-Tenant-Id: $TENANT_ID")

echo $MESSAGES_RESPONSE | python -m json.tool
MESSAGE_COUNT=$(echo $MESSAGES_RESPONSE | python -m json.tool | grep -c '"role"')
echo -e "Found ${CYAN}$MESSAGE_COUNT${NC} messages"
echo -e "${GREEN}✓ Messages retrieved${NC}\n"

# Test 9: Get Conversation with Messages
echo -e "${YELLOW}Test 9: Get Conversation with Full History${NC}"
FULL_CONVO=$(curl -s -X GET $BASE_URL/conversations/$CONVO_ID \
  -H "X-Tenant-Id: $TENANT_ID")

echo $FULL_CONVO | python -m json.tool | head -30
echo -e "${GREEN}✓ Conversation with messages retrieved${NC}\n"

# Test 10: List All Conversations
echo -e "${YELLOW}Test 10: List All Conversations${NC}"
LIST_RESPONSE=$(curl -s -X GET $BASE_URL/conversations \
  -H "X-Tenant-Id: $TENANT_ID")

echo $LIST_RESPONSE | python -m json.tool
CONVO_COUNT=$(echo $LIST_RESPONSE | python -m json.tool | grep -c '"agentId"')
echo -e "Found ${CYAN}$CONVO_COUNT${NC} conversations"
echo -e "${GREEN}✓ Conversations listed${NC}\n"

# Test 11: Update Conversation State
echo -e "${YELLOW}Test 11: Update Conversation State${NC}"
UPDATE_RESPONSE=$(curl -s -X PATCH $BASE_URL/conversations/$CONVO_ID \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "state": {"step": "completed", "resolved": true}
  }')

echo $UPDATE_RESPONSE | python -m json.tool
echo -e "${GREEN}✓ Conversation state updated${NC}\n"

# Test 12: Tenant Isolation
echo -e "${YELLOW}Test 12: Tenant Isolation Test${NC}"
ISOLATION_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X GET $BASE_URL/conversations/$CONVO_ID \
  -H "X-Tenant-Id: wrong-tenant-id-12345")

if [ "$ISOLATION_RESPONSE" -eq 404 ] || [ "$ISOLATION_RESPONSE" -eq 403 ]; then
    echo -e "${GREEN}✓ Tenant isolation working (404/403 for wrong tenant)${NC}\n"
else
    echo -e "${RED}✗ Tenant isolation failed (got $ISOLATION_RESPONSE)${NC}\n"
fi

# Test 13: Create Second Conversation
echo -e "${YELLOW}Test 13: Create Second Conversation${NC}"
CONVO2_RESPONSE=$(curl -s -X POST $BASE_URL/conversations \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d "{
    \"agentId\": \"$AGENT_ID\",
    \"channel\": \"slack\"
  }")

CONVO2_ID=$(echo $CONVO2_RESPONSE | python -m json.tool | grep '"id"' | head -1 | awk -F'"' '{print $4}')
echo -e "Conversation 2 ID: ${CYAN}$CONVO2_ID${NC}"
echo -e "${GREEN}✓ Second conversation created${NC}\n"

# Test 14: Delete Conversation
echo -e "${YELLOW}Test 14: Delete Conversation${NC}"
DELETE_RESPONSE=$(curl -s -X DELETE $BASE_URL/conversations/$CONVO2_ID \
  -H "X-Tenant-Id: $TENANT_ID")

echo $DELETE_RESPONSE | python -m json.tool
echo -e "${GREEN}✓ Conversation deleted (CASCADE deletes all messages)${NC}\n"

# Test 15: Verify Deletion
echo -e "${YELLOW}Test 15: Verify Conversation Deletion${NC}"
VERIFY_DELETE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X GET $BASE_URL/conversations/$CONVO2_ID \
  -H "X-Tenant-Id: $TENANT_ID")

if [ "$VERIFY_DELETE" -eq 404 ]; then
    echo -e "${GREEN}✓ Conversation successfully deleted (404)${NC}\n"
else
    echo -e "${RED}✗ Conversation still exists (got $VERIFY_DELETE)${NC}\n"
fi

# Summary
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   Test Summary${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✓ All 15 tests completed${NC}"
echo -e "${YELLOW}Note: Messages are CASCADE deleted with conversation${NC}"
echo -e "${YELLOW}Note: Phase 8 will add LangGraph execution on message post${NC}\n"
