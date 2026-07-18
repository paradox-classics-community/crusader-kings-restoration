# Crusader Kings Restoration

An unofficial community project to make **Crusader Kings Complete / Deus Vult** attractive, readable and comfortable on modern computers while preserving the original game's identity and core gameplay.

> Beautiful enough to make players want to try it.  
> Clear enough to make them understand what they can do.

## Current stage

**Research, preservation and technical feasibility.**

The project currently targets the Steam release of Crusader Kings Complete and is documenting:

- the exact vanilla build;
- essential official and community fixes;
- historical visual and accessibility mods;
- Windows 11 and modern-display behaviour;
- the limits of the Europa Engine interface and map formats.

No gameplay expansion or total conversion is being developed at this stage.

## Planned modules

- **Modern Compatibility** — installation checks, display profiles, borderless/fullscreen behaviour and safe restoration.
- **Modern Controls** — modern camera and time controls.
- **Cartographic Edition** — a coherent visual restoration of the map, map modes, zoom levels and minimap.
- **Readable Interface** — larger, clearer windows, typography, icons and states.
- **Campaign Experience** — a clearer character and scenario selection flow.
- **Guided Tutorial** — progressive, practical onboarding instead of static help pages.
- **Feedback & Clarity** — clearer selections, active states, alerts and consequences.

Portrait and heraldry restoration may follow after the map and interface foundations are stable.

## Project principles

- Preserve the original design rather than simplify it.
- Make depth visible and understandable.
- Prefer modular, independently testable packages.
- Keep installation and uninstallation reproducible.
- Never redistribute original game files or third-party mod assets without permission.
- Credit and preserve historical community work.

## Supported baseline

The initial reference installation is the Steam build documented in:

- [`docs/technical/steam-baseline.md`](docs/technical/steam-baseline.md)
- [`manifests/steam-vanilla/`](manifests/steam-vanilla/)
- [`docs/audits/vanilla-audit.md`](docs/audits/vanilla-audit.md)

## Scope

See:

- [`docs/vision.md`](docs/vision.md)
- [`docs/scope.md`](docs/scope.md)
- [`docs/roadmap.md`](docs/roadmap.md)
- [`PROJECT_STATUS.md`](PROJECT_STATUS.md)

## Repository safety

Do not commit:

- game executables;
- original graphics, audio or data files;
- save files;
- complete third-party mod archives;
- assets copied from other games;
- redistributable components bundled with the game.

File names, metadata, hashes, original tools and fully original assets are acceptable when legally distributable.

## Contributing

The project is in its research phase. Useful contributions include:

- preserved links or archives whose redistribution rights are known;
- documentation of old CK1 mods and tools;
- reproducible Windows 11 test results;
- technical information about CK1 interface, fonts, map palettes and lightmaps;
- accessibility and UI analysis;
- original visual mock-ups.

Before publishing a third-party archive or asset, document its author and permission status.

## Disclaimer

This is an unofficial community project. It is not affiliated with or endorsed by Paradox Interactive.
