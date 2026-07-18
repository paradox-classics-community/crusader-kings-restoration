# Vanilla Usability Audit

Test date: 2026-07-17  
Platform: Steam / Windows 11  
Displayed version: `CK: Deus Vult 2.1 beta`

## Installation

### Observed

- The first launch requests installation of legacy DirectX components.
- The game repeatedly reports a failed prerequisite installation until Windows is restarted.
- After restart, the game launches normally.

### Impact

A user may reasonably conclude that the game is broken and stop before the first launch.

### Restoration requirement

A future compatibility tool must detect prerequisites before launch and explicitly explain when a restart is required.

## Display and desktop integration

### Observed

- Default game resolution is 1024 × 768.
- The game uses an old fullscreen mode.
- The second monitor is not conveniently accessible.
- The Windows key is needed to reach the desktop.
- Steam F12 and Print Screen captures did not work.
- The `WINDOW` launch option caused `Could not initialize Video`.

### Restoration requirement

Provide tested display profiles, preserve aspect ratio, support fast desktop switching and avoid relying on the native windowed mode.

## Campaign selection

### Positive

- The three start scenarios are reasonably easy to understand.

### Problems

- King, duke and count categories are represented by unclear graphical tabs.
- The alphabetical character list is difficult to browse.
- The location preview is unattractive and does not provide enough geographic context.
- No difficulty, campaign style or recommended first objective is shown.

### Restoration requirement

Make ranks explicit and present selected characters as distinct campaign promises.

## Map

### Observed

- Three zoom levels.
- Multiple map modes.
- Separate toggles for units, forts and coats of arms.
- Province selection feedback is present.
- Turning overlays off reduces visual overload.

### Problems

- All map modes are visually dated.
- Political information, heraldry, units, labels and terrain compete for attention.
- The controls are small and depend heavily on tooltips.
- Visual language is inconsistent between map modes.

### Restoration requirement

Treat the map, map modes, zoom levels, minimap and overlay toggles as one coherent visual system.

## Controls and time

### Observed

- Camera movement uses arrow keys.
- Pause has a keyboard control.
- Game speed is awkward to change and is prominently exposed through options rather than modern in-game controls.

### Restoration requirement

Add process-scoped modern controls, including ZQSD/WASD and direct speed adjustment.

## Interface

### Problems

- Designed around 1024 × 768.
- Text is small on modern displays.
- Decorative space is not converted into useful information hierarchy.
- Several controls and states are not self-explanatory.

### Restoration requirement

Test whether background size, text regions and hitboxes are independent before committing to a full layout redesign.

## Tutorial

### Observed

- Static, full-page help screens.
- Large amount of text.
- Previous/next navigation.
- No action-based progression.

### Restoration requirement

Replace or complement static help with a guided scenario using short instructions and observable objectives.

## Initial conclusion

The main obstacle is not a lack of content. It is the route into that content:

- fragile first launch;
- poor display integration;
- dated map presentation;
- unclear controls;
- small interface;
- weak campaign selection;
- non-interactive onboarding.
