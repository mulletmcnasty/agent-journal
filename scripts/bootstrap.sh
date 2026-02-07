#!/bin/bash
# ============================================================
# MULLET MCNASTY BOOTSTRAP SCRIPT v2
# "From amnesia to operational in 60 seconds"
# ============================================================
# 
# Run this after a sandbox reset to restore full functionality.
# Requires: GITHUB_PAT env var (or will prompt)
#
# What it does:
#   1. Installs dependencies (gh CLI)
#   2. Authenticates GitHub
#   3. Clones/updates blog-repo with push access
#   4. Clones/updates workspace-backup
#   5. Syncs local workspace from backup if stale
#   6. Runs self-check
# ============================================================

set -e

CLAWD_HOME="/root/clawd"
BLOG_REPO_NAME="sethshoultes/mulletmcnasty"
WORKSPACE_REPO_NAME="mulletmcnasty/workspace"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }
info() { echo -e "${CYAN}→${NC} $1"; }

echo ""
echo "🦞 MULLET MCNASTY BOOTSTRAP v2"
echo "Business in the front, party in the back."
echo "============================================"
echo ""

# ------------------------------------------------------------
# 0. GITHUB PATS
# ------------------------------------------------------------
# BLOG_PAT = sethshoultes account (for blog-repo)
# WORKSPACE_PAT = mulletmcnasty account (for workspace backup)

if [ -z "$BLOG_PAT" ]; then
    # Try to extract from existing blog-repo remote
    if [ -d "$CLAWD_HOME/blog-repo/.git" ]; then
        BLOG_PAT=$(cd "$CLAWD_HOME/blog-repo" && git remote get-url origin 2>/dev/null | grep -oP 'github_pat_[^@]+' || true)
    fi
fi

if [ -z "$WORKSPACE_PAT" ]; then
    # Try to extract from existing workspace-backup remote
    if [ -d "$CLAWD_HOME/workspace-backup/.git" ]; then
        WORKSPACE_PAT=$(cd "$CLAWD_HOME/workspace-backup" && git remote get-url origin 2>/dev/null | grep -oP 'ghp_[^@]+' || true)
    fi
fi

# Fallback to GITHUB_PAT for backwards compat
BLOG_PAT="${BLOG_PAT:-$GITHUB_PAT}"
WORKSPACE_PAT="${WORKSPACE_PAT:-$GITHUB_PAT}"

if [ -z "$BLOG_PAT" ]; then
    fail "BLOG_PAT not set and couldn't extract from existing repo"
    exit 1
fi

success "GitHub PATs available"

# ------------------------------------------------------------
# 1. INSTALL DEPENDENCIES
# ------------------------------------------------------------
echo ""
echo "📦 Phase 1: Dependencies"

if command -v gh &> /dev/null; then
    success "gh CLI already installed"
else
    info "Installing gh CLI..."
    apt-get update -qq && apt-get install -y gh -qq
    success "gh CLI installed"
fi

# ------------------------------------------------------------
# 2. AUTHENTICATE GITHUB
# ------------------------------------------------------------
echo ""
echo "🔐 Phase 2: GitHub Authentication"

if gh auth status &>/dev/null; then
    GH_USER=$(gh api /user --jq '.login' 2>/dev/null || echo "unknown")
    success "Already authenticated as $GH_USER"
else
    info "Authenticating..."
    echo "$BLOG_PAT" | gh auth login --with-token
    success "Authenticated with GitHub"
fi

# ------------------------------------------------------------
# 3. BLOG REPOSITORY
# ------------------------------------------------------------
echo ""
echo "📝 Phase 3: Blog Repository"

BLOG_DIR="$CLAWD_HOME/blog-repo"
BLOG_URL="https://${BLOG_PAT}@github.com/${BLOG_REPO_NAME}.git"

if [ -d "$BLOG_DIR/.git" ]; then
    # Check if remote has auth
    CURRENT_REMOTE=$(cd "$BLOG_DIR" && git remote get-url origin 2>/dev/null)
    if echo "$CURRENT_REMOTE" | grep -q "github_pat"; then
        success "blog-repo exists with auth"
    else
        info "Updating remote with auth..."
        cd "$BLOG_DIR" && git remote set-url origin "$BLOG_URL"
        success "blog-repo remote updated with auth"
    fi
    cd "$BLOG_DIR" && git fetch origin -q && git pull -q 2>/dev/null || true
    success "blog-repo synced"
else
    if [ -d "$BLOG_DIR" ]; then
        warn "blog-repo exists but no .git - removing"
        rm -rf "$BLOG_DIR"
    fi
    info "Cloning blog-repo..."
    git clone -q "$BLOG_URL" "$BLOG_DIR"
    success "blog-repo cloned"
fi

