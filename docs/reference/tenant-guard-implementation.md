# TenantGuard Implementation Reference

**File:** `src/guards/tenant.guard.ts`  
**Phase:** Phase 3.1 - Multi-Tenancy Foundation  
**Created:** November 10, 2025

## Overview

The `TenantGuard` is a NestJS security guard that validates tenant context on every API request. It ensures multi-tenant data isolation by:

1. Extracting `X-Tenant-Id` from request headers
2. Validating the tenant exists in the database
3. Attaching tenant object to the request for downstream use
4. Rejecting invalid requests with appropriate HTTP error codes

## Implementation

```typescript
import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
  BadRequestException,
} from "@nestjs/common";
import { PrismaService } from "../services/prisma.service";

@Injectable()
export class TenantGuard implements CanActivate {
  constructor(private readonly prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const tenantId = request.headers["x-tenant-id"];

    // Validate header exists
    if (!tenantId) {
      throw new BadRequestException(
        "X-Tenant-Id header is required. Please provide a valid tenant identifier."
      );
    }

    // Lookup tenant in database
    const tenant = await this.prisma.tenant.findUnique({
      where: { id: tenantId },
    });

    // Validate tenant exists
    if (!tenant) {
      throw new ForbiddenException(
        `Tenant with ID '${tenantId}' not found or you do not have access to this tenant.`
      );
    }

    // Attach tenant to request
    request.tenant = tenant;

    return true;
  }
}
```

## Request Flow

### Successful Request

```
Client Request → Extract X-Tenant-Id → Query Database → Tenant Found
→ Attach to Request → Return true → Controller Executes
```

### Failed Request (Missing Header)

```
Client Request → No X-Tenant-Id → Throw BadRequestException (400)
→ Controller Never Executes
```

### Failed Request (Invalid Tenant)

```
Client Request → Extract X-Tenant-Id → Query Database → Not Found
→ Throw ForbiddenException (403) → Controller Never Executes
```

## Usage

### Apply to Controller

```typescript
@Controller("users")
@UseGuards(TenantGuard) // Protects all routes
export class UsersController {
  @Get()
  findAll(@Request() req) {
    const tenant = req.tenant; // Validated tenant object available
    return this.usersService.findAll(tenant.id);
  }
}
```

### Apply to Specific Route

```typescript
@Controller("users")
export class UsersController {
  @Get()
  @UseGuards(TenantGuard) // Only this route
  protected(@Request() req) {
    return { tenant: req.tenant.name };
  }

  @Get("public")
  public() {
    return { message: "No guard - publicly accessible" };
  }
}
```

## Error Responses

### 400 Bad Request (Missing Header)

```json
{
  "statusCode": 400,
  "message": "X-Tenant-Id header is required. Please provide a valid tenant identifier.",
  "error": "Bad Request"
}
```

### 403 Forbidden (Invalid Tenant)

```json
{
  "statusCode": 403,
  "message": "Tenant with ID 'invalid-id' not found or you do not have access to this tenant.",
  "error": "Forbidden"
}
```

## TypeScript Type Declaration

Add to `src/types/express.d.ts`:

```typescript
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

## Security Benefits

- **Data Isolation:** Each tenant can only access their own data
- **Early Rejection:** Invalid requests blocked before reaching business logic
- **Clear Errors:** Distinct HTTP codes (400 vs 403) for different failure modes
- **Performance:** Single database query, result cached on request object

## Related Documentation

- Multi-tenancy architecture: See `docs/guides/ROADMAP.md` Phase 3
- Tenant CRUD API: See `src/tenants/` module
- Database schema: See `prisma/schema.prisma`
