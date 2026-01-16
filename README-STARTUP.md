# Startup Script for TidalCycles

This directory contains scripts to automate the startup process for TidalCycles on macOS.

## Quick Start

Run the startup script:

```bash
./start.sh
```

This will:
1. Install/update the SuperCollider startup file
2. Launch SuperCollider (which automatically starts SuperDirt)
3. Launch Pulsar (or Atom if Pulsar isn't found)
4. Display next steps

## Files

### `start.sh`
The main startup script that automates the entire launch process.

**Features:**
- Checks for required applications (SuperCollider)
- Installs/updates SuperCollider startup file
- Backs up existing startup file if present
- Launches SuperCollider and Pulsar
- Provides clear status messages and next steps

**Usage:**
```bash
chmod +x start.sh  # Make executable (first time only)
./start.sh
```

### `startup.scd`
The SuperCollider startup script that automatically starts SuperDirt when SuperCollider launches.

**Location:**
- Source: `startup.scd` (in this repo)
- Installed: `~/Library/Application Support/SuperCollider/startup.scd`

**What it does:**
- Configures SuperCollider server options (buffers, memory, latency)
- Boots the audio server
- Starts SuperDirt on port 57120
- Loads sample files
- Sets up orbit variables (~d1 through ~d12)

**Customization:**
You can edit `startup.scd` in this repo and re-run `start.sh` to update it. The script will automatically back up your existing startup file.

## Manual Steps After Running the Script

After the script completes:

1. **Verify SuperDirt is running:**
   - Check SuperCollider's post window
   - Look for: `SuperDirt: listening to Tidal on port 57120`
   - If you don't see this, check SuperCollider for error messages

2. **Boot Tidal in your editor:**
   - In Pulsar: `Packages → TidalCycles → Boot Tidal Cycles`
   - Wait for the `t>` prompt to appear

3. **Test with a simple pattern:**
   ```haskell
   d1 $ sound "bd sn"
   ```
   - Place cursor on the line
   - Press **Shift+Enter** to evaluate
   - You should hear kick and snare sounds

## Troubleshooting

### SuperCollider Not Found
- Install SuperCollider (see `INSTALL-macOS.md`)
- Ensure it's in `/Applications/SuperCollider.app`

### SuperDirt Not Starting
- Check SuperCollider's post window for errors
- Verify SuperDirt is installed: `Language → Quarks → SuperDirt` should be checked
- **Vowel quark missing**: If you see "Class 'Vowel' not found", install Vowel:
  ```supercollider
  Quarks.checkForUpdates({Quarks.install("Vowel"); thisProcess.recompile()})
  ```
  Or reinstall SuperDirt (which installs Vowel automatically):
  ```supercollider
  Quarks.checkForUpdates({Quarks.install("SuperDirt", "v1.7.3"); thisProcess.recompile()})
  ```
- Try restarting SuperCollider manually

### No Sound
- Check SuperCollider's audio device: `Server → Options → Audio`
- Verify system volume is up
- Check that SuperDirt shows "listening to Tidal on port 57120"

### Pulsar Not Found
- The script will still launch SuperCollider
- Install Pulsar or use another Tidal-compatible editor
- See `INSTALL-macOS.md` for editor installation

### Port Already in Use
- Another instance of SuperCollider may be running
- Quit all SuperCollider instances and try again

### "Exceeded number of interconnect buffers"
- The startup script now sets `numWireBufs = 128` (increased from 64)
- If you still see this error, you can increase it further in `startup.scd`

## Advanced Usage

### Custom Startup File
If you want to customize the SuperCollider startup:

1. Edit `startup.scd` in this repo
2. Re-run `start.sh` to install the updated version
3. Your previous startup file will be backed up automatically

### Disable Auto-Start
To stop SuperCollider from auto-starting SuperDirt:

1. Remove or rename: `~/Library/Application Support/SuperCollider/startup.scd`
2. Or edit it to remove the SuperDirt startup code

### Manual Startup
If you prefer to start manually:

1. Open SuperCollider
2. Paste the contents of `startup.scd` into the editor
3. Select all and press **Cmd+Enter** (Mac) or **Ctrl+Enter** (Windows/Linux)

## References

- [`START-Tidal.md`](START-Tidal.md) - Detailed startup instructions
- [`INSTALL-macOS.md`](INSTALL-macOS.md) - Installation guide
- [`GUIDE-SuperCollider.md`](GUIDE-SuperCollider.md) - SuperCollider usage guide
