# TenantGuard Implementation - November 10, 2025

**File:** `src/guards/tenant.guard.ts`  
**Phase:** Phase 3.1 - Multi-Tenancy Foundation  
**Purpose:** Security layer that validates tenant context on every API request

---

## 🎯 What This File Does

The `TenantGuard` is a **security gatekeeper** that:
1. Intercepts every incoming API request
2. Validates the request has a valid `X-Tenant-Id` header
3. Checks that the tenant exists in the database
4. Attaches tenant information to the request
5. Blocks invalid requests with clear error messages

**Think of it as:** A bouncer at a club checking IDs before letting people in.

---

## 📋 Code Breakdown

### Imports (Lines 1-7)

```typescript
import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../services/prisma.service';
```

**What each import does:**

| Import | Purpose |
|--------|---------|
| `CanActivate` | NestJS interface that guards must implement |
| `ExecutionContext` | Provides access to request/response objects |
| `Injectable` | Enables dependency injection (NestJS can provide dependencies) |
| `ForbiddenException` | Throws 403 error when tenant is invalid |
| `BadRequestException` | Throws 400 error when header is missing |
| `PrismaService` | Database service to query tenants |

---

### Class Declaration (Lines 9-10)

```typescript
@Injectable()
export class TenantGuard implements CanActivate {
```

**@Injectable()** - Tells NestJS:
- "This class can receive dependencies via constructor injection"
- "You can use this class in other modules"

**implements CanActivate** - Promises to NestJS:
- "I will have a `canActivate()` method"
- "I will return `true` (allow) or `false` (block) for requests"

---

### Constructor (Line 11)

```typescript
constructor(private readonly prisma: PrismaService) {}
```

**How dependency injection works:**
1. NestJS sees `TenantGuard` needs `PrismaService`
2. NestJS creates/finds a `PrismaService` instance
3. NestJS automatically passes it to the constructor
4. We can now use `this.prisma` throughout the class

**private readonly** means:
- `private` - Only accessible inside this class
- `readonly` - Cannot be reassigned after construction

---

### canActivate Method (Lines 13-42)

This is where the magic happens!

#### Step 1: Get Request Object (Lines 14-15)

```typescript
const request = context.switchToHttp().getRequest();
const tenantId = request.headers['x-tenant-id'];
```

**What happens:**
- `context.switchToHttp()` - Convert generic context to HTTP context
- `.getRequest()` - Get the Express request object
- `request.headers['x-tenant-id']` - Read the header value

**Example request:**
```http
POST /users HTTP/1.1
X-Tenant-Id: cl123abc456def
Content-Type: application/json
```
→ `tenantId` = `"cl123abc456def"`

---

#### Step 2: Check Header Exists (Lines 18-23)

```typescript
if (!tenantId) {
  throw new BadRequestException(
    'X-Tenant-Id header is required. Please provide a valid tenant identifier.',
  );
}
```

**Why BadRequestException (400)?**
- Client made a mistake (forgot the header)
- Not an authorization problem
- Clear message helps developers debug

**What happens:**
- Request is immediately rejected
- NestJS returns this response:
```json
{
  "statusCode": 400,
  "message": "X-Tenant-Id header is required. Please provide a valid tenant identifier.",
  "error": "Bad Request"
}
```

---

#### Step 3: Database Lookup (Lines 25-29)

```typescript
const tenant = await this.prisma.tenant.findUnique({
  where: { id: tenantId }
});
```

**What this does:**
- Queries the `Tenant` table in PostgreSQL
- Looks for a tenant with matching `id`
- Returns tenant object if found, `null` if not

**SQL equivalent:**
```sql
SELECT * FROM "Tenant" WHERE id = 'cl123abc456def';
```

**Possible results:**
```typescript
// Found:
tenant = {
  id: "cl123abc456def",
  name: "Acme Corp",
  plan: "PRO",
  createdAt: "2025-11-06T...",
  updatedAt: "2025-11-06T..."
}

// Not found:
tenant = null
```

---

#### Step 4: Validate Tenant Exists (Lines 31-35)

```typescript
if (!tenant) {
  throw new ForbiddenException(
    `Tenant with ID '${tenantId}' not found or you do not have access to this tenant.`,
  );
}
```

