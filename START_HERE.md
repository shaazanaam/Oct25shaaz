# 🚀 Start Here - Next Session Guide

**Last Updated:** November 5, 2025  
**Current Status:** Phase 2 Complete ✅  
**Next Step:** Phase 3 - Multi-Tenancy Foundation

---

## ✅ What You've Completed

### Phase 1: Foundation
- ✅ NestJS 11.1.7 installed and configured
- ✅ Docker Compose with PostgreSQL + Redis
- ✅ TypeScript configuration
- ✅ Basic project structure

### Phase 2: Core Data Models
- ✅ Complete Prisma schema with 7 models
- ✅ Database migration: `20251106022522_ai_platform_schema`
- ✅ All tables created in PostgreSQL
- ✅ Prisma Client generated

**Commit:** `11c5d3a` - "feat: implement multi-tenant AI platform schema"

---

## 🎯 Next Session: Phase 3 - Multi-Tenancy Foundation

### What You'll Build

**Goal:** Protect all API endpoints with tenant isolation using middleware

### Step-by-Step Plan

#### 1. Start Docker (First Thing!)
```bash
# Make sure Docker Desktop is running, then:
docker ps

# You should see:
# - oct25shaaz-postgres-1 (port 5432)
# - oct25shaaz-redis-1 (port 6379)

# If not running:
docker-compose up -d
```

#### 2. Verify Database Connection
```bash
npm run db:studio
# Opens Prisma Studio at http://localhost:5555
# You should see all 7 tables (Tenant, User, Agent, etc.)
```

#### 3. Create Tenant Guard Middleware

**File to create:** `src/guards/tenant.guard.ts`

**Purpose:** Extract `X-Tenant-Id` header and validate tenant exists

**What it does:**
- Reads `X-Tenant-Id` from request headers
- Queries database to verify tenant exists
- Attaches tenant info to request object
- Rejects requests with invalid/missing tenant ID

**Code skeleton:**
```typescript
import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { PrismaService } from '../services/prisma.service';

@Injectable()
export class TenantGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const tenantId = request.headers['x-tenant-id'];
    
    // TODO: Validate tenant exists
    // TODO: Attach tenant to request
    
    return true;
  }
}
```

#### 4. Create Tenants Module

**Generate module:**
```bash
# NestJS CLI (if installed):
nest generate module tenants
nest generate controller tenants
nest generate service tenants

# OR create manually:
# - src/tenants/tenants.module.ts
# - src/tenants/tenants.controller.ts
# - src/tenants/tenants.service.ts
# - src/tenants/dto/create-tenant.dto.ts
```

**API Endpoints to Build:**
- `POST /tenants` - Create new tenant
- `GET /tenants/:id` - Get tenant by ID
- `PATCH /tenants/:id` - Update tenant (name, plan)
- `DELETE /tenants/:id` - Delete tenant (cascade deletes all data!)

#### 5. Add DTOs for Validation

**File:** `src/tenants/dto/create-tenant.dto.ts`
```typescript
import { IsString, IsEnum, IsOptional } from 'class-validator';

export class CreateTenantDto {
  @IsString()
  name: string;

  @IsEnum(['FREE', 'PRO', 'ENTERPRISE'])
  @IsOptional()
  plan?: string;
}
```

#### 6. Test Your Work

**Create a test tenant:**
```bash
curl -X POST http://localhost:3000/tenants \
  -H "Content-Type: application/json" \
  -d '{"name": "acme-corp", "plan": "PRO"}'
```

**Expected response:**
```json
{
  "id": "clxxxx...",
  "name": "acme-corp",
  "plan": "PRO",
  "createdAt": "2025-11-06T...",
  "updatedAt": "2025-11-06T..."
}
```

---

## 📂 Current Project Structure

