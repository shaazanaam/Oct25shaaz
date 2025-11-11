#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const STATE_FILE = path.join(__dirname, '.session-state.json');

// Load current state
function loadState() {
  if (!fs.existsSync(STATE_FILE)) {
    console.error('❌ State file not found. Run start-session first.');
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(STATE_FILE, 'utf8'));
}

// Save state
function saveState(state) {
  state.lastUpdated = new Date().toISOString();
  fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
}

// Display current tasks
function displayTasks(state) {
  console.log('\n════════════════════════════════════════════════════════════════');
  console.log(`  📋 ${state.currentPhase}: ${state.phaseName}`);
  console.log(`  Progress: ${state.phaseProgress}% | Overall: ${state.overallProgress}%`);
  console.log('════════════════════════════════════════════════════════════════\n');

  state.tasks.forEach((task, index) => {
    const checkbox = task.status === 'completed' ? '✅' : '⬜';
    const status = task.status === 'in-progress' ? '🔄' : checkbox;
    const time = task.status === 'completed' 
      ? `(completed ${new Date(task.completedAt).toLocaleTimeString()})` 
      : `(${task.estimatedTime})`;
    
    console.log(`  ${index + 1}. ${status} ${task.id} ${task.name} ${time}`);
  });

  console.log('\n════════════════════════════════════════════════════════════════\n');
}

// Mark task as complete
function completeTask(state, taskIndex) {
  const task = state.tasks[taskIndex];
  if (!task) {
    console.error(`❌ Task ${taskIndex + 1} not found`);
    return;
  }

  if (task.status === 'completed') {
    console.log(`ℹ️  Task ${task.id} is already completed`);
    return;
  }

  task.status = 'completed';
  task.completedAt = new Date().toISOString();

  // Calculate phase progress
  const completed = state.tasks.filter(t => t.status === 'completed').length;
  state.phaseProgress = Math.round((completed / state.tasks.length) * 100);

  saveState(state);
  console.log(`✅ Marked task ${task.id} as complete!`);
  console.log(`📊 Phase progress: ${state.phaseProgress}%\n`);
}

// Mark task as in-progress
function startTask(state, taskIndex) {
  const task = state.tasks[taskIndex];
  if (!task) {
    console.error(`❌ Task ${taskIndex + 1} not found`);
    return;
  }

  if (task.status === 'completed') {
    console.log(`ℹ️  Task ${task.id} is already completed`);
    return;
  }

  // Mark other tasks as not in progress
  state.tasks.forEach(t => {
    if (t.status === 'in-progress') t.status = 'not-started';
  });

  task.status = 'in-progress';
  saveState(state);
  console.log(`🔄 Started task ${task.id}: ${task.name}`);
}

// Interactive menu
async function interactiveMenu() {
  const state = loadState();
  displayTasks(state);

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  const question = (prompt) => new Promise((resolve) => rl.question(prompt, resolve));

  console.log('Commands:');
  console.log('  s <number> - Start task (e.g., s 1)');
  console.log('  c <number> - Complete task (e.g., c 1)');
  console.log('  l          - List tasks');
  console.log('  q          - Quit\n');

  while (true) {
    const answer = await question('> ');
    const [cmd, ...args] = answer.trim().split(' ');

    switch (cmd.toLowerCase()) {
      case 's':
      case 'start':
        const startIndex = parseInt(args[0]) - 1;
        startTask(state, startIndex);
        displayTasks(state);
        break;

      case 'c':
      case 'complete':
        const completeIndex = parseInt(args[0]) - 1;
        completeTask(state, completeIndex);
        displayTasks(state);
        break;

      case 'l':
      case 'list':
        displayTasks(state);
        break;

      case 'q':
      case 'quit':
      case 'exit':
        console.log('\n✅ Task tracking saved. Happy coding! 🚀\n');
        rl.close();
        return;

      default:
        console.log('❌ Unknown command. Use: s <num>, c <num>, l, or q\n');
    }
  }
}

// CLI mode
function cliMode() {
  const state = loadState();
  const args = process.argv.slice(2);
  const command = args[0];

  switch (command) {
    case 'list':
      displayTasks(state);
      break;

    case 'start':
      const startIndex = parseInt(args[1]) - 1;
      startTask(state, startIndex);
      displayTasks(state);
      break;

    case 'complete':
      const completeIndex = parseInt(args[1]) - 1;
      completeTask(state, completeIndex);
      displayTasks(state);
      break;

    case 'reset':
      state.tasks.forEach(t => {
        t.status = 'not-started';
        t.completedAt = null;
      });
      state.phaseProgress = 0;
      saveState(state);
      console.log('✅ All tasks reset to not-started\n');
      displayTasks(state);
      break;

    case 'interactive':
      interactiveMenu();
      break;

    default:
      console.log('Usage:');
      console.log('  node track-tasks.js list              - Show all tasks');
      console.log('  node track-tasks.js start <number>    - Mark task as in-progress');
      console.log('  node track-tasks.js complete <number> - Mark task as complete');
      console.log('  node track-tasks.js reset             - Reset all tasks');
      console.log('  node track-tasks.js interactive       - Interactive mode');
      console.log('\nExample: node track-tasks.js start 1');
  }
}

// Run
if (require.main === module) {
  if (process.argv.length <= 2) {
    interactiveMenu();
  } else {
    cliMode();
  }
}

module.exports = { loadState, saveState, displayTasks, completeTask, startTask };
