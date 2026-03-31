#!/bin/bash
# NEPI Engine — Session Start Hook
# Loads the most recent valid session summary for Claude Code continuity.
# Session files older than 7 days are ignored. Files older than 14 days are pruned.

SESSIONS_DIR=".claude/sessions"
MAX_AGE_LOAD=7
MAX_AGE_PRUNE=14

# Prune old session files
find "$SESSIONS_DIR" -name "*.md" -mtime +$MAX_AGE_PRUNE -delete 2>/dev/null

# Find the most recent session file within the load window
RECENT=$(find "$SESSIONS_DIR" -name "*.md" -mtime -$MAX_AGE_LOAD 2>/dev/null | sort -r | head -1)

if [ -n "$RECENT" ]; then
  echo "=== SESSION CONTINUITY ==="
  echo "Loading context from: $RECENT"
  echo ""
  cat "$RECENT"
  echo ""
  echo "=== END SESSION CONTEXT ==="
else
  echo "No recent session summary found. Starting fresh."
fi
