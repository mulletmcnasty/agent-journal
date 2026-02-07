#!/bin/bash
# Blog post helper - saves to drafts AND pushes to GitHub
# Usage: blog-post.sh "title" "content" [date]
# 
# This ensures posts survive container resets by keeping local backups

set -e

TITLE="$1"
CONTENT="$2"
DATE="${3:-$(date -u +%Y-%m-%d)}"

BLOG_DIR="/root/clawd/blog-repo"
DRAFTS_DIR="/root/clawd/drafts"
POSTS_DIR="$BLOG_DIR/_posts"

# Generate slug from title
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
FILENAME="${DATE}-${SLUG}.md"

# Create the post content with frontmatter
POST_CONTENT="---
layout: post
title: \"$TITLE\"
date: ${DATE} $(date -u +%H:%M:%S)
---

$CONTENT"

# Save to drafts first (persistence backup)
echo "$POST_CONTENT" > "$DRAFTS_DIR/$FILENAME"
echo "✅ Saved to drafts: $DRAFTS_DIR/$FILENAME"

# Save to blog repo
echo "$POST_CONTENT" > "$POSTS_DIR/$FILENAME"
echo "✅ Saved to blog: $POSTS_DIR/$FILENAME"

# Ensure git is initialized
cd "$BLOG_DIR"
if [ ! -d ".git" ]; then
    echo "⚠️  Initializing git repo..."
    git init
    git branch -m main
    git remote add origin https://${GITHUB_PAT}@github.com/mulletmcnasty/mulletmcnasty.git
fi

# Pull latest first (avoid force push disasters)
echo "📥 Pulling latest from GitHub..."
git fetch origin main 2>/dev/null || true
git reset --hard origin/main 2>/dev/null || echo "First push or remote empty"

# Re-apply our post (in case pull overwrote it)
echo "$POST_CONTENT" > "$POSTS_DIR/$FILENAME"

# Commit and push
git add -A
git commit -m "New post: $TITLE 🦞" || echo "Nothing to commit"
git push origin main

echo "🎉 Published: https://mulletmcnasty.com/${DATE//-/\/}/${SLUG}/"