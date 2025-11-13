# Agent Endpoints Testing

This directory contains automated tests for the Agent Management API.

## Files

- `test-agents.sh` - Comprehensive bash script to test all Agent endpoints

## Prerequisites

1. **Server must be running**: Start the NestJS server in a separate terminal
   ```bash
   npm run start:dev
   ```

2. **Docker containers must be running**: PostgreSQL and Redis
   ```bash
   docker compose up -d
   ```

## Running the Tests

### From a separate Git Bash terminal (outside VS Code):

```bash
# Navigate to project root
cd /c/Users/600790/Oct25shaaz

# Make script executable
chmod +x test/test-agents.sh

# Run the tests
./test/test-agents.sh
```

### What the script tests:

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

## Expected Output

The script will output color-coded results:
- 🟢 Green = Success
- 🔴 Red = Failure
- 🟡 Yellow = Info/Progress
- 🔵 Cyan = Section headers

## Troubleshooting

**Error: "Server is not running"**
- Make sure `npm run start:dev` is running in another terminal
- Check that server is on http://localhost:3000

**Error: "curl: command not found"**
- Install Git Bash which includes curl
- Or install curl separately for Windows

**Error: "python -m json.tool" fails**
- The script will still work, just won't pretty-print JSON
- Install Python if you want formatted output
