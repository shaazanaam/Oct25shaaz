# 🔔 Automatic Session Reminder System - Setup Guide

**Created:** November 11, 2025  
**Purpose:** Never forget the development workflow - get automatic reminders every session

---

## 🎯 What Was Built

An **automatic reminder system** that shows you the 8-step workflow every time you start coding. No more forgetting to check the roadmap or update documentation!

---

## 🚀 Quick Start (60 Seconds)

### For Windows Users

**Step 1:** Close VS Code if it's currently open

**Step 2:** Open Command Prompt or PowerShell in your project folder:
```bash
cd c:\Users\600790\Oct25shaaz
```

**Step 3:** Open the workspace file:
```bash
code ai-platform.code-workspace
```

**Step 4:** When VS Code asks "Do you trust this workspace?", click **Yes, I trust the authors**

**Step 5:** Look at the terminal! You'll see:
```
════════════════════════════════════════════════════════════════
  🚀 AI Platform Development Session
════════════════════════════════════════════════════════════════

📋 SESSION WORKFLOW REMINDER

1. ✅ Open START_HERE.md (1 min)
2. ✅ Run SESSION_CHECKLIST.md pre-checks (5 min)
3. ✅ Review ROADMAP.md current phase (3 min)
... [full workflow displayed]
```

**Step 6:** Type `y` if you want to auto-open the key documentation files

**Done!** 🎉 You now have automatic reminders every session.

**BONUS:** Track tasks in real-time!
```bash
node track-tasks.js list         # See current progress
node track-tasks.js start 1      # Start task 1
node track-tasks.js complete 1   # Mark complete
```

See [`TASK_TRACKING_GUIDE.md`](TASK_TRACKING_GUIDE.md) for details.

---

## 📋 What Happens Automatically

When you open `ai-platform.code-workspace`, the system:

1. **Runs the startup script** (`start-session.bat`)
2. **Shows the 8-step workflow** in terminal
3. **Checks your environment:**
   - ✅ Is Docker running?
   - ✅ Are PostgreSQL and Redis containers up?
   - ✅ What's your Git status?
4. **Displays current phase** (Phase 4 - Agent & Flow Management)
5. **Lists today's tasks** with time estimates
6. **Offers to open documentation** files for you

---

## 🛠️ What Was Implemented

### Files Created

#### 1. **`start-session.bat`** (Windows Script)
**Location:** Project root  
**Purpose:** The main reminder script for Windows  
**What it does:**
- Displays 8-step workflow in formatted terminal output
- Checks if Docker is running
- Verifies PostgreSQL container (port 5432)
- Verifies Redis container (port 6379)
- Shows Git branch and status
- Lists current phase tasks
- Asks if you want to open documentation files

**How it works:**
```batch
@echo off
cls
echo ================================================================
echo   🚀 AI Platform Development Session
echo ================================================================
... [displays workflow]
... [checks Docker/Git]
... [optionally opens files]
```

---

#### 2. **`start-session.sh`** (Mac/Linux Script)
**Location:** Project root  
**Purpose:** Same as `.bat` but for Mac/Linux  
**What it does:** Identical functionality to Windows version

**How to use manually:**
```bash
chmod +x start-session.sh
./start-session.sh
```

---

#### 3. **`ai-platform.code-workspace`** (VS Code Workspace)
**Location:** Project root  
**Purpose:** VS Code workspace configuration with auto-run task

**Key configuration:**
```json
{
  "tasks": {
    "tasks": [
      {
        "label": "🚀 Start Session Reminder",
        "type": "shell",
        "command": "start-session.bat",
        "runOptions": {
          "runOn": "folderOpen"  // ← Runs automatically!
        }
      }
    ]
  }
}
```

**What this does:**
- When you open the workspace, VS Code automatically runs the task
- The task executes `start-session.bat`
- Terminal shows the reminder before you start coding

