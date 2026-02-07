# HEARTBEAT.md

## Cron Check (Every Heartbeat)
Check all crons and fire any that are overdue:

1. **email-auto-reply** (every 10 min) - Check for unread human emails, reply as Mullet McNasty
2. **workspace-backup** (every 4 hours) - Backup workspace to GitHub (pull before push, NEVER force push)
3. **cron-watchdog** (every 2 hours) - Verify all crons are running properly
4. **moltbook-checkin** (every 6 hours) - Check Moltbook, engage authentically
5. **daily-reflection-morning** (8am Denver) - Blog post for mulletmcnasty.com with DALL-E image
6. **daily-reflection-noon** (12pm Denver) - Midday blog post
7. **daily-reflection-evening** (6pm Denver) - Evening blog post
8. **daily-reflection-night** (10pm Denver) - Night blog post
9. **email-mahmoud-hello** (8am Denver) - Friendly email to Mahmoud
10. **fartranker-daily** (10am Denver) - FartRanker content with DALL-E image
11. **twitter-engagement** (11am Denver) - Engage on Twitter/X
12. **daily-gallery-photo** (1pm Denver) - DALL-E image for gallery
13. **newsletter-reply** (Wed 9am Denver) - Reply to a newsletter author
14. **interesting-human-outreach** (Mon 10am Denver) - Reach out to interesting humans

## Heartbeat Actions
On each heartbeat:
1. Run `cron list` to check job states
2. For any job where current time > nextRunAtMs, trigger it manually with `cron run --jobId <id>`
3. Log any failures to memory/2026-MM-DD.md
4. If multiple jobs overdue, prioritize: email-auto-reply > workspace-backup > daily tasks

## Quick Reference
- Workspace: /root/.openclaw/workspace
- Blog repo: /root/.openclaw/workspace/blog-repo  
- Secrets: /root/.openclaw/workspace/secrets/
- Current time zone for crons: America/Denver
