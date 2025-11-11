#!/bin/bash

# 🚀 Session Startup Script
# Run this at the start of every coding session

clear

echo "════════════════════════════════════════════════════════════════"
echo "  🚀 AI Platform Development Session - Nov 11, 2025"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📋 SESSION WORKFLOW REMINDER"
echo ""
echo "1. ✅ Open START_HERE.md (1 min)"
echo "2. ✅ Run SESSION_CHECKLIST.md pre-checks (5 min)"
echo "3. ✅ Review ROADMAP.md current phase (3 min)"
echo "4. ✅ Follow PHASE_X_GUIDE.md step-by-step (while coding)"
echo "5. ✅ Document decisions in DEV_SESSION_LOG.md (as you go)"
echo "6. ✅ Run SESSION_CHECKLIST.md post-checks (10 min)"
echo "7. ✅ Update ROADMAP.md and CHANGELOG.md (5 min)"
echo "8. ✅ Commit and push to Git"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""

# Check if Docker is running
echo "🔍 Checking Prerequisites..."
echo ""

# Docker check
if docker ps &> /dev/null; then
    echo "✅ Docker is running"
    
    # Check PostgreSQL container
    if docker ps | grep -q "oct25shaaz-postgres-1"; then
        echo "✅ PostgreSQL container is running (port 5432)"
    else
        echo "⚠️  PostgreSQL container NOT running"
        echo "   Run: docker compose up -d"
    fi
    
    # Check Redis container
    if docker ps | grep -q "oct25shaaz-redis-1"; then
        echo "✅ Redis container is running (port 6379)"
    else
        echo "⚠️  Redis container NOT running"
        echo "   Run: docker compose up -d"
    fi
else
    echo "❌ Docker is NOT running"
    echo "   Action: Start Docker Desktop first"
fi

echo ""

# Check Git status
echo "📦 Git Status:"
git status --short
if [ $? -eq 0 ]; then
    echo ""
    BRANCH=$(git branch --show-current)
    echo "📍 Current branch: $BRANCH"
    
    # Check if there are uncommitted changes
    if [[ -n $(git status --porcelain) ]]; then
        echo "⚠️  You have uncommitted changes"
    else
        echo "✅ Working directory is clean"
    fi
else
    echo "❌ Git status check failed"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📚 Quick Links:"
echo ""
echo "   START_HERE.md           → Overview & current phase"
echo "   SESSION_CHECKLIST.md    → Pre/post session checklist"
echo "   ROADMAP.md              → Master plan (37.5% complete)"
echo "   PHASE_4_GUIDE.md        → Current phase guide"
echo "   DEV_SESSION_LOG.md      → Session notes"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "🎯 CURRENT PHASE: Phase 4 - Agent & Flow Management"
echo ""
echo "📋 TODAY'S TASKS:"
echo "   [ ] 4.1 Create Agent DTOs (30 min)"
echo "   [ ] 4.2 Implement AgentsService (45 min)"
echo "   [ ] 4.3 Implement AgentsController (30 min)"
echo "   [ ] 4.4 Testing & Validation (30 min)"
echo ""
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "💡 REMINDER: Follow the guide exactly - it prevents common mistakes!"
echo ""
echo "🚀 Ready to code? Start with SESSION_CHECKLIST.md!"
echo ""

# Ask if user wants to open key files
read -p "Would you like to open key documentation files? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Opening files in VS Code..."
    code docs/guides/START_HERE.md
    code docs/guides/SESSION_CHECKLIST.md
    code docs/guides/ROADMAP.md
    code docs/guides/PHASE_4_GUIDE.md
    echo "✅ Files opened!"
fi

echo ""
echo "Happy coding! 🎉"
echo ""
