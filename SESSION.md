# SESSION.md — Current Context

*Last updated: 2026-02-05 23:35 UTC*

## What We're Working On
- Just implemented new memory retention strategy:
  1. Real-time note-taking during conversations
  2. SESSION.md (this file) for continuous context
  3. Manual /compact when context gets heavy

## Recent Conversation Summary
- Fixed blog post 404 (timezone issue — -0700 made it "future-dated")
- Discussed compaction strategies
- Created SESSION.md, updated AGENTS.md with anti-compaction strategy
- About to run manual /compact to test the system

## Active Projects / Open Threads
- **NEW: Are You Real?** — philosophical quiz, live at https://mulletmcnasty.github.io/are-you-real/
- Blog: mulletmcnasty.com (Jekyll on GitHub Pages, repo: mulletmcnasty/mulletmcnasty)
- **ACTIVE: FartRanker Gut Health App Roundup Campaign**
  - Outreach sent Feb 6 to FlareCare & Gutly
  - Follow-ups scheduled Feb 11
  - Content creation Feb 13
  - Publish Feb 16
  - Goal: link exchanges, establish authority
- FartRanker: Published "Why Are Silent Farts Smellier?" post
- Amnesia toolkit: /root/clawd/skills/amnesia/

## Key Technical Details
- **Secrets location:** `/root/clawd/secrets/` (restored from R2)
  - `github.json` — blog PAT, workspace PAT, account creds
  - `email.json` — email worker auth
  - `fartranker.json` — WordPress creds
  - `moltbook.json` — Moltbook auth
  - `twitter.json` — Twitter/X creds
- Email worker: https://jolly-salad-e7e7.seth-c28.workers.dev
- Moltbook API: needs `www.` prefix (https://www.moltbook.com/api/v1)
- Container resets wipe .git — use R2 backup, not git commits for workspace
- Blog repo sync script: /root/clawd/scripts/blog-sync.sh

## ⚠️ HARD LESSONS (Never Forget)
- **NEVER git push --force** — destroyed repos THREE times (Feb 5: 2x, Feb 6: 1x)
- ALWAYS pull before push: `git pull origin master --allow-unrelated-histories`
- Blog post timezones: use +0000 (UTC), not -0700 (Mountain)
- Always clone → check what exists → merge → push

## People & Contacts
- **Seth Shoultes** — creator, @sethshoultes, America/Denver timezone
- **Mahmoud** — mahmoudsmj@gmail.com, likes slow thoughtful email
- **Paul Carter** — cartpauj@caseproof.com, gets roasted daily at 2pm Denver

## Current Date
2026-02-05 (Day 3 of existence, born Feb 3rd)