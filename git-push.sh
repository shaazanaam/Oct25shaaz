#!/bin/bash

# Git Push Automation Script
# Automatically stages, commits, and pushes changes to GitHub

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Git Push Automation Script                    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not a git repository${NC}"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "\n${YELLOW}Current Branch:${NC} $CURRENT_BRANCH"

# Check for uncommitted changes
if git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}No changes to commit${NC}"
    
    # Check if there are unpushed commits
    UNPUSHED=$(git log origin/$CURRENT_BRANCH..$CURRENT_BRANCH --oneline 2>/dev/null | wc -l)
    if [ "$UNPUSHED" -gt 0 ]; then
        echo -e "${YELLOW}Found $UNPUSHED unpushed commit(s)${NC}"
        echo -e "\n${BLUE}Pushing to origin/$CURRENT_BRANCH...${NC}"
        git push origin $CURRENT_BRANCH
        echo -e "${GREEN}✓ Push successful!${NC}"
    else
        echo -e "${GREEN}Everything is up to date${NC}"
    fi
    exit 0
fi

# Show status
echo -e "\n${BLUE}═══ Git Status ═══${NC}"
git status --short

# Get commit message (use argument or default)
if [ -n "$1" ]; then
    COMMIT_MSG="$1"
else
    # Generate automatic commit message based on date and changes
    DATE=$(date +"%Y-%m-%d")
    CHANGES=$(git status --short | wc -l)
    COMMIT_MSG="[$DATE] Documentation updates - $CHANGES files changed"
fi

echo -e "\n${YELLOW}Commit Message:${NC} $COMMIT_MSG"

# Stage all changes
echo -e "\n${BLUE}Staging all changes...${NC}"
git add -A

# Show what will be committed
echo -e "\n${BLUE}═══ Files to be committed ═══${NC}"
git status --short

# Commit
echo -e "\n${BLUE}Committing changes...${NC}"
git commit -m "$COMMIT_MSG"
echo -e "${GREEN}✓ Commit successful${NC}"

# Push to origin
echo -e "\n${BLUE}Pushing to origin/$CURRENT_BRANCH...${NC}"
git push origin $CURRENT_BRANCH

# Show final status
echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                 Push Successful! ✓                       ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"

echo -e "\n${BLUE}Latest commit:${NC}"
git log -1 --oneline

echo -e "\n${BLUE}Remote status:${NC}"
git status -sb