```
Oct25shaaz/
├── src/
│   ├── main.ts              ← NestJS entry point
│   ├── app.module.ts        ← Root module
│   ├── controllers/
│   │   ├── app.controller.ts
│   │   └── users.controller.ts
│   ├── services/
│   │   ├── prisma.service.ts  ← Already exists!
│   │   └── users.service.ts
│   ├── dto/
│   │   └── create-user.dto.ts
│   └── guards/              ← CREATE THIS
│       └── tenant.guard.ts
├── prisma/
│   ├── schema.prisma        ← Your 7 models
│   └── migrations/
│       └── 20251106022522_ai_platform_schema/
├── .env                     ← DATABASE_URL, REDIS_URL
├── docker-compose.yml
└── package.json
```

---

## 🔑 Environment Variables

**File:** `.env`
```env
DATABASE_URL="postgresql://ai:ai@localhost:5432/ai_platform"
REDIS_URL="redis://localhost:6379"
PORT=3000
NODE_ENV=development
JWT_SECRET=your-secret-key
```

---

## 🧪 Quick Health Check Commands

```bash
# 1. Check containers
docker ps

# 2. Test NestJS server
npm run start:dev
# Server should start on http://localhost:3000

# 3. Check Swagger docs
# Open: http://localhost:3000/api

# 4. Test health endpoint
curl http://localhost:3000/health

# 5. View database
npm run db:studio
```

---

## 📝 Important Notes

### Multi-Tenancy Pattern
Every request (except auth/public endpoints) must include:
```
X-Tenant-Id: clxxxx...
```

### Data Isolation
All models are linked to `Tenant` with `onDelete: Cascade`:
- Deleting a tenant deletes ALL their data (users, agents, conversations, etc.)
- This is intentional for data isolation

### PrismaService Already Exists
You already have `src/services/prisma.service.ts` - just import it:
```typescript
import { PrismaService } from '../services/prisma.service';
```

---

## 🐛 Common Issues & Solutions

### Issue: Docker containers not running
```bash
# Check if Docker Desktop is running (Windows)
# Then:
docker-compose up -d
```

### Issue: Port 3000 already in use
```bash
# Kill existing process or change PORT in .env
PORT=3001 npm run start:dev
```

### Issue: Database connection error
```bash
# Verify PostgreSQL is running:
docker logs oct25shaaz-postgres-1

# Test connection:
npm run db:studio
```

### Issue: Prisma Client out of sync
```bash
# Regenerate Prisma Client:
npm run db:generate
```

---

## 📚 Resources to Review

1. **Prisma Docs:** https://www.prisma.io/docs/concepts/components/prisma-client
2. **NestJS Guards:** https://docs.nestjs.com/guards
3. **Your Schema Notes:** See `prismanotes.md` in this repo
4. **Current Migration:** `prisma/migrations/20251106022522_ai_platform_schema/migration.sql`

---

## ✅ Quick Start Checklist for Tomorrow

- [ ] Open Docker Desktop
- [ ] Run `docker ps` to verify containers
- [ ] Run `npm run db:studio` to verify database
- [ ] Read Phase 3 plan above
- [ ] Create `src/guards/tenant.guard.ts`
- [ ] Create Tenants module (controller, service, DTOs)
- [ ] Test with Swagger/Postman
- [ ] Commit your work!

---

## 🎯 Success Criteria for Phase 3

You'll know you're done when:
- ✅ TenantGuard validates X-Tenant-Id header
- ✅ Can create new tenant via POST /tenants
- ✅ Can retrieve tenant via GET /tenants/:id
- ✅ Can update tenant plan via PATCH /tenants/:id
- ✅ All endpoints properly validate input with DTOs
- ✅ Swagger docs show all tenant endpoints

---

## 💡 Tips

1. **Start simple** - Get basic CRUD working before adding complex validation
2. **Use Swagger** - Test endpoints at http://localhost:3000/api
3. **Check Prisma Studio** - Visually verify data at http://localhost:5555
4. **Commit often** - Small commits are better than one giant commit
5. **Ask questions** - If stuck, re-read your `prismanotes.md`

---

**Remember:** You've already built the foundation (Phases 1 & 2). Phase 3 is just adding the "gatekeeper" that ensures every API call knows which tenant it's working with!

Good luck tomorrow! 🚀
