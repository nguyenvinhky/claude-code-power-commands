---
name: migration-guide
description: Generate a user-facing migration guide for a major version bump in a library/API/CLI YOU OWN (different from `/migrate` command which plans YOUR codebase upgrade onto a 3rd-party lib). Every breaking change gets before/after code, Why, and codemod link if available. Trigger when user says "write migration guide for v2", "users need to upgrade from vX", "breaking changes doc for the 3.0 release".
---

# Migration Guide Skill

## When to invoke
- "Write migration guide from v1 to v2 of `<our library>`"
- "Doc for users upgrading our API from `/v1` to `/v2`"
- "Breaking changes guide for the 3.0 release"

**NOT for**: planning YOUR codebase migration onto a 3rd-party lib — use `/migrate` command instead. Those two are mirror-image:
- `/migrate` = inward (we're the consumer of someone else's lib)
- `migration-guide` skill = outward (we're the publisher; users need to migrate)

## Process

### Step 1 — Inputs
- **From version → to version** (e.g. `v1.x → v2.0`)
- **Audience**: library users / API consumers / CLI users / SDK callers
- **Source of truth for breaking changes**: changelog, RFC, commit range with `BREAKING CHANGE:` footer

### Step 2 — Categorize each breaking change

| Category | Example | Risk |
|----------|---------|------|
| **Removed** | `oldFunction()` no longer exists | Compile error → easy to find |
| **Renamed** | `getUserById` → `findUser` | Compile error → easy to find |
| **Changed signature** | added required param, changed return type | Compile error → easy to find |
| **Behavioral** | same API, different runtime behavior | **Silent — most dangerous** |
| **Deprecated** | still works in vN, removed in vN+1 | Warning today, error tomorrow |

### Step 3 — For each change, write:
- **Before** code snippet (vN)
- **After** code snippet (vN+1)
- **Why** — one line, gives user context (helps absorb the cost of upgrading)
- **Codemod available?** — link if yes; nothing accelerates adoption like `npx codemod`

### Step 4 — Output structure

```markdown
# Migration Guide: vN → vN+1

`<Product>` vN+1 introduces <X> breaking changes. This guide walks through each with before/after examples.

**TL;DR**: <one sentence — biggest change>

## Estimated effort
- Small project (<5 files using affected APIs): ~30 min
- Medium project: ~half day
- Large project: ~1–2 days

## Breaking Changes (compile-time — easy to find)

### 1. `oldFunction()` removed
**Before (vN)**:
```ts
import { oldFunction } from 'mylib';
oldFunction(arg);
```
**After (vN+1)**:
```ts
import { newFunction } from 'mylib';
newFunction({ arg, mode: 'compat' });
```
**Why**: `oldFunction` was a thin wrapper that hid an important option. Making it explicit prevents bugs.
**Codemod**: `npx mylib-codemod v2/old-to-new`

### 2. ... (repeat per change)

## Behavioral Changes (silent — careful!)

### `useFoo()` now batches updates
**vN**: each call triggered immediate re-render
**vN+1**: calls within the same tick are batched
**Action**: if you relied on intermediate renders, wrap with `flushSync()`
**How to detect in your code**: search for `useFoo` calls inside loops / event handlers

## Deprecations (still works in vN+1, will be removed in vN+2)
- `legacyOption` → use `newOption`
- `Service.start()` → use `Service.boot()`
- Run with `MYLIB_WARN_DEPRECATIONS=1` to see usage in your test runs

## Step-by-step Migration Path

1. **Stay on `vN.last`** (last minor of vN) for one release cycle — exposes deprecation warnings
2. **Run your test suite** — fix every deprecation warning while still on vN
3. **Bump to vN+1**: `npm install mylib@N+1` (or equivalent)
4. **Run codemods**: `npx mylib-codemod v2/all`
5. **Manual fixes** for items not covered by codemods (see sections above)
6. **Run full test suite** — pay extra attention to behavioral-change areas
7. **Smoke test** in staging before production

## Common Pitfalls
- <Specific gotcha 1>
- <Specific gotcha 2>

## Need help?
- Discussion: `<link>`
- Issue tracker: `<link>`
- Discord/Slack: `<link>`
```

### Step 5 — Emphasize codemods where possible
Most users prefer one command over hand-edits. If your project doesn't have codemods yet for any breaking change, suggest writing them — small upfront investment, big adoption payoff.

## Hard rules
- **Every breaking change needs before/after code** — words alone don't help
- **Order by impact** — most-disruptive first; behavioral changes deserve their own section because they bite hardest
- **Honest about behavioral changes** — call them out as "silent" so users know to look extra carefully
- **Don't oversell deprecations as "easy"** — each one is a future breaking change in disguise
- **Pair with `release-notes` skill** for the announcement post (release notes ≠ migration guide; ship both)
- **Don't auto-publish** — migration guides need careful review; wrong steps cost user trust