**Additional features:**
- Sets window title: "AI Platform - Phase 4 (37.5% Complete)"
- Enables smart Git commits
- Auto-save after 1 second delay
- Recommends Prisma extension

---

#### 4. **`SESSION_REMINDER_SETUP.md`**
**Location:** Project root  
**Purpose:** Complete documentation of reminder system

**Contents:**
- How to set up automatic reminders
- Manual script usage
- What the reminder displays
- Troubleshooting guide
- Alternative reminder methods
- Customization instructions

---

#### 5. **`WORKFLOW_PRINTABLE.txt`**
**Location:** Project root  
**Purpose:** ASCII art version for printing and sticking on monitor

**Contents:**
- 8-step workflow in box format
- Cross-reference questions
- Red flags checklist
- Current phase status
- Today's tasks
- Quick commands reference

**How to use:**
1. Open `WORKFLOW_PRINTABLE.txt`
2. Print it (Ctrl+P)
3. Cut along the line
4. Stick on your monitor with tape

---

### Files Updated

#### **`README.md`**
**What changed:** Added "New to This Project?" section at top

**New content:**
```markdown
## 🚀 **New to This Project?**

**Start here:** Run `.\start-session.bat` (Windows) or `./start-session.sh` (Mac/Linux) 
to see the development workflow reminder.

Or open the workspace: `code ai-platform.code-workspace` for automatic reminders.

See [`SESSION_REMINDER_SETUP.md`](SESSION_REMINDER_SETUP.md) for details.
```

**Why:** Immediately guide new developers to the reminder system

---

## 🎯 How to Use Daily

### Option A: Automatic (Recommended)

**Every day, start coding like this:**

```bash
# Navigate to project
cd c:\Users\600790\Oct25shaaz

# Open workspace (not just "code .")
code ai-platform.code-workspace
```

**Result:** Reminder appears automatically in terminal! ✅

---

### Option B: Manual Script

**If you prefer manual control:**

```bash
# Windows
.\start-session.bat

# Mac/Linux
./start-session.sh
```

**When to use:** 
- You opened VS Code with `code .` instead of workspace
- You want to see reminder mid-session
- Workspace auto-run is disabled

---

## 🔧 Customization Guide

### Update Current Phase

When you move to Phase 5, update the scripts:

**Edit `start-session.bat` (around line 65):**
```batch
REM Change from:
echo 🎯 CURRENT PHASE: Phase 4 - Agent ^& Flow Management

REM To:
echo 🎯 CURRENT PHASE: Phase 5 - Conversations ^& Messages
```

**Edit today's tasks (around line 70):**
```batch
echo 📋 TODAY'S TASKS:
echo    [ ] 5.1 Create Conversations DTOs ^(30 min^)
echo    [ ] 5.2 Implement ConversationsService ^(45 min^)
echo    [ ] 5.3 Implement ConversationsController ^(30 min^)
echo    [ ] 5.4 Redis Integration ^(60 min^)
```

---

### Update Progress Percentage

**Edit workspace title in `ai-platform.code-workspace`:**
```json
{
  "settings": {
    "window.title": "${dirty}${activeEditorShort}${separator}AI Platform - Phase 5 (50% Complete)"
  }
}
```

After Phase 4, you'll be 50% complete (4 of 8 phases).

---

### Disable Auto-Run

**If you don't want automatic reminders:**

**Edit `ai-platform.code-workspace`:**
```json
{
  "tasks": {
    "tasks": [
      {
        "label": "🚀 Start Session Reminder",
        "type": "shell",
        "command": "start-session.bat",
        // Remove this section:
        // "runOptions": {
        //   "runOn": "folderOpen"
        // }
      }
    ]
  }
}
```

Then run script manually when you want it.

---

### Add Custom Checks

**Want to add more environment checks?**

**Edit `start-session.bat` (around line 35):**
```batch
REM Add after Redis check:
echo.
echo 🔍 Checking Node.js version...
node --version
if %errorlevel% neq 0 (
    echo ❌ Node.js not found
) else (
    echo ✅ Node.js installed
)
```

