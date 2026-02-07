#!/bin/bash
# Amnesia New Day Script
# Creates a new daily log file if it doesn't exist
#
# Usage: ./new-day.sh [workspace_dir]

WORKSPACE="${1:-.}"
TODAY=$(date +%Y-%m-%d)
NOW=$(date -u +"%H:%M UTC")
LOG_DIR="$WORKSPACE/memory"
LOG_FILE="$LOG_DIR/$TODAY.md"

# Create memory directory if needed
mkdir -p "$LOG_DIR"

# Check if today's log already exists
if [ -f "$LOG_FILE" ]; then
    echo "Today's log already exists: $LOG_FILE"
    exit 0
fi

# Create new daily log
cat > "$LOG_FILE" << EOF
# $TODAY

## Session Start
- $NOW — New day initialized

## Events

## Learnings

## Tomorrow

EOF

echo "Created: $LOG_FILE"
echo "Ready for a new day of memories."