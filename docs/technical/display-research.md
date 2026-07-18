# Display Research

## Baseline

- Internal resolution: 1024 × 768
- Primary monitor: 2560 × 1440
- Secondary monitor: 1920 × 1080
- Windows scale: 100 %
- Native fullscreen works.
- Native `WINDOW` launch mode fails with `Could not initialize Video`.

## Goals

- correct aspect ratio;
- readable UI size;
- fast switching to desktop;
- usable second monitor;
- stable mouse coordinates;
- no visual stretching;
- predictable internal resolution for future interface assets.

## Test matrix

| Internal resolution | Output mode | Target display | Status |
|---|---|---|---|
| 1024 × 768 | native fullscreen | 1440p | Observed; low-quality presentation |
| 1280 × 720 | native fullscreen | 1440p | Not tested |
| 1600 × 900 | native fullscreen | 1440p | Not tested |
| 1920 × 1080 | native fullscreen | 1440p | Not tested |
| 2560 × 1440 | native fullscreen | 1440p | Not tested |
| 1920 × 1080 | borderless/wrapper | 1440p | Not tested |
| 1920 × 1080 | integer scale | 4K | Future test |

## Candidate approaches

- direct `settings.txt` resolution changes;
- Windows compatibility and DPI settings;
- DirectDraw wrapper;
- fake fullscreen or borderless wrapper;
- fixed internal resolution with controlled scaling.

No wrapper is approved until it has been tested for stability, input alignment, alt-tab behaviour and licensing.