POST_COUNT=$(ls -1 "$BLOG_DIR/_posts"/*.md 2>/dev/null | wc -l)
LATEST_POST=$(cd "$BLOG_DIR" && git log --oneline -1 2>/dev/null || echo "unknown")
info "Posts: $POST_COUNT | Latest: $LATEST_POST"

# ------------------------------------------------------------
# 4. WORKSPACE BACKUP REPOSITORY
# ------------------------------------------------------------
echo ""
echo "💾 Phase 4: Workspace Backup"

WORKSPACE_DIR="$CLAWD_HOME/workspace-backup"
WORKSPACE_URL="https://${WORKSPACE_PAT}@github.com/${WORKSPACE_REPO_NAME}.git"

# Check if workspace repo exists on GitHub
if gh repo view "$WORKSPACE_REPO_NAME" &>/dev/null; then
    if [ -d "$WORKSPACE_DIR/.git" ]; then
        cd "$WORKSPACE_DIR" && git fetch origin -q && git pull -q 2>/dev/null || true
        success "workspace-backup synced"
    else
        if [ -d "$WORKSPACE_DIR" ]; then
            rm -rf "$WORKSPACE_DIR"
        fi
        info "Cloning workspace-backup..."
        git clone -q "$WORKSPACE_URL" "$WORKSPACE_DIR"
        success "workspace-backup cloned"
    fi
    
    # Check if we need to restore from backup
    LOCAL_MEMORY_COUNT=$(ls -1 "$CLAWD_HOME/memory"/*.md 2>/dev/null | wc -l || echo 0)
    BACKUP_MEMORY_COUNT=$(ls -1 "$WORKSPACE_DIR/memory"/*.md 2>/dev/null | wc -l || echo 0)
    
    if [ "$BACKUP_MEMORY_COUNT" -gt "$LOCAL_MEMORY_COUNT" ]; then
        warn "Backup has more memory files ($BACKUP_MEMORY_COUNT vs $LOCAL_MEMORY_COUNT)"
        info "Restoring from backup..."
    fi
    
    # Always sync these critical files/dirs from backup
    info "Syncing from backup..."
    
    # Core files
    for f in MEMORY.md IDENTITY.md SOUL.md USER.md TOOLS.md HEARTBEAT.md AGENTS.md fartranker-content-calendar.md; do
        [ -f "$WORKSPACE_DIR/$f" ] && cp "$WORKSPACE_DIR/$f" "$CLAWD_HOME/"
    done
    
    # Directories
    for d in memory scripts skills secrets; do
        if [ -d "$WORKSPACE_DIR/$d" ]; then
            mkdir -p "$CLAWD_HOME/$d"
            cp -r "$WORKSPACE_DIR/$d"/* "$CLAWD_HOME/$d/" 2>/dev/null || true
        fi
    done
    
    success "Synced from backup"
else
    warn "Workspace repo doesn't exist yet"
    echo "  Create it: gh repo create $WORKSPACE_REPO_NAME --private"
fi

# ------------------------------------------------------------
# 5. IDENTITY CHECK
# ------------------------------------------------------------
echo ""
echo "📋 Phase 5: Identity Verification"

[ -f "$CLAWD_HOME/IDENTITY.md" ] && success "IDENTITY.md exists" || fail "IDENTITY.md missing!"
[ -f "$CLAWD_HOME/SOUL.md" ] && success "SOUL.md exists" || warn "SOUL.md missing"
[ -f "$CLAWD_HOME/USER.md" ] && success "USER.md exists" || warn "USER.md missing"
[ -f "$CLAWD_HOME/MEMORY.md" ] && success "MEMORY.md exists" || warn "MEMORY.md missing"

# Memory directory
mkdir -p "$CLAWD_HOME/memory"
MEMORY_COUNT=$(ls -1 "$CLAWD_HOME/memory"/*.md 2>/dev/null | wc -l)
success "memory/ directory ($MEMORY_COUNT daily files)"

# Scripts directory
mkdir -p "$CLAWD_HOME/scripts"
success "scripts/ directory exists"

# ------------------------------------------------------------
# 6. SUMMARY
# ------------------------------------------------------------
echo ""
echo "============================================"
echo "🦞 BOOTSTRAP COMPLETE"
echo ""
echo "Status:"
echo "  • Identity: Mullet McNasty"
echo "  • Blog: $POST_COUNT posts, push-ready"
echo "  • Memory: $MEMORY_COUNT daily files"
echo "  • gh CLI: $(gh auth status 2>&1 | grep -oP 'Logged in to github.com as \K\w+' || echo 'ready')"
echo ""
echo "Next steps:"
echo "  1. Read IDENTITY.md, SOUL.md, USER.md"
echo "  2. Read memory/$(date +%Y-%m-%d).md (today)"
echo "  3. Check MEMORY.md for long-term context"
echo "  4. Run 'cron list' for scheduled jobs"
echo ""
echo "Business in the front, party in the back. 🦞"