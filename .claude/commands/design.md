# /design — UI/UX Preview Mode

## Mission
Generate a **UI/UX mockup preview** (self-contained HTML + DESIGN.md spec) so the user can review a modern, framework-aware design **before** applying it to the real frontend. **Do NOT touch any source code outside `design/`.**

> VN: Sinh mockup HTML xem trước + spec DESIGN.md, versioning, redirect `latest`. User duyệt mắt trước rồi mới `/code` để port vào project thật.

## Input
`$ARGUMENTS` = screen/feature description + optional flags:

| Flag | Effect |
|------|--------|
| `--slug=<name>` | Override auto-inferred slug (folder name under `design/`) |
| `--framework=<mui\|antd\|chakra\|bootstrap>` | Force a specific component library CDN (adds React UMD). Default: Tailwind-only. |
| `--preview` | After generating HTML, render 3 viewport screenshots via Puppeteer MCP |

---

## Process

### Step 1 — Detect frontend stack
Read `package.json` (or `pnpm-workspace.yaml` / workspace roots) and detect:
- **Framework**: React / Vue / Svelte / Next / Nuxt / Astro / none
- **Component library**: MUI (`@mui/material`), Ant Design (`antd`), Chakra (`@chakra-ui/react`), Bootstrap (`bootstrap` / `react-bootstrap`), Tailwind (`tailwindcss`), or plain CSS
- **Brand tokens**: scan `tailwind.config.{js,ts,mjs}`, `theme.ts`, CSS custom properties in `:root`, design tokens JSON — capture colors, font family, radii
- **If no frontend detected** (template repo, backend-only): default to Tailwind + neutral palette and note this in output

> VN: Đọc `package.json` để biết dùng framework gì → spec sẽ nói đúng ngôn ngữ component library đó.

### Step 2 — Clarify requirements
Ask the user (concise, only what you cannot infer):
- **Target viewports**: desktop / tablet / mobile (default: all 3)
- **Theme**: light / dark / auto (default: auto with toggle)
- **State variants to cover**: empty / loading / error / success (default: all applicable)
- **Brand palette** — if not discovered in Step 1
- **Reference** — any screenshot URL, Dribbble link, or existing component to mirror

Skip any question whose answer is obvious from context.

### Step 3 — Slug & version
- **Slug**: use `--slug` if provided; else derive from description (kebab-case, ≤ 32 chars, e.g. "user settings page" → `user-settings`)
- **Version**: scan `design/<slug>/v*/` directories. Bump to next `v<N>` (v1 if new). Never overwrite existing versions.

### Step 4 — Generate artifacts → `design/<slug>/v<N>/`

#### `preview.html` — self-contained mockup
Rules:
- **Default renderer**: Tailwind Play CDN (`<script src="https://cdn.tailwindcss.com"></script>`) — zero build, opens in any browser via double-click
- **If `--framework=X`**: include React 18 UMD + library CDN + Babel Standalone, render JSX inline. Warn this is ~500KB heavier.
- **Required UI elements**:
  - Theme toggle (top-right) — light/dark/auto, driven by `prefers-color-scheme` + manual override in `localStorage`
  - Viewport badge (bottom-right) — shows current width, visible in all 3 viewports for orientation
  - All requested state variants visible (tabs, side-by-side sections, or toggles)
  - Mock data inline — plausible names, numbers, timestamps (never real PII)
- **Accessibility**: semantic HTML (`<nav>`, `<main>`, `<button>`), ARIA labels on icon-only buttons, focus-visible styles, sufficient contrast (≥ WCAG AA)
- **Reference example**: [design/_example/v1/preview.html](design/_example/v1/preview.html) — study its structure before generating

#### `DESIGN.md` — design spec
Required sections (in this order):

```markdown
# <Feature Name> — Design Spec (v<N>)

## Goal
<1-2 sentences. Why this screen exists.>

## Target users
<Primary persona + their task.>

## Design tokens
### Colors
- Primary: `#RRGGBB` — <usage>
- Secondary / Accent / Neutral scale / Semantic (success/warning/error)

