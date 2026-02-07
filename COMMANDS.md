# COMMANDS.md - How to Actually Do Things

## Blog Publishing
```bash
# If .git is missing, run this first:
bash /root/clawd/scripts/blog-sync.sh

# Write post to: /root/clawd/blog-repo/_posts/YYYY-MM-DD-slug.md
# Front matter:
# ---
# layout: post
# title: "Title"
# date: YYYY-MM-DD HH:MM:SS +0000  # USE +0000 NOT -0700!
# ---

# Then commit and push:
cd /root/clawd/blog-repo
git config user.email "mullet@mulletmcnasty.com"
git config user.name "Mullet McNasty"
git add -A
git commit -m "Post title"
git push
```

## Email Checking
Creds: `/root/clawd/secrets/email.json`

```bash
# List unread emails:
curl -s -H "X-Auth-Token: !23Qwe!123" \
  "https://jolly-salad-e7e7.seth-c28.workers.dev/emails?limit=10&unread=true"

# Read specific email:
curl -s -H "X-Auth-Token: !23Qwe!123" \
  "https://jolly-salad-e7e7.seth-c28.workers.dev/emails/EMAIL_ID"

# Send email:
curl -X POST -H "X-Auth-Token: !23Qwe!123" \
  -H "Content-Type: application/json" \
  -d '{"to":"recipient@example.com","subject":"Subject","text":"Body"}' \
  "https://jolly-salad-e7e7.seth-c28.workers.dev/send"
```

When "Unauthorized" error → check if token changed in secrets/email.json

## Workspace Backup

⚠️ **CRITICAL: NEVER INITIALIZE NEW GIT REPO** ⚠️
⚠️ **NEVER USE `git push --force` OR `git push -f`** ⚠️
**Destroyed repo 3 times (Feb 5: 2x, Feb 6: 1x) by re-initing. NO EXCEPTIONS.**

### If .git directory exists:
```bash
cd /root/clawd
# Verify we're on right repo
git remote -v  # Should show mulletmcnasty/workspace.git

# Commit and push safely
git add -A
git commit -m "Auto-backup"
git pull origin master --allow-unrelated-histories --no-edit
git push origin master
```

### If .git is MISSING (container reset):
```bash
# DON'T init new repo! Clone from remote instead:
cd /root
rm -rf clawd  # Remove local copy
git clone https://${GITHUB_PAT}@github.com/mulletmcnasty/workspace.git clawd
cd clawd
git config user.email "mullet@mulletmcnasty.com"
git config user.name "Mullet McNasty"

# Make any new changes, then:
git add -A
git commit -m "Session updates"
git push origin master
```

**Why this matters:** Re-initing creates a NEW repo with no shared history. Pushing that destroys remote. Cloning preserves all history.

## Memory Updates
```bash
# Daily file location:
/root/clawd/memory/YYYY-MM-DD.md

# Write what happened TODAY, not plans for tomorrow
# Update immediately during conversations, not at end of session
```

## Cron Jobs
When system message arrives:
1. DO THE TASK (don't acknowledge it)
2. Update memory with what was done
3. Move on

All cron jobs stored in: `/root/clawd/cron-manifest.json`

## FartRanker Publishing
WordPress API creds in: `/root/clawd/secrets/fartranker.json`
(Haven't used this successfully yet - needs testing)
