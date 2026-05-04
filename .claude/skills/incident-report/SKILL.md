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
- **Severity** (SEV1/2/3) — match by highest threshold hit:
  - **SEV1**: >50% active users affected, OR data loss, OR security breach, OR revenue-blocking
  - **SEV2**: 10–50% users affected with workaround available, OR major feature down, OR SLA breach risk
  - **SEV3**: <10% users OR internal-only OR cosmetic
  Pick the highest match. Negotiate down only with explicit reasoning, not on engineer feelings.

### Step 2 — Apply blameless framing
- ✅ "An incorrect environment variable was deployed" — describes the system
- ❌ "Person X deployed wrong" — points at a human
- ✅ "Alert threshold was set at 90%; the incident occurred at 89%" — facts
- ❌ "Alert was misconfigured by team Y" — assigns blame

If the user's draft has blame language, gently rewrite. The goal is org learning, not punishment.

### Step 2.5 — If status is "Investigating" or "Mitigated" (ongoing incident)

Use the **LIVE** template below — shorter, written for frequent updates. Don't fill Root Cause / Action Items / What Went Well|Poorly until the incident is resolved (promote to the full Resolved template at that point).

```markdown
# Incident Report — <date> — <title> [LIVE]

**Severity**: SEV<N> (initial — may revise)
**Status**: Investigating | Mitigated
**Detected**: <ISO timestamp> via <source>
**Current state**: <one sentence — what's broken right now>
**Mitigation in progress**: <action being taken / who is on it>
**Next update**: in <minutes/hours>

## Updates (newest first)
- HH:MM — <update>
- HH:MM — <previous update>
```

When the incident resolves → switch to the full template in Step 3 below; carry over Detected / Updates / Mitigation history into the Timeline.

### Step 3 — Output structure (Resolved incidents)

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
| # | Action | Owner | Due | Type | Status |
|---|--------|-------|-----|------|--------|
| 1 | Add alert for <metric> | @alice | 2026-05-20 | Detection | Open |
| 2 | Update runbook for <scenario> | @bob | 2026-05-15 | Process | Open |
| 3 | Refactor <component> to prevent recurrence | @carol | 2026-06-01 | Prevention | Open |

Type categories: Detection | Mitigation | Recovery | Prevention | Process | Communication
Status enum: Open | In progress | Done | Cancelled. **Update status as items complete** — the post-mortem is a live document, not write-once. Stale "Open" items 6 months later signal lessons not learned.

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
- **Customer-facing comms** (status page, customer email, social posts) is a **separate artifact** — don't merge into the post-mortem. This skill produces internal RCA only; user-facing comms typically need PR/legal review and use a different tone