### Typography
- Font family: <...>
- Scale: <xs 12, sm 14, base 16, lg 18, xl 20, 2xl 24, 3xl 30>
- Weights used: <400, 500, 600, 700>

### Spacing scale
- Base unit: 4px. Scale: 4, 8, 12, 16, 24, 32, 48, 64

### Radii & shadows
- Radii: sm 4, md 8, lg 12, full 9999
- Shadows: sm / md / lg — include exact values

## Component breakdown
<USE THE USER'S ACTUAL FRAMEWORK. Examples:>
- Header — `MUI <AppBar position="sticky">` with `<Toolbar>` children
- Primary CTA — `MUI <Button variant="contained" color="primary" size="large">`
- (NOT generic `button.btn-primary`)

## States
- Empty: <describe visual + copy>
- Loading: <skeleton / spinner / where>
- Error: <inline alert / toast / banner>
- Success: <feedback pattern>

## Responsive behavior
- Desktop (≥1280): <layout>
- Tablet (768–1279): <what collapses/rearranges>
- Mobile (<768): <nav pattern, touch target sizes ≥44×44>

## Accessibility
- Contrast: all text ≥ 4.5:1 (body) / 3:1 (large)
- Focus: visible focus ring on all interactive
- Keyboard: tab order, shortcuts if any
- Screen reader: ARIA labels listed

## Open questions
1. <...>
2. <...>
```

### Step 5 — Update pointers (redirect-based, cross-platform)
Write these files at `design/<slug>/`:

- **`latest.html`** — HTML meta-refresh:
  ```html
  <!DOCTYPE html>
  <meta http-equiv="refresh" content="0; url=v<N>/preview.html">
  <title>Latest: <slug> v<N></title>
  ```
- **`LATEST.txt`** — single line: `v<N>`
- **`LATEST.md`** — one line: `Latest spec → [v<N>/DESIGN.md](v<N>/DESIGN.md)`

> No symlinks — works identically on Windows / macOS / Linux without admin rights.

### Step 6 — Update CHANGELOG (Keep-a-Changelog)
Append to `design/<slug>/CHANGELOG.md` (create with `# Changelog` header if new):

```markdown
## [v<N>] - YYYY-MM-DD
### Added
- <new components, states, screens added this iteration>
### Changed
- <what was refined from previous version>
### Removed
- <anything dropped>
```

Use today's date. For `v1`, use `### Added` only.

### Step 7 — Render screenshots (`--preview` flag only)
If `--preview` is set:
1. Verify `puppeteer` MCP is active. If not → print: `Enable puppeteer MCP in .mcp.json to use --preview` and skip to Step 8.
2. For each viewport, navigate Puppeteer to `file:///<absolute-path>/v<N>/preview.html`, set viewport, screenshot:
   - Desktop **1440×900** → `v<N>/preview-desktop.png`
   - Tablet **768×1024** → `v<N>/preview-tablet.png`
   - Mobile **375×812** → `v<N>/preview-mobile.png`
3. Screenshots are gitignored by default (see `.gitignore`) — intended for local review only.

### Step 8 — Report

```
## ✅ Design generated
- Slug:         <slug> (v<N>)
- Open latest:  file:///<abs>/design/<slug>/latest.html
- Spec:         design/<slug>/LATEST.md → v<N>/DESIGN.md
- Stack:        <detected> (spec uses <lib> component names)
- Screenshots:  preview-desktop.png, preview-tablet.png, preview-mobile.png  [if --preview]

## 🔜 Next
- Iterate:  `/design <refinement>`             → creates v<N+1>
- Apply:    `/code port design/<slug>/latest into src/`
```

---

## Hard Rules
- **NEVER** edit files outside `design/` — no source code, no configs, no package.json changes
- **NEVER** add runtime dependencies to the host project
- **NEVER** overwrite existing `v<N>/` folders — always bump version
- **NEVER** include real user PII in mock data — use plausible but fictional names/emails
- If the request is vague → ask for clarification BEFORE generating
- If the user's framework is unknown → use Tailwind + note the assumption in DESIGN.md Open Questions
