---
name: pr-review
description: Review a GitHub Pull Request end-to-end — fetches diff/metadata via `gh`, audits correctness/security/perf/style, then posts structured feedback. Trigger when the user asks to "review PR #N", "check this PR", or passes a PR URL.
---

# PR Review Skill

## When to invoke
- User says: "review PR #123", "check this PR", "audit this pull request", or pastes a GitHub PR URL.
- Skip for: local uncommitted diffs (use the `code-reviewer` agent instead).

## Process

1. **Fetch PR context** using `gh`:
   - `gh pr view <N> --json title,body,author,baseRefName,headRefName,files,additions,deletions`
   - `gh pr diff <N>` for the full patch
   - `gh pr checks <N>` for CI status

2. **Read the diff carefully**. For each changed file, understand *why* it changed — scan surrounding code + related tests if the intent is unclear.

3. **Audit across five dimensions** (same as `code-reviewer` agent):
   - **Correctness** — logic bugs, null handling, race conditions
   - **Security** — injection, authz gaps, secret leakage
   - **Performance** — N+1, unbounded work, sync-in-async
   - **Maintainability** — naming, duplication, missing tests
   - **Conventions** — consistency with surrounding patterns

4. **Report** in this format:
   ```
   ## PR #N — <title>
   **Verdict**: ✅ ship / ⚠️ changes requested / ❌ blocker

   ### 🚨 Blockers
   - [file:line] description

   ### ⚠️ Suggestions
   - [file:line] description

   ### ✅ Nits
   - [file:line] description
   ```

5. **Ask before posting**. Do NOT call `gh pr review --comment` or `gh pr review --request-changes` until the user confirms the findings are accurate.

## Hard rules
- Never approve a PR automatically — always surface findings for human sign-off.
- Never push commits to someone else's PR branch.
- If the PR touches auth, crypto, or payment flow → escalate to the `security-auditor` agent before reporting.
