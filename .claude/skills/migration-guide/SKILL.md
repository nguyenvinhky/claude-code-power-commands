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

1. **Stay on `vN.last`** (last minor of vN) for one release cycle.
   ✅ Verify: deprecation warnings appear in `npm test` output.
2. **Fix every deprecation warning** while still on vN.
   ✅ Verify: `npm test` clean, no deprecation noise.
3. **Bump to vN+1**: `npm install mylib@N+1` (or equivalent).
   ✅ Verify: install succeeds, lockfile updated.
4. **Run codemods**: `npx mylib-codemod v2/all`.
   ✅ Verify: `git diff` shows expected mechanical changes only; no stray edits.
5. **Manual fixes** for items not covered by codemods (see sections above).
   ✅ Verify: `npm test` green; specifically run tests in behavioral-change areas.
6. **Smoke test in staging** — critical user flows end-to-end.
   ✅ Verify: every flow works before production.
7. **Production deploy** with rollback ready (see Rollback Plan below).
   ✅ Verify: `<key metric>` stable for 30+ minutes post-deploy.

⚠️ **Stop at first failed verify** — do NOT skip ahead. Fix the failure or rollback before continuing.

## Rollback Plan

If migration breaks production at any phase, revert with:

1. **Code rollback**: `git revert <migration-commit-range>` OR `npm install <product>@<previous-version>` (or equivalent for your package manager).
2. **Schema rollback** (if DB migrations were part of this): run the down-migration `<command>`. Test in staging first if data shape changed.
3. **Cache invalidation**: clear `<which caches>` so app doesn't keep stale state pointing at the new schema.
4. **Monitoring**: watch `<key metric>` for 30 minutes post-rollback to confirm stable.

**Pre-condition for safe rollback**: backups taken at step `<N>` of the migration path. If you skipped backups → rollback may lose data; manual recovery needed.

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

## Hard Rules
- **Every breaking change needs before/after code** — words alone don't help
- **Order by impact** — most-disruptive first; behavioral changes deserve their own section because they bite hardest
- **Honest about behavioral changes** — call them out as "silent" so users know to look extra carefully
- **Don't oversell deprecations as "easy"** — each one is a future breaking change in disguise
- **Pair with `release-notes` skill** for the announcement post (release notes ≠ migration guide; ship both)
- **Don't auto-publish** — migration guides need careful review; wrong steps cost user trust
