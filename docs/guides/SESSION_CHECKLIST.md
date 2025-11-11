# 📋 Session Start Checklist

**Purpose:** Run through this checklist at the start of EVERY coding session to ensure you're on track with the roadmap.

---

##  Pre-Session Checklist (5 minutes)

### 1. Environment Verification
```bash
# Check Docker containers are running
docker ps

# Expected output:
# - oct25shaaz-postgres-1 (port 5432)
# - oct25shaaz-redis-1 (port 6379)

# If not running, start them:
docker compose up -d
```

### 2. Git Sync
```bash
# Pull latest changes
git pull origin main

# Check current branch
git branch

# Verify clean working directory
git status
```

### 3. Database Status
```bash
# Check migration status
npm run db:migrate:status

# Should show: "Database schema is up to date!"

# (Optional) View data
npm run db:studio
```

### 4. Review Roadmap
- [ ] Open `ROADMAP.md`
- [ ] Identify current phase: **Phase ____**
- [ ] Read phase goals and tasks
- [ ] Note estimated time for today's work

### 5. Read Phase Guide
- [ ] Open phase-specific guide (e.g., `PHASE_4_GUIDE.md`)
- [ ] Review step-by-step plan
- [ ] Understand what you're building today
- [ ] Note any prerequisites or dependencies

### 6. Check Last Session Notes
- [ ] Open `DEV_SESSION_LOG.md`
- [ ] Read "Next Session" section from previous day
- [ ] Review any blockers or open questions
- [ ] Check decisions made that affect today's work

### 7. Review Recent Changes
- [ ] Open `CHANGELOG.md`
- [ ] Read last 2-3 entries
- [ ] Understand what was recently completed
- [ ] Verify no breaking changes

---

## 🎯 During Session Guidelines

### Before Writing Code
- [ ] Is this task in the current phase plan?
- [ ] Have I read the relevant section of the phase guide?
- [ ] Do I understand WHY this feature is needed?
- [ ] Do I know the success criteria for this task?

### While Coding
- [ ] Following the step-by-step guide
- [ ] Writing clean, type-safe TypeScript
- [ ] Adding validation to all DTOs
- [ ] Including Swagger documentation
- [ ] Testing each feature before moving on
- [ ] Documenting complex decisions in `DEV_SESSION_LOG.md`

### Cross-Reference Questions
Ask yourself frequently:
-  **Is this in the roadmap?** Check `ROADMAP.md`
-  **Does this follow the phase plan?** Check `PHASE_X_GUIDE.md`
-  **Will this break existing features?** Check `CHANGELOG.md`
-  **Is this consistent with project architecture?** Check `README.md`

---

##  Post-Task Checklist

After completing each major task:

### 1. Test the Feature
```bash
# Start dev server
npm run start:dev

# Open Swagger UI
# http://localhost:3000/api

# Manually test:
# - Happy path (valid input)
# - Error cases (invalid input, missing fields)
# - Tenant isolation (if applicable)
```

### 2. Update Documentation
- [ ] Mark task complete in `ROADMAP.md`
- [ ] Add entry to `DEV_SESSION_LOG.md` (decisions, blockers)
- [ ] Update progress percentage in `ROADMAP.md`

### 3. Check for Errors
```bash
# TypeScript compilation
npm run build

# Should complete with no errors

# Check for linting issues (if ESLint configured)
npm run lint
```

### 4. Commit Your Work
```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat(phase-4): implement agents service with CRUD operations"

# Use conventional commit format:
# - feat: New feature
# - fix: Bug fix
# - docs: Documentation only
# - refactor: Code restructuring
# - test: Adding tests
# - chore: Maintenance
```

---

##  End-of-Session Checklist (10 minutes)

### 1. Update All Documentation
- [ ] `ROADMAP.md` - Mark completed tasks, update progress %
- [ ] `CHANGELOG.md` - Add entry with today's changes
- [ ] `DEV_SESSION_LOG.md` - Document decisions, add "Next Session" note
- [ ] `README.md` - Update if phase completed

### 2. Verify Everything Works
```bash
# Stop and restart server
npm run start:dev

# Quick smoke test:
# - Health check: GET /health
# - Create test resource
# - Verify in database: npm run db:studio
```

### 3. Git Push
```bash
# Push changes to remote
git push origin main

# Verify push succeeded
git log --oneline -5
```

### 4. Plan Tomorrow
Write in `DEV_SESSION_LOG.md`:

