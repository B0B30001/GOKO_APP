# Garden World Scenery

Drop one illustrated **scenery-only** PNG per world here. Each scrolls *with*
the path behind that world's tiles (see `GardenWorldPanel` in
`lib/widgets/garden/garden_scenery.dart`) and gracefully falls back to the
procedural background painter when absent — so this folder can stay empty
during development.

## File naming

One PNG per theme band, exact filename:

| Theme band | Puzzle levels | Filename               | Vibe                         |
| ---------- | ------------- | ---------------------- | ---------------------------- |
| 0          | 1–5           | `stone_forest.png`     | bright zen courtyard / pines |
| 1          | 6–10          | `crystal_cave.png`     | cool blue/purple cavern      |
| 2          | 11–15         | `copper_peaks.png`     | warm orange/gold mountains   |
| 3          | 16–20         | `diamond_tundra.png`   | pale icy highlands           |
| 4          | 21+           | `jade_highlands.png`   | deep green jade plateau      |

The Learn page uses one band (the user's palette), so it just needs that
world's file. Any missing file silently falls through to the painter — drop
them in as you create them, no code changes required.

## How they're rendered (important — this is why nothing stretches now)

`GardenWorldPanel` paints the scenery with **`BoxFit.fitWidth` +
`ImageRepeat.repeatY`**, anchored top-center:

- **fitWidth** scales the image to the panel width with its aspect preserved →
  **never horizontally stretched**, on any device.
- **repeatY** tiles it vertically so it covers a band of any height.

So author the art **seamless on the top/bottom edges** (so the vertical repeat
joins cleanly), or make it tall enough that one copy covers the whole band.

## Export specs

- **Width**: 1080 px. **Height**: 1080–2400 px (taller = fewer visible repeats).
- **Format**: PNG, 24-bit (no alpha needed — it's a full backdrop).
- **CRITICAL — scenery only**: **NO game tiles, NO winding path, NO checkmarks,
  NO buttons, NO UI, NO characters.** Those are drawn live on top. If you bake
  tiles into the image they'll collide with the real interactive tiles.
- **Colour**: match the band's `GardenTheme` stops (see
  `lib/widgets/garden/garden_theme.dart`) so the world reads as one place.

## Gemini / image-gen prompt template

> "Tall vertical mobile-game background, **<vibe>**, soft hand-illustrated
> Candy-Crush / Studio-Ghibli style, Japanese zen garden — pagoda, stone
> lanterns, bonsai, koi pond, drifting clouds, terraced stone courtyard.
> **Empty scene: NO game tiles, NO path, NO buttons, NO text, NO characters.**
> Seamless top and bottom edges for vertical tiling. 1080×2160."

Swap `<vibe>` per the table above (e.g. "cool blue crystal cavern" for
`crystal_cave.png`).

## Optional: 3D panda mascot

Drop a transparent-background `assets/mascot/panda_3d.png` (a 3D-rendered panda)
to upgrade the on-tile mascot; `GardenMascot` prefers it, then falls back to
`assets/avatars/panda.png`. Declare `assets/mascot/` in `pubspec.yaml` if you add it.

## Why we ship the directory empty

The procedural painter is small, deterministic, and never fails to render.
Hand-designed backgrounds are an upgrade — not a requirement — so the app boots
and looks good while you iterate on the art.
