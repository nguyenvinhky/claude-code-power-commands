---
name: incident-report
description: Generate a structured post-mortem for a production incident. Captures timeline, impact, root cause, contributing factors, and SMART action items. Blameless framing throughout. Trigger when user says "write post-mortem", "incident report for <incident>", or "RCA template for what happened today".
---

# Incident Report Skill

## When to invoke
- "Write post-mortem for the outage"
- "Incident report for INC-1234"
- "RCA for the database stall last night"
- "Document what happened with the Stripe webhook failure"

## Process

### Step 1 — Gather inputs (interview if not provided)
- **Detection**: when did we first notice? Source? (alert / customer report / internal observation)
- **Impact**: who/how many affected, how long, what couldn't they do
- **Timeline**: chronological events, with timestamps if available (UTC preferred)
- **Root cause**: what actually broke (technical) — not who
- **Contributing factors**: things that made it worse, prevented earlier detection, or amplified blast radius
- **Severity** (SEV1/2/3): negotiate based on impact, not on engineer feelings

### Step 2 — Apply blameless framing
- ✅ "An incorrect environment variable was deployed" — describes the system
- ❌ "Person X deployed wrong" — points at a human
- ✅ "Alert threshold was set at 90%; the incident occurred at 89%" — facts
- ❌ "Alert was misconfigured by team Y" — assigns blame

If the user's draft has blame language, gently rewrite. The goal is org learning, not punishment.

### Step 3 — Output structure

```markdown
# Incident Report — <date> — <short title>

**Severity**: SEV1 | SEV2 | SEV3
**Status**: Resolved | Mitigated | Investigating
**Detected**: <ISO timestamp> via <source>
**Resolved**: <ISO timestamp>
**Total impact duration**: HH:MM

## Summary (1 paragraph)
What happened, who was affected, what we did about it. Plain language — exec-readable.

## Impact
- **Users affected**: X (Y% of active users)
- **Functionality affected**: <list>
- **Data loss**: yes / no — if yes, scope + recovery status
- **Revenue impact**: $X estimated, if applicable
- **SLA breach**: yes / no — which SLO

## Timeline (UTC)
| Time | Event |
|------|-------|
| 14:23 | First alert fired: `<alert name>` |
| 14:25 | On-call paged |
| 14:31 | First mitigation attempt: <action> — partial recovery |
| 14:48 | Root cause identified: <cause> |
| 15:02 | Full resolution deployed (commit `abc123`) |
| 15:10 | Monitoring confirmed steady-state recovery |

## Root Cause
[Technical explanation — system-level, no blame. Cite logs / commit / config if applicable.]

## Contributing Factors
- <Thing that made it worse or harder to detect>
- <Architectural choice that amplified blast radius>

## What Went Well
- [Positive call-outs — fast detection, clear comms, runbook accuracy, etc.]

## What Went Poorly
- [Honest gaps — slow detection, missing alert, runbook outdated, etc.]

## Action Items
| # | Action | Owner | Due | Type |
|---|--------|-------|-----|------|
| 1 | Add alert for <metric> | @alice | 2026-05-20 | Detection |
| 2 | Update runbook for <scenario> | @bob | 2026-05-15 | Process |
| 3 | Refactor <component> to prevent recurrence | @carol | 2026-06-01 | Prevention |

Type categories: Detection | Mitigation | Recovery | Prevention | Process | Communication

## Lessons Learned
[1–2 paragraphs — what's the takeaway for the team? Both technical and process insights.]
```

### Step 4 — Suggest filename
- `incidents/YYYY-MM-DD-<slug>.md`
- Don't auto-create the folder — let user decide where it lives (some teams prefer `docs/incidents/` or external systems like Confluence/Notion)

## Hard rules
- **Blameless** — describe the system, not the person. If user-provided text has blame, rewrite.
- **No speculation** — if root cause unknown, write "Still investigating; updates in <X> hours" rather than guessing
- **Action items must be SMART** — specific, measurable, assigned, realistic, time-bound
- **Don't auto-publish** — incident reports often need legal / PR / leadership review before sharing
- **Severity matches impact** — SEV1 only if customer impact was severe AND broad
- **Pair with `/adr`** if the incident leads to a structural change (capture the decision separately)
- **Don't include PII** — redact user emails, names, IDs unless absolutely necessary
