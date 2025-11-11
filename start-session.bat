@echo off
REM 🚀 Session Startup Script for Windows
REM Run this at the start of every coding session

cls

echo ================================================================
echo   🚀 AI Platform Development Session - Nov 11, 2025
echo ================================================================
echo.
echo 📋 SESSION WORKFLOW REMINDER
echo.
echo 1. ✅ Open START_HERE.md (1 min)
echo 2. ✅ Run SESSION_CHECKLIST.md pre-checks (5 min)
echo 3. ✅ Review ROADMAP.md current phase (3 min)
echo 4. ✅ Follow PHASE_X_GUIDE.md step-by-step (while coding)
echo 5. ✅ Document decisions in DEV_SESSION_LOG.md (as you go)
echo 6. ✅ Run SESSION_CHECKLIST.md post-checks (10 min)
echo 7. ✅ Update ROADMAP.md and CHANGELOG.md (5 min)
echo 8. ✅ Commit and push to Git
echo.
echo ================================================================
echo.

REM Check if Docker is running
echo 🔍 Checking Prerequisites...
echo.

docker ps >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Docker is running
    
    REM Check PostgreSQL container
    docker ps | findstr "oct25shaaz-postgres-1" >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ PostgreSQL container is running ^(port 5432^)
    ) else (
        echo ⚠️  PostgreSQL container NOT running
        echo    Run: docker compose up -d
    )
    
    REM Check Redis container
    docker ps | findstr "oct25shaaz-redis-1" >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Redis container is running ^(port 6379^)
    ) else (
        echo ⚠️  Redis container NOT running
        echo    Run: docker compose up -d
    )
) else (
    echo ❌ Docker is NOT running
    echo    Action: Start Docker Desktop first
)

echo.

REM Check Git status
echo 📦 Git Status:
git status --short
if %errorlevel% equ 0 (
    echo.
    for /f "tokens=*" %%i in ('git branch --show-current') do set BRANCH=%%i
    echo 📍 Current branch: %BRANCH%
    
    git status --porcelain >nul 2>&1
    if %errorlevel% neq 0 (
        echo ⚠️  You have uncommitted changes
    ) else (
        echo ✅ Working directory is clean
    )
)

echo.
echo ================================================================
echo.
echo 📚 Quick Links:
echo.
echo    START_HERE.md           → Overview ^& current phase
echo    SESSION_CHECKLIST.md    → Pre/post session checklist
echo    ROADMAP.md              → Master plan ^(37.5%% complete^)
echo    PHASE_4_GUIDE.md        → Current phase guide
echo    DEV_SESSION_LOG.md      → Session notes
echo.
echo ================================================================
echo.
echo 🎯 CURRENT PHASE: Phase 4 - Agent ^& Flow Management
echo.
echo 📋 TODAY'S TASKS:

REM Check if task tracker exists and use it
if exist .session-state.json (
    node track-tasks.js list 2>nul
    if %errorlevel% neq 0 (
        REM Fallback to static list
        echo    [ ] 4.1 Create Agent DTOs ^(30 min^)
        echo    [ ] 4.2 Implement AgentsService ^(45 min^)
        echo    [ ] 4.3 Implement AgentsController ^(30 min^)
        echo    [ ] 4.4 Testing ^& Validation ^(30 min^)
    )
) else (
    REM Static list if no tracker
    echo    [ ] 4.1 Create Agent DTOs ^(30 min^)
    echo    [ ] 4.2 Implement AgentsService ^(45 min^)
    echo    [ ] 4.3 Implement AgentsController ^(30 min^)
    echo    [ ] 4.4 Testing ^& Validation ^(30 min^)
)
echo.
echo ================================================================
echo.
echo 💡 REMINDER: Follow the guide exactly - it prevents common mistakes!
echo.
echo 🚀 Ready to code? Start with SESSION_CHECKLIST.md!
echo.

REM Ask if user wants to open key files
set /p OPEN_FILES="Would you like to open key documentation files? (y/n) "
if /i "%OPEN_FILES%"=="y" (
    echo Opening files in VS Code...
    code docs\guides\START_HERE.md
    code docs\guides\SESSION_CHECKLIST.md
    code docs\guides\ROADMAP.md
    code docs\guides\PHASE_4_GUIDE.md
    echo ✅ Files opened!
)

echo.
echo Happy coding! 🎉
echo.
pause
