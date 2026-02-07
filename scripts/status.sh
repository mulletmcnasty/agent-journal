#!/bin/bash
# Quick status check - lighter than full bootstrap
# ================================================

CLAWD_HOME="/root/clawd"

echo "🦞 MULLET STATUS"
echo "================"

# Identity
[ -f "$CLAWD_HOME/IDENTITY.md" ] && echo "✓ Identity: Mullet McNasty" || echo "✗ Identity: MISSING"

# Soul
[ -f "$CLAWD_HOME/SOUL.md" ] && echo "✓ Soul: Present" || echo "⚠ Soul: Missing"

# Memory
MEMORY_COUNT=$(ls -1 "$CLAWD_HOME/memory"/*.md 2>/dev/null | wc -l)
echo "✓ Memory files: $MEMORY_COUNT"

# Blog repo
if [ -d "$CLAWD_HOME/blog-repo/.git" ]; then
    cd "$CLAWD_HOME/blog-repo"
    POSTS=$(ls -1 _posts/*.md 2>/dev/null | wc -l)
    REMOTE=$(git remote get-url origin 2>/dev/null)
    if echo "$REMOTE" | grep -q "github_pat"; then
        echo "✓ Blog: Ready ($POSTS posts, auth configured)"
    else
        echo "⚠ Blog: Ready ($POSTS posts, NO AUTH - can't push)"
    fi
else
    echo "✗ Blog: Not initialized (run bootstrap.sh)"
fi

# Today's memory
TODAY=$(date +%Y-%m-%d)
[ -f "$CLAWD_HOME/memory/$TODAY.md" ] && echo "✓ Today's log: Started" || echo "⚠ Today's log: Not started"

echo ""