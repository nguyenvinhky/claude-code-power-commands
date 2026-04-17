# Dashboard — Design Spec (v1)

> Reference example bundled with `/design` command. Demonstrates the expected DESIGN.md structure for a typical admin dashboard screen.

## Goal
Give operators an at-a-glance view of platform health — KPIs, weekly traffic trend, and a live activity feed — with clear affordances for empty / loading / error states so the page never looks "dead".

## Target users
**Operations staff** checking the pulse of the platform 5–10 times per day. Task: decide whether something needs attention in the next 30 seconds. Secondary: **executives** glancing at top-of-funnel numbers.

## Design tokens

### Colors
- **Primary** `#2563eb` (brand-600) — CTAs, active nav, focus ring
- **Primary hover** `#1d4ed8` (brand-700)
- **Primary tint** `#eff6ff` (brand-50) — active nav background (light mode)
- **Success** `#059669` (emerald-600) — positive trend arrows
- **Danger** `#e11d48` (rose-600) — negative trend arrows, error banners
- **Surface (light)** `#ffffff` cards on `#f8fafc` (slate-50) body
- **Surface (dark)** `#0f172a` (slate-900) cards on `#020617` (slate-950) body
- **Border** `#e2e8f0` (slate-200) / dark `#1e293b` (slate-800)
- **Text primary** `#0f172a` (slate-900) / dark `#f1f5f9` (slate-100)
- **Text muted** `#64748b` (slate-500) / dark `#94a3b8` (slate-400)

### Typography
- **Font family**: Inter (via `rsms.me/inter`), fallback to system sans
- **Scale**: xs 12 / sm 14 / base 16 / lg 18 / xl 20 / 2xl 24 / 3xl 30
- **Weights**: 400 (body), 500 (labels), 600 (titles, KPI values), 700 reserved for marketing pages (not used here)
- **Letter-spacing**: `tracking-tight` on titles, `tracking-wide uppercase` on KPI labels

### Spacing scale
Base unit **4px**. Used: 4, 8, 12, 16, 24, 32, 48.
- Card padding: 16 (mobile) / 24 (tablet+)
- Section gap: 24
- Grid gap: 16

### Radii & shadows
- **Radii**: sm 4 (inputs), md 6 (buttons, tabs), lg 8 (cards), full 9999 (avatars)
- **Shadows**: none on cards (borders only) — keeps UI flat and legible on both themes. Add `shadow-sm` only on floating elements (dropdowns, toasts)

## Component breakdown

> Reference example uses **Tailwind + plain HTML** (this repo has no project framework). When `/design` generates for a real project, replace these with the project's actual component library (MUI / Ant / Chakra / etc.)

- **Layout root** — `<div class="flex h-full">` two-column (sidebar + main)
- **Sidebar** — `<aside aria-label="Primary navigation">` 240px fixed width, hides below `md` breakpoint (768px)
- **Top bar** — `<header>` 56px height, contains: menu toggle (mobile only), search input, theme toggle, user avatar
- **Search input** — `<input type="search">` with `sr-only` label
- **KPI card** — `<article class="kpi">` border + rounded-lg. Contains: uppercase label, value, trend delta
- **Chart** — Pure CSS/SVG bars, no chart library. 7 bars, animated height transition
- **Activity list** — `<ul>` with avatar + text + timestamp per item
- **State tabs** — `<div role="tablist">` with `aria-selected` for each tab. Shows: Ready / Loading / Empty / Error
- **Theme toggle** — button with `aria-label="Toggle theme"`, persists to `localStorage['design-theme']`, respects `prefers-color-scheme` on first load
- **Viewport badge** — fixed bottom-right pill, shows current px width + device class (desktop/tablet/mobile). Hidden from screen readers (`aria-hidden`)

## States

- **Ready** (default) — all KPIs populated, chart animated in, activity feed shows 5 most recent events
- **Loading** — KPI values replaced with `animate-pulse` skeleton blocks; chart and activity remain (simulating partial load). Prevents layout shift
- **Empty** — KPI grid + chart + activity hidden; centered empty illustration + CTA "Connect data source"
- **Error** — Full-width red banner at top: `role="alert" aria-live="polite"` with retry button. KPI grid + chart hidden to avoid showing stale data

Switching states is done via the tab control at the top-right of the main area (for demo purposes; in production, state is driven by data loading).

## Responsive behavior

- **Desktop (≥1280)** — sidebar visible, KPIs in 4-column grid, chart takes 2/3 of lower row, activity takes 1/3
- **Tablet (768–1279)** — sidebar visible, KPIs in 2×2 grid, chart + activity stacked below each other
- **Mobile (<768)** — sidebar hidden behind hamburger menu; KPIs stack vertically; top bar condensed (search expands inline); theme label hidden (icon only)

Touch targets on mobile: all interactive elements ≥ 36×36 (tabs, buttons). Primary CTAs ≥ 44×44.

## Accessibility

- **Contrast**: body text ≥ 4.5:1 (checked against slate-900 on slate-50 = 16.8:1, slate-100 on slate-950 = 15.2:1). Muted text `slate-500 on slate-50` = 4.6:1 (passes AA). Trend arrows `emerald-600` / `rose-600` meet 3:1 as large text
- **Focus**: global `:focus-visible` rule — 2px brand-600 outline with 2px offset. No focus suppression anywhere
- **Keyboard**: skip-link to `#main` at top. All interactive elements in natural tab order. Tabs in state switcher use arrow-key navigation (not implemented in demo; add in production)
- **ARIA**:
  - `<aside aria-label="Primary navigation">`
  - Active nav link: `aria-current="page"`
  - Search: `sr-only` `<label>`
  - Icon buttons: `aria-label="Open navigation menu"`, `aria-label="Toggle theme"`
  - State tabs: `role="tablist"` / `role="tab"` / `aria-selected`
  - Error banner: `role="alert" aria-live="polite"`
  - Chart bars: per-bar `aria-label="Mon: 42k visits"` for screen readers
- **Motion**: only two animations — `animate-pulse` on skeleton, `transition-all` on bar heights. Both respect `prefers-reduced-motion` via Tailwind's built-in media query (to be verified in production)

## Open questions

1. **Real data contract** — what's the polling cadence? SSE vs poll? Affects loading state UX (skeleton vs subtle refresh spinner)
2. **Empty-state CTA** — does "Connect data source" link to settings or open a modal? Need routing decision
3. **Activity feed** — should it auto-refresh, or require manual reload? If auto, add a "N new events" banner pattern
4. **KPI drill-down** — clicking a KPI card should navigate where? (Currently inert)
5. **Chart library** — stay with CSS bars for simplicity, or adopt Recharts / Chart.js when real data + tooltips are needed?
