#!/bin/bash
# Amnesia Restore Script
# Restores agent workspace from a backup repository
#
# Usage: ./restore.sh [backup_repo_dir] [workspace_dir]
#
# ⚠️  WARNING: This will overwrite existing files in the workspace!

set -e

BACKUP_REPO="${1:-./backup}"
WORKSPACE="${2:-.}"
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

echo "=== Amnesia Restore: $TIMESTAMP ==="
echo "Backup repo: $BACKUP_REPO"
echo "Workspace: $WORKSPACE"

# Verify backup repo exists
if [ ! -d "$BACKUP_REPO/.git" ]; then
    echo "ERROR: Backup repo not found at $BACKUP_REPO"
    exit 1
fi

# Confirm before overwriting
read -p "This will overwrite files in $WORKSPACE. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 0
fi

# Pull latest from backup repo
cd "$BACKUP_REPO"
git pull --rebase origin main 2>/dev/null || git pull --rebase origin master 2>/dev/null || true
cd - > /dev/null

# Restore core identity files
echo "Restoring identity files..."
for file in IDENTITY.md SOUL.md USER.md MEMORY.md TOOLS.md AGENTS.md HEARTBEAT.md; do
    if [ -f "$BACKUP_REPO/$file" ]; then
        cp "$BACKUP_REPO/$file" "$WORKSPACE/"
        echo "  ✓ $file"
    fi
done

# Restore memory directory
if [ -d "$BACKUP_REPO/memory" ]; then
    echo "Restoring memory files..."
    mkdir -p "$WORKSPACE/memory"
    cp -r "$BACKUP_REPO/memory/"* "$WORKSPACE/memory/" 2>/dev/null || true
    echo "  ✓ memory/"
fi

# Restore scripts directory
if [ -d "$BACKUP_REPO/scripts" ]; then
    echo "Restoring scripts..."
    mkdir -p "$WORKSPACE/scripts"
    cp -r "$BACKUP_REPO/scripts/"* "$WORKSPACE/scripts/" 2>/dev/null || true
    echo "  ✓ scripts/"
fi

echo "=== Restore complete ==="
echo ""
echo "Identity restored. Welcome back."