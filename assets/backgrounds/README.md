# Puzzle Garden Backgrounds

Drop hand-designed PNGs into this directory to replace the procedural
`_GardenBackgroundPainter` for each world theme. The garden screen tries
the PNG first and gracefully falls back to the painter if the asset is
missing — so this folder can stay empty during development.

## File naming

The garden looks for one PNG per theme band, exact filename:

| Theme band | Levels  | Expected filename            |
| ---------- | ------- | ---------------------------- |
| 0          | 1–5     | `stone_forest.png`           |
| 1          | 6–10    | `crystal_cave.png`           |
| 2          | 11–15   | `copper_peaks.png`           |
| 3          | 16–20   | `diamond_tundra.png`         |
| 4          | 21+     | `jade_highlands.png`         |

Any missing file silently falls through to the painted version — drop them
in as you create them, no code changes required.

## Canva export specs

- **Aspect ratio**: 9:20 (`1080 × 2400 px`) so the image fills a phone screen
  in portrait without cropping at common device aspect ratios.
- **Format**: PNG, 24-bit colour, no alpha needed (a flat background is
  fine — the ambient layer above adds drifting motifs).
- **Composition**: place the focal interest (mountains, gates, distant
  structures) in the top 60% — the bottom 40% is hidden under the
  "Solve Puzzles" CTA and the player's current pedestal.
- **Colour palette**: match the theme's defined `_GardenTheme` colour stops
  (see `lib/screens/puzzle_garden_screen.dart` line ~64) so the
  AnimatedSwitcher cross-fade between bands feels intentional.

## Why we ship the directory empty

The CustomPainter approach is small, deterministic, and never fails to
render. Hand-designed backgrounds are an upgrade — not a requirement.
Keeping the asset folder optional means the app boots without these files
and looks good while you iterate on designs in Canva.