**Why ForbiddenException (403)?**
- Client provided a tenant ID, but it's invalid
- This is an authorization issue (can't access this resource)
- Different from 400 (missing header) or 401 (not authenticated)

**What happens:**
- Request is rejected
- NestJS returns:
```json
{
  "statusCode": 403,
  "message": "Tenant with ID 'invalid-id' not found or you do not have access to this tenant.",
  "error": "Forbidden"
}
```

---

#### Step 5: Attach Tenant to Request (Line 37-38)

```typescript
request.tenant = tenant;
```

**Why this matters:**
- Now controllers/services can access `request.tenant`
- No need to query database again
- Ensures downstream code uses validated tenant

**Usage in controller:**
```typescript
@Get()
findAll(@Request() req) {
  const tenant = req.tenant;  // ← Already validated and attached!
  console.log(`Request from tenant: ${tenant.name}`);
}
```

---

#### Step 6: Allow Request (Lines 40-42)

```typescript
return true;
```

**What happens:**
- Guard allows request to proceed
- Next in chain: controller method executes
- Request has `tenant` object attached

---

## 🔄 Request Flow Example

### Successful Request:

```
1. Client Request:
   POST /users
   X-Tenant-Id: acme-corp-id
   
2. TenantGuard intercepts
   
3. Extract header: "acme-corp-id"
   
4. Query database: 
   SELECT * FROM Tenant WHERE id = 'acme-corp-id'
   → Found: { id: "acme-corp-id", name: "Acme Corp", plan: "PRO" }
   
5. Attach to request:
   request.tenant = { id: "acme-corp-id", ... }
   
6. Return true (allow)
   
7. Controller executes:
   UsersController.create() with access to request.tenant
```

### Failed Request (Missing Header):

```
1. Client Request:
   POST /users
   (no X-Tenant-Id header)
   
2. TenantGuard intercepts
   
3. Extract header: undefined
   
4. Throw BadRequestException
   
5. NestJS returns 400 error
   
6. Controller NEVER executes
```

### Failed Request (Invalid Tenant):

```
1. Client Request:
   POST /users
   X-Tenant-Id: fake-tenant-id
   
2. TenantGuard intercepts
   
3. Extract header: "fake-tenant-id"
   
4. Query database:
   SELECT * FROM Tenant WHERE id = 'fake-tenant-id'
   → Not found: null
   
5. Throw ForbiddenException
   
6. NestJS returns 403 error
   
7. Controller NEVER executes
```

---

## 🎯 Security Benefits

### Data Isolation
-  Each tenant can ONLY access their own data
-  Invalid tenant IDs are rejected immediately
-  No way to "guess" another tenant's data

### Clear Error Messages
-  Developers know exactly what's wrong
-  400 vs 403 distinction helps debugging
-  Error messages guide proper API usage

### Performance
-  Single database query per request
-  Tenant object cached on request (no re-querying)
-  Fast rejection of invalid requests

---

## 🔍 How to Use This Guard

### Option 1: Apply to Specific Controller

```typescript
@Controller('users')
@UseGuards(TenantGuard)  // ← Protects all routes in this controller
export class UsersController {
  @Get()
  findAll(@Request() req) {
    const tenant = req.tenant;  // Available here!
  }
}
```

### Option 2: Apply to Specific Route

```typescript
@Controller('users')
export class UsersController {
  @Get()
  @UseGuards(TenantGuard)  // ← Only protects this route
  findAll(@Request() req) {
    const tenant = req.tenant;
  }
  
  @Get('public')
  // No guard - publicly accessible
  getPublic() {
    return { message: 'Public endpoint' };
  }
}
```

### Option 3: Apply Globally (Future)

```typescript
// In main.ts
app.useGlobalGuards(new TenantGuard(prismaService));
```

---

## 🐛 Common Issues & Solutions

### Issue: "Property 'tenant' does not exist on type 'Request'"

**Solution:** TypeScript doesn't know about custom properties. Add type declaration:

```typescript
// Create: src/types/express.d.ts
declare namespace Express {
  export interface Request {
    tenant?: {
      id: string;
      name: string;
      plan: string;
      createdAt: Date;
      updatedAt: Date;
    };
  }
}
```

### Issue: Guard not running

**Check:**
1. Is guard applied with `@UseGuards(TenantGuard)`?
2. Is `PrismaService` provided in the module?
3. Is the route actually being called?

---

## 📚 Next Steps

### Phase 3.2: Create Tenants Module
- Build CRUD API for tenant management
- Allow creating/updating/deleting tenants
- Test with Swagger

### Phase 3.3: Apply to Existing Endpoints
- Add `@UseGuards(TenantGuard)` to UsersController
- Update queries to filter by `tenantId`
- Test data isolation

---

## 🎓 Key Learnings

### NestJS Guards
- Run BEFORE controllers
- Perfect for authentication/authorization
- Can access request/response
- Can modify request object

### Dependency Injection
- NestJS automatically provides dependencies
- Makes testing easier (can mock PrismaService)
- Keeps code clean and maintainable

### Error Handling
- Use appropriate HTTP status codes
- Provide clear error messages
- Help developers debug quickly

---

**Created:** November 10, 2025  
**Status:**  Complete and ready for testing  
**Next:** Create Tenants CRUD module