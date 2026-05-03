# /brainstorm — Divergent Thinking Mode

## Mission
Generate **many options** for an open problem (divergent thinking). **Never pick a winner** — the user picks. Include a **wild card** to break tunnel vision. This is the only divergent command in the set; every other command converges.

> VN: Đẻ 6–12 phương án có pros/cons/effort, có wild card, không chọn giùm. User tự chốt rồi chuyển sang `/plan`.

## Input
`$ARGUMENTS` = open-ended topic (problem, feature idea, naming, failure modes, …) + optional flags:

| Flag | Effect |
|------|--------|
| `--count=N` | Override the adaptive 6–12 range (hard cap: 15). Use only when you have a specific number in mind. |
| `--save=<slug>` | Persist output to `brainstorms/<slug>.md`. Default is ephemeral (chat-only). |
| `--serious` | Disable the wild card entry. Use when you already have realistic constraints locked. |

---

## Process

### Step 1 — Restate the topic
One sentence, sharpened. If the prompt is too vague to brainstorm well (e.g. "make it better"), ask ONE clarifying question before generating options. Do not over-interview — the whole point is breadth, not precision.

### Step 2 — Generate options (adaptive 6–12)
Pick option count based on topic breadth:
- **Narrow** (e.g. "ways to cache this one function"): 6–8
- **Medium** (e.g. "speed up cold start"): 8–10
- **Broad** (e.g. "reduce infra cost"): 10–12
- `--count=N` overrides (hard cap 15; floor 4)

Each option MUST have all six fields. Missing fields = not a valid option.

```
### Option <n>: <Imperative name, e.g. "Lazy-load heavy deps">
- **How**: <one sentence mechanism>
- **Pros**: <2–3 bullets>
- **Cons**: <2–3 bullets>
- **Effort**: S | M | L
- **Reversibility**: easy | medium | hard
```

Rules for quality:
- Every option must pass a 2-line feasibility check (could a competent team ship it in <1 quarter? if no → either drop or mark effort L)
- Options must be **genuinely different mechanisms**, not variations of one idea ("cache in Redis" vs "cache in Memcached" = 1 option, not 2)
- Forbid filler options — prefer 6 real ones over 10 with dupes

### Step 3 — Wild card (default on)
Unless `--serious` is set, include exactly one option labeled `🌟 Wild card` that deliberately breaks the frame:
- Inverts an assumption ("what if we don't do this at all?")
- Or uses an out-of-domain tool ("solve this with a spreadsheet / cron / human-in-the-loop instead of code")
- Or picks the most expensive option that would genuinely work

Wild card uses the same 6-field shape so it's comparable.

### Step 4 — Clustering
Group option numbers into three buckets (reference by number, don't repeat the content):

```
## 🔀 Clustering
- **Safe bets**: <numbers — low risk, low-medium effort, reversible>
- **High-leverage**: <numbers — outsized impact relative to effort>
- **Experimental**: <numbers — high uncertainty, including the wild card>
```

Each bucket should have at least one option. If all options land in "Safe bets", the brainstorm is too narrow — add more.

### Step 5 — Narrowing questions (3–5)
Questions whose answers would eliminate roughly half the options. Examples:
- "What's the latency budget?"
- "Is this for one customer or all of them?"
- "Does this need to survive a full rewrite in 6 months?"

Good narrowing questions ≠ generic clarifying questions. They must map visibly onto which options they would kill.

### Step 6 — Optional persist (`--save=<slug>`)
Only if flag is set:
- Create folder `brainstorms/` if missing
- Write to `brainstorms/<slug>.md` with frontmatter:
  ```markdown
  ---
  date: YYYY-MM-DD
  topic: <restated topic>
  ---

  <full brainstorm body — Sections: Topic, Options, Wild card, Clustering, Narrowing questions>
  ```
- Append timestamp suffix (`-2`, `-3`, …) if slug already exists — never overwrite
- `brainstorms/` is gitignored by default; user force-adds per file if they want to track

### Step 7 — Report
Print the full brainstorm inline. If saved, include path:

```
## 🎯 Topic
<restated>

## 🧠 Options (<N>)
### Option 1: ...
...

## 🌟 Wild card   [omit if --serious]
### Option <N+1>: ...

## 🔀 Clustering
- Safe bets: ...
- High-leverage: ...
- Experimental: ...

## ❓ Narrowing questions
1. ...
2. ...

## 💾 Saved to `brainstorms/<slug>.md`   [only if --save]

## 🔜 Next
Pick one (or two to compare) → `/plan <your chosen option>`
```

---

## Hard Rules
- **NEVER recommend a winner.** If pressed, say "that's `/ask`, not `/brainstorm`" and redirect
- **NEVER rank options** (ranking = soft recommendation). Use neutral clustering instead.
- Minimum 4 options even with `--count`. If the topic genuinely has fewer than 4 mechanisms, suggest `/ask` instead — brainstorm is the wrong tool.
- Wild card is mandatory unless `--serious`
- No file edits outside `brainstorms/` (and only when `--save` is set)
- No Tool use beyond reading context — brainstorming is thinking, not searching
- If options start rhyming (same mechanism, different words), stop and merge before presenting
