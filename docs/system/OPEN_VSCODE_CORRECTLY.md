# 🚀 How to Open VS Code for This Project

---

## ❌ WRONG WAY (No Reminders)

```bash
cd c:\Users\600790\Oct25shaaz
code .                              # ← Opens folder only
```

**What happens:**
- ❌ No automatic reminder
- ❌ No session workflow displayed
- ❌ You might forget the checklist
- ❌ Manual work required

---

##  RIGHT WAY (With Automatic Reminders)

```bash
cd c:\Users\600790\Oct25shaaz
code ai-platform.code-workspace     # ← Opens workspace file
```

**What happens:**
-  Terminal automatically shows reminder
-  8-step workflow displayed
-  Environment checks (Docker, Git)
-  Current phase and tasks shown
-  Optionally opens documentation files

---

## 📊 Visual Comparison

```
┌─────────────────────────────────────────────────────────────┐
│  WRONG: code .                                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [VS Code opens]                                            │
│  [Empty terminal]                                           │
│  [You have to manually remember everything]                 │
│                                                             │
│  ❌ No guidance                                             │
│  ❌ Easy to forget steps                                    │
│  ❌ Must open docs manually                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────┐
│  RIGHT: code ai-platform.code-workspace                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [VS Code opens]                                            │
│  [Terminal automatically shows:]                            │
│                                                             │
│  ════════════════════════════════════════════════════       │
│    🚀 AI Platform Development Session                      │
│  ════════════════════════════════════════════════════       │
│                                                             │
│  📋 SESSION WORKFLOW REMINDER                               │
│                                                             │
│  1.  Open START_HERE.md (1 min)                          │
│  2.  Run SESSION_CHECKLIST.md pre-checks (5 min)         │
│  ... [full workflow displayed]                              │
│                                                             │
│  🔍 Checking Prerequisites...                               │
│   Docker is running                                       │
│   PostgreSQL container running                            │
│   Redis container running                                 │
│                                                             │
│  🎯 CURRENT PHASE: Phase 4 - Agent & Flow Management       │
│                                                             │
│   Clear guidance                                          │
│   Can't forget steps                                      │
│   Auto-opens docs (optional)                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Quick Reference

### Open with Reminders (Recommended)
```bash
code ai-platform.code-workspace
```

### Open without Reminders (Not Recommended)
```bash
code .
```

### Run Reminder Manually (Backup Option)
```bash
.\start-session.bat          # Windows
./start-session.sh           # Mac/Linux
```

---

## 💡 Pro Tip: Create a Shortcut

**Windows Desktop Shortcut:**
1. Right-click Desktop → New → Shortcut
2. Location: `"C:\Program Files\Microsoft VS Code\Code.exe" "c:\Users\600790\Oct25shaaz\ai-platform.code-workspace"`
3. Name: `AI Platform (with reminders)`
4. Double-click to start coding! 🚀

**Windows Terminal Profile:**
Add to Windows Terminal settings:
```json
{
  "name": "AI Platform Dev",
  "commandline": "cmd.exe /k cd c:\\Users\\600790\\Oct25shaaz && code ai-platform.code-workspace"
}
```

---

## 📋 Bookmark This Command

**Save this in a text file on your desktop:**
```bash
code c:\Users\600790\Oct25shaaz\ai-platform.code-workspace
```

**Or create a batch file `start-ai-dev.bat`:**
```batch
@echo off
cd c:\Users\600790\Oct25shaaz
code ai-platform.code-workspace
```

Double-click to start your session!

---

## 🎯 Remember

**Workspace file = Automatic reminders = Better workflow adherence**

Always use:
```bash
code ai-platform.code-workspace
```

NOT:
```bash
code .
```

---

**See full details:** [`HOW_TO_USE_REMINDER_SYSTEM.md`](HOW_TO_USE_REMINDER_SYSTEM.md)