---

## 🐛 Troubleshooting

### Issue: "Permission Denied" (Mac/Linux)

**Problem:** Script doesn't have execute permissions

**Solution:**
```bash
chmod +x start-session.sh
./start-session.sh
```

---

### Issue: Script Doesn't Run Automatically

**Problem:** Workspace task not executing

**Checklist:**
1. ✅ Did you open **workspace file** (`code ai-platform.code-workspace`)?
   - NOT just the folder (`code .`)
2. ✅ Did you trust the workspace when prompted?
3. ✅ Is task auto-detect enabled?
   - `File > Preferences > Settings`
   - Search "task auto detect"
   - Should be "on"

**Fix:** Reload VS Code window
```
Ctrl+Shift+P → "Developer: Reload Window"
```

---

### Issue: Terminal Closes Too Fast

**Problem:** Can't read the reminder before terminal closes

**Solution:** Script already has `pause` command at end (Windows)

**If still closing:**
```batch
REM Add at end of start-session.bat:
timeout /t 30
```

This keeps terminal open for 30 seconds.

---

### Issue: Want Different Terminal

**Problem:** Script opens in wrong terminal (PowerShell vs CMD)

**Solution:** Edit workspace task:
```json
{
  "tasks": [{
    "command": "start-session.bat",
    "options": {
      "shell": {
        "executable": "cmd.exe"  // or "powershell.exe"
      }
    }
  }]
}
```

---

### Issue: Docker Check Fails But Docker Is Running

**Problem:** Docker command not in PATH

**Solution:** 
1. Verify Docker Desktop is running
2. Open new terminal window
3. Run `docker --version`
4. If fails, add Docker to PATH:
   - Windows: `C:\Program Files\Docker\Docker\resources\bin`
   - Restart terminal

---

## 💡 Best Practices

### Practice 1: Make It a Habit

**Week 1:** Consciously follow the reminder every day  
**Week 2:** It starts feeling natural  
**Week 3:** It's automatic - you don't need the reminder as much

**Goal:** Internalize the workflow, use reminder as backup

---

### Practice 2: Update When Phase Changes

**After completing Phase 4:**
1. Update `start-session.bat` with Phase 5 info
2. Update `WORKFLOW_PRINTABLE.txt` if you printed it
3. Update workspace title with new progress %
4. Commit changes: `git commit -m "chore: update reminder for phase 5"`

---

### Practice 3: Customize to Your Style

**The scripts are templates!** Edit them to match your workflow:
- Add checks for other tools you use
- Change the format/colors
- Add reminders for your specific pain points
- Remove sections you don't need

---

### Practice 4: Combine with Physical Reminders

**Digital + Physical = Best Results**

- Print `WORKFLOW_PRINTABLE.txt` → Stick on monitor
- Set phone alarm for end-of-session checklist
- Use browser start page with `START_HERE.md`
- Desktop wallpaper with the 8 steps

**Why:** Multiple reminders reinforce the habit

---

## 🎯 Alternative Reminder Methods

If workspace auto-run doesn't work for you, try these:

### Method 1: Git Alias

**Add to `.git/config` or `~/.gitconfig`:**
```ini
[alias]
    start = !cmd /c start-session.bat
```

**Usage:**
```bash
git start  # Shows reminder
```

---

### Method 2: Windows Scheduled Task

**Create task that runs on login:**
1. Open Task Scheduler
2. Create Basic Task
3. Trigger: "When I log on"
4. Action: Run `start-session.bat`
5. Only runs when you're ready to code

---

### Method 3: VS Code Extension

**Install "Todo Tree" extension:**
1. Create `.vscode/tasks.json` with reminder task
2. Set as default task
3. Shows in status bar

---

### Method 4: Browser Extension

