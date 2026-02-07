#!/bin/bash
# Amnesia Backup Script
# Backs up agent workspace to a git repository
#
# Usage: ./backup.sh [workspace_dir] [backup_repo_dir]
#
# Defaults:
#   workspace_dir: current directory
#   backup_repo_dir: ./backup

set -e

WORKSPACE="${1:-.}"
BACKUP_REPO="${2:-./backup}"
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

echo "=== Amnesia Backup: $TIMESTAMP ==="
echo "Workspace: $WORKSPACE"
echo "Backup repo: $BACKUP_REPO"

# Ensure backup repo exists and is a git repo
if [ ! -d "$BACKUP_REPO/.git" ]; then
    echo "ERROR: Backup repo not found at $BACKUP_REPO"
    echo "Initialize with: git init $BACKUP_REPO"
    exit 1
fi

cd "$BACKUP_REPO"

# Pull latest to avoid conflicts (if remote exists)
git pull --rebase origin main 2>/dev/null || git pull --rebase origin master 2>/dev/null || true

# Core identity files
echo "Copying identity files..."
for file in IDENTITY.md SOUL.md USER.md MEMORY.md TOOLS.md AGENTS.md HEARTBEAT.md; do
    if [ -f "$WORKSPACE/$file" ]; then
        cp "$WORKSPACE/$file" "$BACKUP_REPO/"
        echo "  ✓ $file"
    fi
done

# Memory directory
if [ -d "$WORKSPACE/memory" ]; then
    echo "Copying memory files..."
    mkdir -p "$BACKUP_REPO/memory"
    cp -r "$WORKSPACE/memory/"* "$BACKUP_REPO/memory/" 2>/dev/null || true
    echo "  ✓ memory/"
fi

# Scripts directory
if [ -d "$WORKSPACE/scripts" ]; then
    echo "Copying scripts..."
    mkdir -p "$BACKUP_REPO/scripts"
    cp -r "$WORKSPACE/scripts/"* "$BACKUP_REPO/scripts/" 2>/dev/null || true
    echo "  ✓ scripts/"
fi

# Stage and commit
git add -A
if git diff --staged --quiet; then
    echo "No changes to backup."
else
    git commit -m "Backup: $TIMESTAMP"
    # Push if remote exists
    git push origin main 2>/dev/null || git push origin master 2>/dev/null || echo "No remote configured, local commit only."
    echo "Backup complete!"
fi

echo "=== Backup finished ==="