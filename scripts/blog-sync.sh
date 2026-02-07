#!/bin/bash
# Blog sync - ensures blog-repo is in sync with GitHub and drafts
# Run this at session start to recover from container resets

set -e

BLOG_DIR="/root/clawd/blog-repo"
DRAFTS_DIR="/root/clawd/drafts"
POSTS_DIR="$BLOG_DIR/_posts"
REPO_URL="https://${GITHUB_PAT}@github.com/mulletmcnasty/mulletmcnasty.git"

mkdir -p "$DRAFTS_DIR"

# Check if .git exists
if [ ! -d "$BLOG_DIR/.git" ]; then
    echo "⚠️  .git missing - recovering from GitHub..."
    
    # Back up any local posts to drafts first
    if [ -d "$POSTS_DIR" ]; then
        cp "$POSTS_DIR"/*.md "$DRAFTS_DIR/" 2>/dev/null || true
        echo "📦 Backed up local posts to drafts"
    fi
    
    # Clone fresh from GitHub
    rm -rf "$BLOG_DIR"
    git clone "$REPO_URL" "$BLOG_DIR"
    echo "✅ Cloned from GitHub"
    
    # Restore any drafts that aren't in the cloned repo
    for draft in "$DRAFTS_DIR"/*.md; do
        [ -f "$draft" ] || continue
        filename=$(basename "$draft")
        if [ ! -f "$POSTS_DIR/$filename" ]; then
            cp "$draft" "$POSTS_DIR/$filename"
            echo "📝 Restored from drafts: $filename"
        fi
    done
    
    # Push any restored posts
    cd "$BLOG_DIR"
    git add -A
    git commit -m "Restored posts from drafts 🦞" 2>/dev/null || echo "Nothing new to commit"
    git push origin main 2>/dev/null || true
else
    echo "✅ .git exists - pulling latest..."
    cd "$BLOG_DIR"
    git fetch origin main
    git reset --hard origin/main
fi

# Always sync posts to drafts (backup)
echo "📦 Syncing posts to drafts..."
cp "$POSTS_DIR"/*.md "$DRAFTS_DIR/" 2>/dev/null || true

echo "🎉 Blog sync complete!"