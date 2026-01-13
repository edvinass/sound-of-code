# macOS Installation Guide for TidalCycles

This guide covers installing TidalCycles, SuperCollider, SuperDirt, and all dependencies on macOS.

> **Source**: This guide is based on the [official TidalCycles macOS installation documentation](https://tidalcycles.org/docs/getting-started/macos_install).

## Prerequisites

- **macOS** (tested on Ventura for Silicon/M1, Big Sur/Monterey for Intel)
- Terminal access
- Internet connection

## Installation Methods

### Method 1: Automatic Installation (Recommended for Beginners)

The `tidal-bootstrap` script automates installation of all components. Use this if you're new to Tidal and don't already have SuperCollider and SuperDirt installed.

#### Step 1: Install Xcode Command Line Tools

If you're unsure whether this is installed, run the command below. It will exit if already installed, or prompt for installation if missing.

```bash
/usr/bin/xcode-select --install
```

**What to expect:**
- Multiple dialog windows will appear
- You'll need to accept Apple's license agreement
- Installation can take **20-30+ minutes**

#### Step 2: Run tidal-bootstrap

This script installs only what's missing and can be run multiple times safely.

**What it installs:**
- **Haskell Language** (via Ghcup)
- **cabal**: Package system for Haskell and TidalCycles
- **TidalCycles**: The pattern engine (includes `BootTidal.hs`)
- **Pulsar**: Text editor
- **tidalcycles plugin** for Pulsar
- **SuperCollider**: Backend audio generation
- **SuperDirt**: Sample library used by Tidal
- **sc-3 plugins**: Unit generator plugins

**Run the installer:**

```bash
curl https://raw.githubusercontent.com/tidalcycles/tidal-bootstrap/master/tidal-bootstrap.command -sSf | sh
```

**What to expect:**
- The Haskell install is the longest part (20-30+ minutes)
- You'll see many messages about Haskell, ghcup, cabal, etc.
- This is normal—let it complete

#### Step 3: Post-Installation Verification

1. **Start a new shell** (exit and reopen Terminal) to load new PATH settings.

2. **Verify installations** by running these commands:

```bash
# Check Tidal installation
cabal list tidal
cabal info tidal

# Check Pulsar plugin
ls ~/.pulsar/packages/tidalcycles/node_modules/osc-min

# Check SuperCollider version
/Applications/SuperCollider.app/Contents/Resources/scsynth -v
```

**Expected results:**
- First two commands should show Tidal version info (if they fail, Haskell/Tidal isn't installed correctly)
- The `ls` command should list files in the `osc-min` directory
- The `scsynth` command should show SuperCollider version info

3. **Verify SuperDirt in SuperCollider:**

   - Open **SuperCollider** application
   - From the **Language** menu, select **"Quarks"**
   - **SuperDirt** and **Dirt-Samples** should be listed and checked

#### Troubleshooting Automatic Installation

- **Review install output**: Check for error messages or install failures
- **Haskell issues**: Check `/tmp/ghcup-install.log` for details
- **Re-run installer**: You can run `tidal-bootstrap` again—it skips already-installed components
- **Pulsar plugin issues**: 
  - First try installing via Pulsar's Package Manager (see Pulsar documentation)
  - If that fails, try manual plugin installation (see Pulsar documentation)

---

### Method 2: Manual Installation

Use this if you prefer to control each step or if automatic installation fails.

#### Prerequisites

Before installing Tidal, ensure you have:
- **Haskell** (via Ghcup)
- **SuperCollider** with SC3 Plugins
- **Git**
- A **text editor** for Tidal (Pulsar, VS Code, or other—see sidebar in Tidal docs)

#### Step 1: Install Haskell (Ghcup)

1. **Add GHC path to your shell configuration:**

   For **macOS 10.14 or earlier** (bash):
   ```bash
   . "$HOME/.ghcup/env"
   echo '. $HOME/.ghcup/env' >> "$HOME/.bashrc"
   ```

   For **macOS 10.15 Catalina or later** (zsh):
   ```bash
   . "$HOME/.ghcup/env"
   echo '. $HOME/.ghcup/env' >> "$HOME/.zshrc"
   ```

2. **Update cabal and install TidalCycles:**

   ```bash
   cabal update
   cabal v1-install tidal
   ```

   **What to expect:**
   - First-time install may take a while
   - At the end, you should see: `Installed tidal-x.x.x` (where x.x.x is the version number)
   - No errors should appear

#### Step 2: Install SuperDirt

1. **Start SuperCollider** application

2. **Paste this code** in the SuperCollider editor:

```supercollider
Quarks.checkForUpdates({Quarks.install("SuperDirt", "v1.7.3"); thisProcess.recompile()})
```

3. **Run the code:**
   - Click on the line to place cursor there
   - Hold **Shift** and press **Enter** (or **Cmd+Return**)

**What to expect:**
- Installation will take a while
- You'll see messages like:
  ```
  Installing SuperDirt
  Installing Vowel
  Vowel installed
  Installing Dirt-Samples
  Dirt-Samples installed
  SuperDirt installed
  compiling class library...
  ```
- Finally, you'll see: `*** Welcome to SuperCollider 3.x.x *** For help press Ctrl-D.`

#### Step 3: Verify Installation

Follow the same verification steps as in **Method 1, Step 3** above.

---

## Next Steps

Once installation is complete:

1. **Start Tidal**: Follow the ["Start Tidal" guide](https://tidalcycles.org/docs/getting-started/start_tidal) to learn how components work together
2. **First patterns**: Try the examples in `agents.md` Phase 1 curriculum
3. **Troubleshooting**: If you encounter issues, refer to the "Known-Good Baseline" section in `agents.md`

## Common Issues

### "Command not found" errors after installation
- **Solution**: Start a new terminal session to load updated PATH

### SuperDirt not found in Quarks
- **Solution**: Re-run the SuperDirt installation code in SuperCollider

### Tidal can't connect to SuperDirt
- **Solution**: Ensure SuperCollider server is booted and SuperDirt is started before launching Tidal

### Audio not working
- **Solution**: Check SuperCollider's audio device settings (Server → Options → Audio)

## References

- **[TidalCycles macOS Installation (Official Source)](https://tidalcycles.org/docs/getting-started/macos_install)** - Primary reference for this guide
- [TidalCycles Official Docs](https://tidalcycles.org/docs/)
- [SuperCollider Getting Started](https://doc.sccode.org/Guides/Getting-Started.html)
- [TidalCycles Userbase](https://club.tidalcycles.org/)
