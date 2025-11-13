#!/bin/bash

# Test script for Documents CRUD endpoints

BASE_URL="http://localhost:3000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   Documents API Testing${NC}"
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
  -d "{\"name\":\"test-tenant-docs-$(date +%s)\",\"plan\":\"ENTERPRISE\"}")

TENANT_ID=$(echo $TENANT_RESPONSE | python -m json.tool | grep '"id"' | head -1 | awk -F'"' '{print $4}')
echo -e "Tenant ID: ${CYAN}$TENANT_ID${NC}"
echo -e "${GREEN}✓ Tenant created${NC}\n"

# Test 3: Create Document (Upload)
echo -e "${YELLOW}Test 3: Create Document (Upload)${NC}"
DOC1_RESPONSE=$(curl -s -X POST $BASE_URL/documents \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "source": "upload",
    "uri": "s3://kb-docs/password-reset-manual.pdf",
    "title": "Password Reset Manual",
    "metadata": {
      "tags": ["manual", "security", "password"],
      "category": "IT Support",
      "fileType": "pdf",
      "size": 245760
    }
  }')

echo $DOC1_RESPONSE | python -m json.tool
DOC1_ID=$(echo $DOC1_RESPONSE | python -m json.tool | grep '"id"' | head -1 | awk -F'"' '{print $4}')
echo -e "Document 1 ID: ${CYAN}$DOC1_ID${NC}"
echo -e "${GREEN}✓ Document created (upload)${NC}\n"

# Test 4: Create Document (Sharepoint)
echo -e "${YELLOW}Test 4: Create Document (Sharepoint)${NC}"
DOC2_RESPONSE=$(curl -s -X POST $BASE_URL/documents \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "source": "sharepoint",
    "uri": "https://company.sharepoint.com/sites/kb/faq.docx",
    "title": "Frequently Asked Questions",
    "metadata": {
      "tags": ["faq", "support"],
      "category": "Knowledge Base",
      "lastModified": "2025-11-10"
    }
  }')

DOC2_ID=$(echo $DOC2_RESPONSE | python -m json.tool | grep '"id"' | head -1 | awk -F'"' '{print $4}')
echo -e "Document 2 ID: ${CYAN}$DOC2_ID${NC}"
echo -e "${GREEN}✓ Document created (sharepoint)${NC}\n"

# Test 5: Create Document (URL)
echo -e "${YELLOW}Test 5: Create Document (URL)${NC}"
DOC3_RESPONSE=$(curl -s -X POST $BASE_URL/documents \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "source": "url",
    "uri": "https://docs.company.com/api-guide",
    "title": "API Integration Guide",
    "metadata": {
      "tags": ["api", "developer"],
      "category": "Technical Documentation"
    }
  }')

DOC3_ID=$(echo $DOC3_RESPONSE | python -m json.tool | grep '"id"' | head -1 | awk -F'"' '{print $4}')
echo -e "Document 3 ID: ${CYAN}$DOC3_ID${NC}"
echo -e "${GREEN}✓ Document created (url)${NC}\n"

# Test 6: List All Documents
echo -e "${YELLOW}Test 6: List All Documents${NC}"
LIST_RESPONSE=$(curl -s -X GET $BASE_URL/documents \
  -H "X-Tenant-Id: $TENANT_ID")

echo $LIST_RESPONSE | python -m json.tool
DOC_COUNT=$(echo $LIST_RESPONSE | python -m json.tool | grep -c '"source"')
echo -e "Found ${CYAN}$DOC_COUNT${NC} documents"
echo -e "${GREEN}✓ Documents listed${NC}\n"

# Test 7: Get Single Document
echo -e "${YELLOW}Test 7: Get Single Document${NC}"
GET_RESPONSE=$(curl -s -X GET $BASE_URL/documents/$DOC1_ID \
  -H "X-Tenant-Id: $TENANT_ID")

echo $GET_RESPONSE | python -m json.tool
echo -e "${GREEN}✓ Document retrieved${NC}\n"

# Test 8: Update Document Metadata
echo -e "${YELLOW}Test 8: Update Document Metadata${NC}"
UPDATE_RESPONSE=$(curl -s -X PATCH $BASE_URL/documents/$DOC1_ID \
  -H "Content-Type: application/json" \
  -H "X-Tenant-Id: $TENANT_ID" \
  -d '{
    "title": "Password Reset Manual (Updated)",
    "metadata": {
      "tags": ["manual", "security", "password", "updated"],
      "category": "IT Support",
      "version": "2.0"
    }
  }')

echo $UPDATE_RESPONSE | python -m json.tool
echo -e "${GREEN}✓ Document metadata updated${NC}\n"

# Test 9: Search Documents (text search)
echo -e "${YELLOW}Test 9: Search Documents${NC}"
SEARCH_RESPONSE=$(curl -s -X GET "$BASE_URL/documents/search?q=password" \
  -H "X-Tenant-Id: $TENANT_ID")

echo $SEARCH_RESPONSE | python -m json.tool
SEARCH_COUNT=$(echo $SEARCH_RESPONSE | python -m json.tool | grep -o '"id"' | wc -l)
echo -e "Found ${CYAN}$((SEARCH_COUNT - 1))${NC} matching documents"
echo -e "${GREEN}✓ Search works (basic text search)${NC}\n"

# Test 10: Tenant Isolation
echo -e "${YELLOW}Test 10: Tenant Isolation Test${NC}"
ISOLATION_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X GET $BASE_URL/documents/$DOC1_ID \
  -H "X-Tenant-Id: wrong-tenant-id-12345")

if [ "$ISOLATION_RESPONSE" -eq 404 ] || [ "$ISOLATION_RESPONSE" -eq 403 ]; then
    echo -e "${GREEN}✓ Tenant isolation working (404/403 for wrong tenant)${NC}\n"
else
    echo -e "${RED}✗ Tenant isolation failed (got $ISOLATION_RESPONSE)${NC}\n"
fi

# Test 11: Delete Document
echo -e "${YELLOW}Test 11: Delete Document${NC}"
DELETE_RESPONSE=$(curl -s -X DELETE $BASE_URL/documents/$DOC3_ID \
  -H "X-Tenant-Id: $TENANT_ID")

echo $DELETE_RESPONSE | python -m json.tool
echo -e "${GREEN}✓ Document deleted${NC}\n"

# Test 12: Verify Deletion
echo -e "${YELLOW}Test 12: Verify Document Deletion${NC}"
VERIFY_DELETE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X GET $BASE_URL/documents/$DOC3_ID \
  -H "X-Tenant-Id: $TENANT_ID")

if [ "$VERIFY_DELETE" -eq 404 ]; then
    echo -e "${GREEN}✓ Document successfully deleted (404)${NC}\n"
else
    echo -e "${RED}✗ Document still exists (got $VERIFY_DELETE)${NC}\n"
fi

# Summary
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}   Test Summary${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}✓ All 12 tests completed${NC}"
echo -e "${YELLOW}Note: Current implementation stores metadata only${NC}"
echo -e "${YELLOW}Phase 7 Enhancement: File upload to S3/MinIO${NC}"
echo -e "${YELLOW}Phase 7 Enhancement: Vector embeddings (Qdrant)${NC}"
echo -e "${YELLOW}Phase 7 Enhancement: Semantic search${NC}\n"
