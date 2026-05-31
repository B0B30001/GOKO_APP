---
name: premium-ui
description: Use when designing, redesigning, or polishing ANY UI/UX in this Flutter app (screens, widgets, theming, animation, layout, backgrounds) — produces premium, minimalist, human-feeling design and avoids generic "AI-slop" looks. Trigger whenever the user asks to make something look better/premium/minimalist, redesign a screen, fix the visual design, or critiques how it looks.
---

# Premium UI/UX for GOKO (Flutter)

Ship interfaces that feel intentional, calm, and premium — the bar is Apple /
Linear / Duolingo / chess.com — and never read as "AI slop."

## 0. Always SEE it before claiming it's good
- Render the change: `flutter build web --release`, serve `build/web`, screenshot —
  or ask the user for a screenshot. **Never declare UI "done" from code alone.**
- Diagnose from the actual pixels. Most "looks bad" reports are a concrete bug
  (e.g. a hero element duplicated) — find it, don't hand-wave taste.

## 1. Anti-"AI-slop" rules (the tells to kill)
- **One hero per view.** Never stamp the same focal element (mascot, badge,
  glow) on every item. Exactly one active/current element draws the eye.
- **No competing focal points.** Decide what the eye lands on first; subordinate
  the rest.
- **Mute raw imagery.** A loud, fully-saturated generated background under live
  UI looks cheap. Lay a scrim/veil over it so the interface reads.
- **No truncated/cramped text.** Give labels room, wrap to 2 lines, or show a
  label only where it fits (e.g. only on the active node).
- **No redundancy.** If two marks mean the same thing (gold star *and* a check),
  keep one.
- **Consistent shape language.** Don't mix ornate tiles with flat nodes in the
  same map — pick one vocabulary.
- **Grid + breathing room.** Align to a consistent rhythm; generous space beats
  density.

## 2. Premium techniques (Flutter)
- **Legibility scrims:** soft top/bottom black gradients (α ≈ 0.15–0.30) behind
  headers/CTAs that sit over imagery.
- **Depth via soft shadows + subtle gradients**, not heavy borders. Use 1px
  hairlines (white α≈0.2 / black α≈0.1) to lift elements off busy art.
- **Frosted/translucent chrome** (semi-transparent fills) so background art
  shows through — lightweight and modern, not opaque slabs.
- **Restrained motion:** gentle bob/scale/pulse on the single active element
  only; keep it subtle.
- **Type discipline:** one weight scale; tight letter-spacing on caps labels;
  `FontFeature.tabularFigures()` for numbers.
- **Color only from the theme** — never hardcode one-off colors.

## 3. Minimalism playbook
- Label only the active/next item; mark the rest with a single glyph
  (check / lock / number).
- Reduce chrome over imagery; let the art breathe.
- Add an element only when it earns its place; otherwise remove it.

## 4. This project's design system (reuse — don't reinvent)
- Theme: `lib/theme/go_theme.dart` (Material 3 light/dark).
- Garden palettes: `lib/widgets/garden/garden_theme.dart` (`gardenThemes`).
- Garden map primitives: `lib/widgets/garden/` — `GardenWorldPanel`,
  `WorldGate`, `PathConnector`, `pedestal_painter.dart`, `GardenMascot`.
- World backgrounds: `assets/backgrounds/<world>.png`, drawn by
  `GardenWorldPanel` (`BoxFit.cover` + dark veil, scrolls with the path).
- Localize every new user-facing string (`app_en.arb` + 5 locales + gen-l10n;
  `test/localization_test.dart` enforces completeness).

## 5. Pre-ship checklist
1. Rendered + screenshotted (or user-confirmed).
2. Exactly one focal element? No duplicated heroes?
3. Text legible, untruncated, on the type scale?
4. Imagery muted enough that UI reads cleanly?
5. Consistent spacing grid and shape language?
6. `flutter analyze` clean; `flutter test` green; `flutter build web` OK.
