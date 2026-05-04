---
name: changelog-gen
description: Generate a CHANGELOG entry from git commits between two refs. Groups commits by conventional-commit type (feat/fix/docs/...) and writes Keep-a-Changelog formatted output. Trigger when the user asks to "generate changelog", "update CHANGELOG.md", or "write release notes".
---

# Changelog Generator Skill

## When to invoke
- User says: "generate changelog", "update CHANGELOG.md", "write release notes for v1.2.0", "what changed since last release".

## Process

1. **Determine the range**:
   - If user provides refs (e.g. `v1.1.0..HEAD`), use them.
   - Otherwise run `git describe --tags --abbrev=0` to find the latest tag, use `<tag>..HEAD`.
   - If no tags exist, fall back to the last 50 commits.

2. **Fetch commits**:
   - `git log <range> --pretty=format:"%h|%s|%an" --no-merges`
   - **Dedup before grouping**:
     - Drop **revert pairs**: if `revert: <X>` appears in range AND the original `<X>` commit is also in range → drop both (match by referenced SHA in the revert commit body, fallback to subject match). Net change is zero — don't surface to user.
     - Drop **fixup commits** (`fixup!`, `squash!`) — these are rebase artifacts that should never appear in a user-facing changelog.

3. **Group by conventional-commit prefix** (priority order — Breaking Changes always first):
   - **`BREAKING CHANGE:` footer OR subject suffix `!` (`feat!:`, `fix!:`, ...)** → **⚠️ Breaking Changes** (top of list; NEVER nested under Added/Fixed). Each entry must include: 1-line description + migration hint pulled from commit body if present.
   - `feat:` / `feat(scope):` → **Added**
   - `fix:` → **Fixed**
   - `docs:` → **Documentation**
   - `refactor:` / `perf:` → **Changed**
   - `chore:` / `ci:` / `test:` → **Internal** (collapse if many)
   - Unprefixed commits → **Other** (list as-is)

4. **Write Keep-a-Changelog format** (Breaking Changes always on top — they affect upgrade decisions):
   ```markdown
   ## [<version>] — <YYYY-MM-DD>

   ### ⚠️ Breaking Changes
   - <description> — Migration: <hint from commit body>

   ### Added
   - Short description (commit-hash)

   ### Fixed
   - ...

   ### Changed
   - ...
   ```

   Skip the Breaking Changes section entirely if there are none — don't write an empty header.

5. **Prepend** to existing `CHANGELOG.md` (don't overwrite). If none exists, create one with a standard header.

6. **Ask the user to confirm the version number** before writing — never guess semver bump.

## Hard rules
- Do NOT tag or push — leave release ceremony to the user.
- Do NOT include commit hashes of private/WIP commits if the user specifies a public changelog.
- Preserve existing CHANGELOG entries verbatim.
