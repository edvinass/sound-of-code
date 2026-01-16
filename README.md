## sound-of-code

This repository is set up for **live coding with SuperCollider + TidalCycles** and is tuned for use with AI assistants (e.g. Cursor agents).

### For Humans

- **Quick Install**: Run `./install-tidal.sh` to automatically install all required components (macOS only).
- **Installation Guide**: See [`INSTALL-macOS.md`](INSTALL-macOS.md) for detailed macOS setup instructions.
- **Starting Tidal**: Run `./start-tidal.sh` or see [`START-Tidal.md`](START-Tidal.md) for manual startup instructions.
- **Using SuperCollider**: See [`GUIDE-SuperCollider.md`](GUIDE-SuperCollider.md) for SuperCollider basics and usage.
- **AI Tutor Guide**: See [`agents.md`](agents.md) for the exact tutoring and interaction contract that AI agents should follow.
- The intent of this repo is to:
  - Document a stable **SuperCollider / SuperDirt / TidalCycles** workflow.
  - Capture recipes, exercises, and patterns as you learn.
  - Provide a consistent place to start sessions with an AI live-coding tutor.

### For AI Assistants

- Always read `agents.md` before giving guidance.
- Preserve and build on the **curriculum structure** and **known-good baseline** procedures defined there.
- When adding examples or exercises, keep them:
  - Minimal, runnable, and clearly labeled (SuperCollider vs Tidal).
  - Connected to the phases in the curriculum where possible.