```markdown
### Next Session Plan (YYYY-MM-DD)
**Start with:**
- [ ] Task 1 (estimated 30 min)
- [ ] Task 2 (estimated 45 min)

**Prerequisites:**
- Verify [X] feature works
- Read [Y] documentation

**Goal:**
Complete Phase X.Y by end of session
```

---

## 🚨 Red Flags - Stop and Reassess

If you encounter these, STOP and review the roadmap:

- ❌ **Writing code not in the phase plan** → Check `ROADMAP.md`
- ❌ **Creating files not mentioned in guide** → Check `PHASE_X_GUIDE.md`
- ❌ **Stuck for more than 30 minutes** → Review documentation, ask for help
- ❌ **Breaking existing features** → Check `CHANGELOG.md` for recent changes
- ❌ **TypeScript errors you don't understand** → Review similar code in project
- ❌ **Unsure about architectural decision** → Read `README.md` architecture section

---

## 📊 Phase Completion Checklist

Before marking a phase as complete:

### Code Quality
- [ ] All endpoints have Swagger `@ApiOperation` and `@ApiResponse` decorators
- [ ] All DTOs use `class-validator` decorators (`@IsString`, `@IsNotEmpty`, etc.)
- [ ] All services have proper error handling (try/catch or Prisma error handling)
- [ ] All database queries filter by `tenantId` (except tenant creation)
- [ ] No `console.log` statements (use NestJS Logger instead)
- [ ] TypeScript compiles with no errors: `npm run build`

### Testing
- [ ] Tested all happy paths via Swagger UI
- [ ] Tested error cases (400, 403, 404, 409)
- [ ] Tested tenant isolation (Tenant A can't access Tenant B's data)
- [ ] Tested with missing/invalid headers
- [ ] Tested cascade deletes (if applicable)

### Documentation
- [ ] Created phase explanation doc (e.g., `AGENTS_MODULE_EXPLANATION.md`)
- [ ] Updated `ROADMAP.md` with  checkmarks
- [ ] Added detailed `CHANGELOG.md` entry
- [ ] Updated `README.md` if needed
- [ ] Committed all changes with clear message
- [ ] Pushed to GitHub

### Database
- [ ] Migration created (if schema changed): `npm run db:migrate:dev`
- [ ] Migration applied successfully
- [ ] Verified tables in Prisma Studio
- [ ] Sample data creates successfully

---

## 🎯 Quick Reference

**Current Phase:** See top of `ROADMAP.md`  
**Current Task:** See `ROADMAP.md` under current phase  
**Last Decision:** See bottom of `DEV_SESSION_LOG.md`  
**Recent Changes:** See top of `CHANGELOG.md`  
**Next Steps:** See `PHASE_X_GUIDE.md` for current phase

---

## 💡 Tips for Staying on Track

1. **Print this checklist** or keep it open in a separate window
2. **Set a timer** - Work in 45-minute focused blocks
3. **Commit often** - Small commits are better than one giant commit
4. **Test immediately** - Don't write 5 files without testing
5. **Document as you go** - Don't leave docs for "later"
6. **Follow the guide** - Resist urge to skip ahead or deviate
7. **Ask yourself:** "Is this in the roadmap?" before starting new work

---

## 🔄 Roadmap Sync Workflow

```
┌─────────────────────────────────────────────┐
│ 1. START SESSION                            │
│    ↓ Run Pre-Session Checklist              │
│    ↓ Read ROADMAP.md current phase          │
│    ↓ Read PHASE_X_GUIDE.md                  │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 2. WHILE CODING                             │
│    ↓ Follow guide step-by-step              │
│    ↓ Test each feature                      │
│    ↓ Update DEV_SESSION_LOG.md              │
│    ↓ Cross-reference frequently             │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 3. AFTER EACH TASK                          │
│    ↓ Mark complete in ROADMAP.md            │
│    ↓ Add to CHANGELOG.md                    │
│    ↓ Commit with clear message              │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│ 4. END SESSION                              │
│    ↓ Update all docs                        │
│    ↓ Push to GitHub                         │
│    ↓ Write "Next Session" plan              │
└─────────────────────────────────────────────┘
```

---

**Remember:** The roadmap exists to GUIDE you, not restrict you. But if you deviate, document WHY in `DEV_SESSION_LOG.md`!

**Goal:** Finish Phase 8 by end of November 2025 🚀
