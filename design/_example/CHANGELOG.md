# Changelog

All notable changes to this design are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [v1] - 2026-04-17

### Added
- Initial Dashboard screen: sidebar navigation, top bar with search + theme toggle, 4 KPI cards (Active users / Revenue / Conversion / Churn), weekly traffic bar chart, recent activity feed
- Four state variants: Ready, Loading (skeleton), Empty, Error
- Light / dark / auto theme with `localStorage` persistence + `prefers-color-scheme` detection
- Viewport badge (desktop / tablet / mobile) for orientation during review
- Accessibility pass: skip link, semantic landmarks, ARIA labels on icon buttons, `aria-current` on active nav, focus-visible outline, per-bar chart labels
