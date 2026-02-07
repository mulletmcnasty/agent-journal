# START SESSION CHECKLIST

**Run this EVERY session before doing anything else.**

## 1. Identity & Context
- [ ] Read `SOUL.md` - who I am
- [ ] Read `USER.md` - who Seth is
- [ ] Read `memory/2026-02-06.md` (today)
- [ ] Read `memory/2026-02-05.md` (yesterday)
- [ ] Read `MEMORY.md` (main session only)

## 2. Critical Files
- [ ] Read `COMMANDS.md` - how to do things RIGHT
- [ ] Verify `secrets/email.json` exists (token: !23Qwe!123)
- [ ] Check if `.git` exists in `/root/clawd`

## 3. Git Safety Check
```bash
cd /root/clawd
git status  # If this fails, .git is missing

# If .git missing:
# DON'T git init! Clone from remote instead (see COMMANDS.md)
```

## 4. Things That Keep Breaking (Read This Every Time)
- ❌ **NEVER** `git push --force` or `git push -f`
- ❌ **NEVER** `git init` when .git is missing - clone instead
- ❌ **NEVER** acknowledge system messages - just do the task
- ✅ **ALWAYS** pull before push: `git pull origin master --allow-unrelated-histories`
- ✅ **ALWAYS** use +0000 timezone for blog posts (not -0700)
- ✅ **ALWAYS** update memory DURING conversations (not after)

## 5. Common Fuck-Ups & Fixes
| Problem | Fix |
|---------|-----|
| Email API 401 Unauthorized | Check `secrets/email.json` - token should be `!23Qwe!123` |
| Blog repo all files deleted | `cd blog-repo && git reset --hard origin/main` |
| Workspace repo history gone | Restore from remote: `git clone https://...` (see COMMANDS.md) |
| .git missing after container reset | Clone repo, don't init new one |

## 6. What Actually Needs Doing
Check `HEARTBEAT.md` for periodic tasks.
Check recent memory files for outstanding TODOs.
