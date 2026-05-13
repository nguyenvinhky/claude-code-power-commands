---
name: release-notes
description: Generate user-facing release notes for a version (different from `changelog-gen` — this is for blog/email/announcement, focused on user value not commit list). Trigger when user asks "release notes for vX", "announcement post for the release", "what to tell users about this update".
---

# Release Notes Skill

## When to invoke
- "Release notes for v1.2.0"
- "Write announcement for this release"
- "Customer-facing changelog"
- "Email update for the launch"

**NOT for**: internal `CHANGELOG.md` — use `changelog-gen` skill instead. The two are siblings: `changelog-gen` is comprehensive + technical; `release-notes` is selective + customer-framed.

## Process

1. **Fetch range**:
   - User-provided refs, OR `git log <last-tag>..HEAD`
   - If multiple feature branches merged in this range → think in terms of features, not commits

2. **Filter for user-facing changes**:
   - Keep: `feat:`, user-affecting `fix:`, `perf:` improvements users will notice
   - Drop: `chore:`, `refactor:`, `test:`, `ci:`, internal-only `fix:` (typo in tests, etc.), `docs:` (unless docs-as-product)
   - When in doubt: "would a user notice if this didn't exist?" — if no, drop

3. **Reframe each entry** (this is the value):
   - `feat: add OAuth login` → "**Sign in with Google or GitHub** — no more password hassle"
   - `fix: dashboard slow render` → "Dashboard loads 3x faster"
   - `perf: reduce bundle size by 40%` → "Page load is noticeably snappier"

   Pattern: **What the user sees** — why they care (1 line).

4. **Output 3 sections** (skip empty):
   ```markdown
   # <Product> v<X.Y.Z>

   ## ✨ New
   - **<Feature in title case>** — one-line user benefit

   ## 🚀 Improved
   - <Concrete improvement, with number if available>

   ## 🐛 Fixed
   - <User-visible fix described in user terms>
   ```

5. **Add CTA at bottom** (optional):
   - "Try it: `<link>`"
   - "Read the docs: `<link>`"
   - "Upgrade: `<install command>`"

6. **Pick tone preset before publishing** (ask user if not specified):

   | Preset | Audience | Example: "added OAuth login" becomes... |
   |--------|----------|------------------------------------------|
   | `technical` | dev / API consumer | "Sign in with OAuth2 (Google + GitHub providers); deprecates session cookies in favor of JWT bearer tokens." |
   | `marketing` (default) | end-user / customer | "Sign in with Google or GitHub — no more password hassle." |
   | `casual` | indie / community | "Forgot your password again? Don't worry, just hit 'Sign in with Google'." |

   If user didn't specify → ask one question: *"Audience là dev hay end-user?"* then pick the matching preset. Don't guess silently.

   **Universal rules across all presets**:
   - **Avoid**: "groundbreaking", "revolutionary", "AI-powered" (unless literally true), "industry-leading"
   - **Prefer**: concrete benefit, specific number, plain English

## Hard Rules
- **Don't list every commit** — quality over quantity; 5 great bullets beats 30 noisy ones
- **Don't use internal jargon** — no "ServiceLayer V2 migration", no internal codenames
- **Don't overpromise** — "fixed an edge case in webhook retries" beats "now bulletproof"
- **Don't auto-publish** — user pastes into blog / email / Slack themselves
- **Pair with `changelog-gen`** for the technical sibling doc; both can ship together
