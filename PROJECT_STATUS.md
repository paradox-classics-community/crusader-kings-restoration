# Project Status

Last updated: 2026-07-18

## Stage

**Research and technical feasibility**

## Completed

- Steam installation created and tested on Windows 11.
- Vanilla installation inventory generated.
- Steam App ID, Build ID, depot and executable fingerprint recorded.
- Initial usability audit recorded from a video capture.
- Three map zoom levels identified.
- Multiple map modes identified.
- Province-selection feedback confirmed.
- Initial module boundaries defined.
- Public project scope separated from gameplay/content expansion.

## In progress

- Locating the exact final official `2.1 beta` revision.
- Locating essential bug-fix and quality-of-life patches.
- Locating historical map, interface, font, icon and audio mods.
- Documenting redistribution permissions and dead sources.
- Designing the Windows 11 and modern-display test matrix.

## Next

1. Validate the cleaned Steam baseline manifest.
2. Create one research record per recovered mod or patch.
3. Compare every recovered archive against the vanilla manifest.
4. Test modern resolutions without changing gameplay data.
5. Evaluate DirectDraw wrappers and borderless display.
6. Prototype keyboard remapping for camera and time controls.
7. Inspect one interface window and one bitmap font as a feasibility slice.
8. Inspect map lightmaps and palette files.

## Not started

- Final visual direction.
- Production map assets.
- Production interface assets.
- Launcher implementation.
- Interactive tutorial implementation.
- Public releases.

## Open technical questions

- Are interface widget coordinates data-driven or hard-coded?
- Can larger background windows expose larger text/list areas?
- Which bitmap fonts are used by each screen?
- How are the `.tbl` lightmaps generated?
- Can visual density differ by zoom level without executable patching?
- Are speed controls available through undocumented hotkeys?
- Can a CK1 event chain detect enough state changes for a guided tutorial?

## Risks

- Historical downloads may be unavailable.
- Some mods may have no explicit redistribution permission.
- Larger fonts may cause clipping in hard-coded regions.
- Interface hitboxes may not follow redrawn assets.
- Modern display fixes may vary by GPU and monitor topology.
- Map tooling may need to be reconstructed.
