# Style spec: <Game Name>

Guidance: `~/Roblox/knowledge/02-visual-design-lighting-building.md`, `03-ui-ux-design.md`, `05-game-feel-vfx-audio-animation.md`.

- **Art style:** (e.g. chunky cartoon / low-poly / realistic)
- **Palette:** primary, accent, currency colors (keep `src/shared/UI/Theme.luau` and `src/gui/*.model.json` in sync)
- **Materials:**
- **Lighting preset:** `Neutral` (template default). If you change it, update `default.project.json` → `Lighting` (incl. `LightingStyle`) and `LightingPresets.luau`
- **UI style:** fonts (Builder Sans), corner radius, stroke, spacing grid 4/8
- **Music:** instrumental only, seamless loops, mood per area
- **SFX:** non-vocal; list key sounds (click, collect, reward, error)
