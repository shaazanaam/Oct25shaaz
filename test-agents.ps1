# Test Agent Endpoints
Write-Host "`n=== Testing Agent Endpoints ===" -ForegroundColor Cyan

# Test 1: Create Tenant
Write-Host "`n[1] Creating Tenant..." -ForegroundColor Yellow
$tenantResponse = Invoke-RestMethod -Uri "http://localhost:3000/tenants" -Method Post -ContentType "application/json" -Body '{"name":"Test Company","plan":"PRO"}'
$tenantId = $tenantResponse.id
Write-Host "Tenant created: $tenantId" -ForegroundColor Green
$tenantResponse | ConvertTo-Json

# Test 2: Create Agent
Write-Host "`n[2] Creating Agent..." -ForegroundColor Yellow
$agentBody = @{
    name = "IT Support Bot"
    version = "1.0.0"
    flowJson = @{
        nodes = @(
            @{ id = "kb_search"; type = "tool" }
            @{ id = "get_feedback"; type = "user_input" }
            @{ id = "create_ticket"; type = "tool" }
        )
        edges = @(
            @{ from = "kb_search"; to = "get_feedback" }
            @{ from = "get_feedback"; to = "create_ticket" }
        )
    }
    tenantId = $tenantId
} | ConvertTo-Json -Depth 10

$agentResponse = Invoke-RestMethod -Uri "http://localhost:3000/agents" -Method Post -ContentType "application/json" -Body $agentBody
$agentId = $agentResponse.id
Write-Host "Agent created: $agentId" -ForegroundColor Green
$agentResponse | ConvertTo-Json

# Test 3: List Agents
Write-Host "`n[3] Listing All Agents..." -ForegroundColor Yellow
$headers = @{ "X-Tenant-Id" = $tenantId }
$agents = Invoke-RestMethod -Uri "http://localhost:3000/agents" -Method Get -Headers $headers
Write-Host "Found $($agents.Count) agent(s)" -ForegroundColor Green
$agents | ConvertTo-Json

# Test 4: Get Single Agent
Write-Host "`n[4] Getting Single Agent..." -ForegroundColor Yellow
$agent = Invoke-RestMethod -Uri "http://localhost:3000/agents/$agentId" -Method Get -Headers $headers
Write-Host "Agent name: $($agent.name), Status: $($agent.status)" -ForegroundColor Green

# Test 5: Update Agent Status
Write-Host "`n[5] Updating Agent Status to PUBLISHED..." -ForegroundColor Yellow
$statusBody = '{"status":"PUBLISHED"}' 
$updatedAgent = Invoke-RestMethod -Uri "http://localhost:3000/agents/$agentId/status" -Method Patch -ContentType "application/json" -Body $statusBody -Headers $headers
Write-Host "Status updated to: $($updatedAgent.status)" -ForegroundColor Green

# Test 6: Update Agent
Write-Host "`n[6] Updating Agent Name and Version..." -ForegroundColor Yellow
$updateBody = '{"name":"IT Support Bot v2","version":"1.1.0"}'
$updatedAgent = Invoke-RestMethod -Uri "http://localhost:3000/agents/$agentId" -Method Patch -ContentType "application/json" -Body $updateBody -Headers $headers
Write-Host "Agent updated: $($updatedAgent.name) v$($updatedAgent.version)" -ForegroundColor Green

# Test 7: Test Tenant Isolation
Write-Host "`n[7] Testing Tenant Isolation..." -ForegroundColor Yellow
$tenant2Response = Invoke-RestMethod -Uri "http://localhost:3000/tenants" -Method Post -ContentType "application/json" -Body '{"name":"Another Company","plan":"FREE"}'
$tenant2Id = $tenant2Response.id
$headers2 = @{ "X-Tenant-Id" = $tenant2Id }
try {
    $isolationTest = Invoke-RestMethod -Uri "http://localhost:3000/agents/$agentId" -Method Get -Headers $headers2
    Write-Host "FAILED: Tenant isolation broken!" -ForegroundColor Red
} catch {
    Write-Host "SUCCESS: Tenant isolation working (404 as expected)" -ForegroundColor Green
}

# Test 8: Delete Agent
Write-Host "`n[8] Deleting Agent..." -ForegroundColor Yellow
$deleteResponse = Invoke-RestMethod -Uri "http://localhost:3000/agents/$agentId" -Method Delete -Headers $headers
Write-Host $deleteResponse.message -ForegroundColor Green

Write-Host "`n=== All Tests Complete! ===" -ForegroundColor Cyan
