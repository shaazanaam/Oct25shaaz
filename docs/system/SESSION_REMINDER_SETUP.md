# 🔔 Session Reminder Automation

This folder contains scripts to **automatically remind you** of the session workflow every time you start coding.

---

## 🚀 Quick Setup (One-Time)

### Option 1: Windows (Recommended)

**Step 1:** Open this workspace in VS Code
```bash
# In the project root folder, run:
code ai-platform.code-workspace
```

**Step 2:** Trust the workspace when prompted

**Step 3:** The reminder will **automatically appear** when you open the workspace!

---

### Option 2: Manual Script

If you don't want automatic reminders, run this manually each session:

**Windows:**
```bash
.\start-session.bat
```

**Mac/Linux:**
```bash
chmod +x start-session.sh
./start-session.sh
```

---

## 📋 What the Reminder Shows

When you open VS Code or run the script, you'll see:

```
════════════════════════════════════════════════════════════════
  🚀 AI Platform Development Session - Nov 11, 2025
════════════════════════════════════════════════════════════════

📋 SESSION WORKFLOW REMINDER

1. ✅ Open START_HERE.md (1 min)
2. ✅ Run SESSION_CHECKLIST.md pre-checks (5 min)
3. ✅ Review ROADMAP.md current phase (3 min)
4. ✅ Follow PHASE_X_GUIDE.md step-by-step (while coding)
5. ✅ Document decisions in DEV_SESSION_LOG.md (as you go)
6. ✅ Run SESSION_CHECKLIST.md post-checks (10 min)
7. ✅ Update ROADMAP.md and CHANGELOG.md (5 min)
8. ✅ Commit and push to Git

════════════════════════════════════════════════════════════════

🔍 Checking Prerequisites...

✅ Docker is running
✅ PostgreSQL container is running (port 5432)
✅ Redis container is running (port 6379)

📦 Git Status:
📍 Current branch: main
✅ Working directory is clean

════════════════════════════════════════════════════════════════

📚 Quick Links:

   START_HERE.md           → Overview & current phase
   SESSION_CHECKLIST.md    → Pre/post session checklist
   ROADMAP.md              → Master plan (37.5% complete)
   PHASE_4_GUIDE.md        → Current phase guide
   DEV_SESSION_LOG.md      → Session notes

════════════════════════════════════════════════════════════════

🎯 CURRENT PHASE: Phase 4 - Agent & Flow Management

📋 TODAY'S TASKS:
   [ ] 4.1 Create Agent DTOs (30 min)
   [ ] 4.2 Implement AgentsService (45 min)
   [ ] 4.3 Implement AgentsController (30 min)
   [ ] 4.4 Testing & Validation (30 min)

════════════════════════════════════════════════════════════════

💡 REMINDER: Follow the guide exactly - it prevents common mistakes!

🚀 Ready to code? Start with SESSION_CHECKLIST.md!

Would you like to open key documentation files? (y/n)
```

---

## 📁 Files Created

1. **`start-session.bat`** - Windows script
2. **`start-session.sh`** - Mac/Linux script
3. **`ai-platform.code-workspace`** - VS Code workspace with auto-run task

---

## 🎯 How It Works

### Automatic Mode (Workspace)

When you open `ai-platform.code-workspace`:
1. VS Code loads the workspace
2. Runs `start-session.bat` automatically
3. Shows reminder in terminal
4. Checks Docker, Git status
5. Optionally opens documentation files

### Manual Mode (Scripts)

Run the script when you start coding:
- Checks prerequisites (Docker, Git)
- Shows workflow reminder
- Displays current tasks
- Opens docs if you want

---

## ⚙️ Customization

### Update Current Phase

Edit `start-session.bat` or `start-session.sh`:

```bash
# Change this line:
echo 🎯 CURRENT PHASE: Phase 4 - Agent & Flow Management

# To current phase:
echo 🎯 CURRENT PHASE: Phase 5 - Conversations Module
```

### Update Tasks

Edit the "TODAY'S TASKS" section:

```bash
echo 📋 TODAY'S TASKS:
echo    [ ] 5.1 Create Conversations DTOs (30 min)
echo    [ ] 5.2 Implement ConversationsService (45 min)
# ... etc
```

### Disable Auto-Run

If you don't want automatic reminders:

1. Open `ai-platform.code-workspace`
2. Remove the `runOptions` section from the task
3. Run script manually when needed

---

## 🔧 Troubleshooting

### "Permission Denied" on Mac/Linux

```bash
chmod +x start-session.sh
./start-session.sh
```

### Script Doesn't Run Automatically

1. Make sure you opened the **workspace file**, not just the folder
2. Check VS Code settings: `File > Preferences > Settings > Task: Auto Detect`
3. Reload VS Code window: `Ctrl+Shift+P` → "Reload Window"

### Want Different Behavior

Edit the scripts! They're just bash/batch files. Customize to your workflow.

---

## 💡 Pro Tips

### Tip 1: Pin the Terminal
When the reminder appears, pin the terminal panel so you can reference it while coding.

### Tip 2: Keep START_HERE.md Open
Open it in a split view so you always see the current phase.

### Tip 3: Physical Sticky Note
Print the 8-step workflow and stick it on your monitor!

### Tip 4: Set Phone Reminder
Set a reminder to check SESSION_CHECKLIST.md at end of session.

### Tip 5: Make It a Habit
Run for 1 week - it becomes automatic after that.

---

## 🎯 Alternative Reminder Methods

### Method 1: Browser Start Page
Set `file:///path/to/START_HERE.md` as browser homepage (using Markdown viewer extension)

### Method 2: Desktop Wallpaper
Screenshot the workflow and set as wallpaper

### Method 3: VS Code Extension
Install a TODO/reminder extension and add the workflow

### Method 4: Git Hook
Add pre-commit hook to remind you to update docs

### Method 5: Calendar
Add recurring calendar event at your usual coding time

---

## 📊 Effectiveness Tracking

After 1 week of using reminders, ask yourself:

- ✅ Am I following the workflow more consistently?
- ✅ Am I forgetting fewer documentation updates?
- ✅ Am I staying on the roadmap better?
- ✅ Am I less likely to go off-plan?

If yes to most → Keep using!  
If no → Try a different method above

---

## 🚀 Getting Started Right Now

**For Windows Users:**
```bash
# Option 1: Use workspace (automatic)
code ai-platform.code-workspace

# Option 2: Run script manually
.\start-session.bat
```

**For Mac/Linux Users:**
```bash
# Option 1: Use workspace (automatic)
code ai-platform.code-workspace

# Option 2: Run script manually
chmod +x start-session.sh
./start-session.sh
```

---

**The reminder system exists to help you build the habit. After a few weeks, the workflow becomes second nature!** 🎯
