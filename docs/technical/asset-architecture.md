# Asset Architecture — Initial Inventory

The Steam baseline exposes a large amount of presentation data outside the executable.

## High-level counts

| Area | File count |
|---|---:|
| Entire installation | 3,223 |
| `gfx/` | 2,888 |
| BMP images | 2,456 |
| `gfx/CoA` | 1,287 |
| `gfx/map` | 891 |
| `gfx/Interface` | 437 |
| `gfx/palette` | 208 |
| `gfx/portraits` | 48 |
| `gfx/fonts` | 10 |

## Important early findings

### Map

The installation includes map tables and multiple lightmap files. This supports further investigation into zoom-specific rendering, but does not yet prove that each visible zoom level can use an independently designed map.

### Interface

Many screens and control states are external bitmap assets. Visual replacement is likely straightforward. Layout and hitbox modification remain unproven.

### Fonts

Bitmap font assets are exposed. Glyph design can likely be changed. Larger visual metrics may still clip inside hard-coded text regions.

### Campaign frontend

Separate visual resources exist for county, duchy and kingdom presentation. This makes the campaign-selection screen a strong early vertical slice.

### Tutorial

Full-screen help assets are exposed. Static presentation can be replaced, while interactive progression depends on event and engine capabilities.

## Required next analysis

- map each important `.bmp` to an in-game screen;
- identify sprite-sheet frame rules;
- identify active, inactive, hover and disabled button states;
- determine palette constraints;
- determine font descriptor format;
- determine whether window dimensions affect text regions;
- locate or reconstruct lightmap-generation tools.