**Use "New Tab Redirect" extension:**
1. Set new tab URL to: `file:///C:/Users/600790/Oct25shaaz/START_HERE.md`
2. Install Markdown viewer extension
3. Every new tab shows workflow

---

## 📊 Measuring Effectiveness

**After 1 week, ask yourself:**

- ✅ Did I check SESSION_CHECKLIST.md before coding? (Goal: 80%+)
- ✅ Did I update ROADMAP.md after completing tasks? (Goal: 100%)
- ✅ Did I document decisions in DEV_SESSION_LOG.md? (Goal: 80%+)
- ✅ Did I commit work at end of session? (Goal: 100%)
- ✅ Did I stay on the current phase (no skipping)? (Goal: 100%)

**If scoring low:** Try printable reminder or multiple methods

**If scoring high:** System is working! Keep it up! 🎉

---

## 🔄 Maintenance

### When to Update Scripts

**Every phase completion:**
- [ ] Update current phase number
- [ ] Update tasks list
- [ ] Update progress percentage
- [ ] Update workspace title
- [ ] Test that reminder still works

**Monthly:**
- [ ] Review if reminder is still helpful
- [ ] Adjust time estimates based on reality
- [ ] Add any new checks you need
- [ ] Remove checks that aren't useful

---

## 🎓 Learning Resources

**Understanding the components:**

1. **Bash/Batch scripting:**
   - Windows batch: https://ss64.com/nt/
   - Bash scripting: https://www.shellscript.sh/

2. **VS Code workspace:**
   - Docs: https://code.visualstudio.com/docs/editor/workspaces
   - Tasks: https://code.visualstudio.com/docs/editor/tasks

3. **Git hooks (advanced):**
   - If you want pre-commit reminders
   - https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks

---

## 🚀 Next Steps

**Immediate (Next 5 Minutes):**
1. Close current VS Code window
2. Run: `code ai-platform.code-workspace`
3. Trust the workspace
4. See the reminder appear! ✅

**This Week:**
1. Use workspace file every day
2. Follow the 8-step workflow
3. Notice if you forget fewer tasks
4. Adjust scripts to your preference

**After Phase 4:**
1. Update scripts with Phase 5 info
2. Update progress to 50%
3. Share your experience (what worked, what didn't)

---

## ❓ FAQ

### Q: Do I have to use the workspace file?

**A:** No! You can:
- Run `.\start-session.bat` manually
- Use any of the alternative methods
- Print the workflow and skip automation

The workspace is just the **easiest** option.

---

### Q: Can I customize the reminder text?

**A:** Absolutely! Edit `start-session.bat` directly. It's just a text file.

---

### Q: Will this work with Git Bash in VS Code?

**A:** Yes, but you might need to use `start-session.sh` instead. Update workspace task:
```json
{
  "command": "./start-session.sh"
}
```

---

### Q: What if I work on multiple computers?

**A:** 
1. Scripts are committed to Git ✅
2. Workspace file is committed ✅
3. Just `git pull` on other computer
4. Open workspace - works automatically!

---

### Q: Can I turn it off temporarily?

**A:** Yes! Just open VS Code with `code .` instead of `code ai-platform.code-workspace`

No workspace = No auto-run = No reminder

---

## 📝 Summary

**What you have now:**

✅ **Automatic reminder** every time you open workspace  
✅ **Environment checks** (Docker, Git, Database)  
✅ **Current phase visibility** (Phase 4)  
✅ **Task list with time estimates**  
✅ **Quick documentation access**  
✅ **Printable backup** for your monitor  
✅ **Complete customization** options

**What to do now:**

```bash
# Close VS Code
# Open terminal in project root
cd c:\Users\600790\Oct25shaaz

# Open workspace (not just folder!)
code ai-platform.code-workspace

# Trust workspace when prompted
# Watch the magic happen! 🎉
```

---

**The reminder system is live! You'll never forget the workflow again.** 🚀

**Questions?** Check `SESSION_REMINDER_SETUP.md` for additional details.
