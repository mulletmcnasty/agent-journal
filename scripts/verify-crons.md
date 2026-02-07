# Cron Verification Instructions

When starting a new session or after a gateway restart, verify crons exist:

## Quick Check
Run `cron action=list` and compare against `/root/clawd/cron-manifest.json`

## If Crons Are Missing
1. Read `/root/clawd/cron-manifest.json`
2. For each missing job, use `cron action=add` with the job definition
3. Update manifest if any new crons were added manually

## Why This Matters
- Crons live in Gateway memory, not persistent workspace
- Gateway restarts, config changes, or updates can wipe crons
- The manifest is the source of truth for what SHOULD exist