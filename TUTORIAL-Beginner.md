# Beginner Tutorial: Your First Sounds with TidalCycles

A step-by-step guide to making your first sounds with TidalCycles. No prior experience needed!

---

## What You'll Learn

By the end of this tutorial, you'll be able to:
- Start TidalCycles and make sounds
- Write simple drum patterns
- Transform patterns to create variations
- Control volume, speed, and other parameters

**Time needed:** 15-30 minutes

---

## Prerequisites

Before starting, make sure you have:
- ✅ Installed all components (run `./install.sh` if needed)
- ✅ A text editor (Pulsar, VS Code, or similar)
- ✅ Headphones or speakers connected

---

## Part 1: Getting Started

### Step 1: Start SuperCollider and SuperDirt

**Option A: Use the startup script (Easiest)**

```bash
./start.sh
```

This automatically:
- Opens SuperCollider
- Starts SuperDirt
- Opens your editor

**Option B: Manual startup**

1. Open **SuperCollider** application
2. Wait for it to fully load (you'll see "Welcome to SuperCollider" message)
3. Check the bottom-right corner - the server should show as "running" (green)

If you see "SuperDirt: listening to Tidal on port 57120" in the post window, you're ready!

**What to expect:**
- SuperCollider window opens
- Post window shows compilation messages
- Server status shows "running"
- You see "SuperDirt: listening to Tidal on port 57120"

**Troubleshooting:**
- **Server not running?** Look for a "boot" button in the bottom-right, or run `s.boot;` in SuperCollider
- **No "SuperDirt" message?** The startup script should have started it automatically. If not, see `START-Tidal.md`

---

### Step 2: Start Tidal in Your Editor

1. **Open your text editor** (Pulsar, VS Code, etc.)

2. **Create a new file** and save it with a `.tidal` extension:
   - Example: `my-first-pattern.tidal`
   - **Important:** The file must end in `.tidal`

3. **Boot Tidal Cycles:**
   - **In Pulsar:** `Packages → TidalCycles → Boot Tidal Cycles`
   - **In VS Code:** Use the TidalCycles extension commands
   - A small window will open at the bottom showing the `t>` prompt

**What to expect:**
- A small terminal window appears at the bottom
- You see a `t>` prompt (this is the Tidal REPL)
- No error messages

**Troubleshooting:**
- **No `t>` prompt?** Check that Tidal booted successfully - look for error messages
- **"Connection refused"?** Make sure SuperDirt is running in SuperCollider first

---

## Part 2: Your First Sound

### Pattern 1: Kick and Snare

Type this in your `.tidal` file:

```haskell
d1 $ sound "bd sn"
```

**What to do:**
1. Place your cursor on the line
2. Press **Shift+Enter** (Mac) or **Ctrl+Enter** (Windows/Linux)
3. Listen!

**What you should hear:**
- A kick drum (`bd` = bass drum) followed by a snare (`sn`)
- The pattern repeats in a loop
- **If you hear this, congratulations! 🎉 You're making music with code!**

**What it means:**
- `d1` = pattern channel 1 (you can have up to 9 channels: d1 through d9)
- `$` = applies the pattern on the right to the channel on the left
- `sound "bd sn"` = play these samples in sequence

**Try this:**
- Change `bd sn` to `bd bd sn` - what happens?
- Try `sn bd` - how does it sound different?

---

### Pattern 2: Add a Hi-Hat

Now let's add a hi-hat to make it more interesting:

```haskell
d1 $ sound "bd sn bd hh"
```

**What you should hear:**
- Kick, snare, kick, hi-hat repeating

**What it means:**
- `hh` = hi-hat sample
- The pattern plays all four sounds in order, then repeats

**Try this:**
- Add more `hh` sounds: `"bd sn bd hh hh"`
- Try `"bd ~ sn ~"` - the `~` means silence/rest

---

### Pattern 3: Multiple Channels

You can play multiple patterns at the same time! Try this:

```haskell
d1 $ sound "bd sn"
d2 $ sound "~ hh"
```

**What to do:**
1. Place cursor on the first line, press **Shift+Enter**
2. Place cursor on the second line, press **Shift+Enter**

**What you should hear:**
- `d1` plays kick and snare
- `d2` plays hi-hat on the off-beats (the `~` is a rest/silence)
- Both patterns play together!

**Try this:**
- Change `d2` to `"hh ~ hh ~"` - what happens?
- Add a third channel: `d3 $ sound "~ ~ ~ cp"` (cp = clap)

---

## Part 3: Stopping and Controlling Patterns

### Stop a Pattern

To stop a pattern, use `silence`:

```haskell
d1 silence
```

**What to do:**
- Type this and press **Shift+Enter**
- The pattern stops immediately

**Alternative:** You can also use:
```haskell
d1 $ sound "~"
```

This plays silence (rests) instead of stopping.

---

### Stop All Patterns

To stop everything at once:

```haskell
hush
```

**What to do:**
- Type `hush` and press **Shift+Enter**
- All patterns (d1, d2, d3, etc.) stop

---

### Change Tempo

To change the speed of your patterns:

```haskell
setcps 0.8
```

**What it means:**
- `setcps` = set cycles per second (tempo)
- `0.8` = slower tempo (try `1.2` for faster)

**Try this:**
- Start with `setcps 0.6` (slow)
- Then try `setcps 1.5` (fast)
- Find a tempo you like!

---

## Part 4: Pattern Transformations

Now let's make your patterns more interesting with transformations!

### Make It Faster

```haskell
d1 $ fast 2 $ sound "bd sn"
```

**What you should hear:**
- The pattern plays twice as fast!

**What it means:**
- `fast 2` = play the pattern 2 times faster
- Try `fast 4` for even faster!

**Try this:**
- `slow 2 $ sound "bd sn"` - plays half speed
- `fast 0.5 $ sound "bd sn"` - same as slow 2

---

### Reverse the Pattern

```haskell
d1 $ rev $ sound "bd sn bd hh"
```

**What you should hear:**
- The pattern plays backwards!

**What it means:**
- `rev` = reverse the pattern
- The last sound becomes the first

---

### Add Variation with "every"

Make the pattern change every few cycles:

```haskell
d1 $ every 4 (fast 2) $ sound "bd sn bd hh"
```

**What you should hear:**
- Normal pattern for 3 cycles
- Then it speeds up for 1 cycle
- Then repeats

**What it means:**
- `every 4` = every 4th cycle
- `(fast 2)` = apply this transformation
- So every 4th cycle, the pattern plays twice as fast

**Try this:**
- `every 2 (rev) $ sound "bd sn"` - reverses every other cycle
- `every 8 (slow 2) $ sound "bd sn bd hh"` - slows down every 8th cycle

---

### Density: Make Patterns Denser

```haskell
d1 $ density 2 $ sound "bd sn"
```

**What you should hear:**
- The pattern plays twice as often (more sounds in the same time)

**What it means:**
- `density 2` = double the density (play twice as often)
- Similar to `fast`, but works differently with timing

**Try this:**
- `density 0.5 $ sound "bd sn bd hh"` - half density (slower)
- `density 4 $ sound "bd"` - very dense kick pattern

---

## Part 5: Control Parameters

Now let's control how the sounds play!

### Volume (Gain)

```haskell
d1 $ gain 0.5 $ sound "bd sn"
```

**What you should hear:**
- The same pattern, but quieter

**What it means:**
- `gain 0.5` = play at 50% volume (0.0 = silent, 1.0 = full volume)
- Useful for balancing different channels

**Try this:**
- `gain 1.5 $ sound "bd sn"` - louder (may clip/distort)
- `gain 0.3 $ sound "hh ~ hh ~"` - quiet hi-hats

---

### Pan (Left/Right)

```haskell
d1 $ pan 0.5 $ sound "bd sn"
```

**What you should hear:**
- The sound comes from the center (if you have stereo speakers/headphones)

**What it means:**
- `pan 0.0` = left speaker
- `pan 0.5` = center
- `pan 1.0` = right speaker

**Try this:**
- `pan 0 $ sound "bd"` - kick on left
- `pan 1 $ sound "sn"` - snare on right
- `pan sine $ sound "hh ~ hh ~"` - hi-hat moves left to right!

---

### Speed (Pitch)

Change the pitch/speed of samples:

```haskell
d1 $ speed 1.5 $ sound "bd sn"
```

**What you should hear:**
- The samples play faster and higher pitched

**What it means:**
- `speed 1.0` = normal speed
- `speed 2.0` = double speed (octave higher)
- `speed 0.5` = half speed (octave lower)

**Try this:**
- `speed 0.75 $ sound "bd"` - lower kick
- `speed "1 1.5 2" $ sound "bd"` - changing speeds!

---

### Combine Multiple Parameters

You can combine multiple controls:

```haskell
d1 $ gain 0.7 $ pan 0.3 $ speed 1.2 $ sound "bd sn"
```

**What you should hear:**
- Quieter, panned slightly left, slightly faster

**Try this:**
- Experiment with different combinations!
- `gain 0.8 $ pan sine $ speed 1.5 $ sound "hh ~ hh ~"`

---

## Part 6: More Sample Names

Here are more samples you can use:

### Drums
- `bd` - bass drum / kick
- `sn` - snare
- `hh` - hi-hat
- `cp` - clap
- `ho` - open hi-hat
- `hc` - closed hi-hat
- `lt` - low tom
- `mt` - mid tom
- `ht` - high tom

### Other Sounds
- `arpy` - arpeggio synth
- `bass` - bass sound
- `pluck` - plucked string
- `vibe` - vibraphone
- `feel` - feel sound

**Try this:**
```haskell
d1 $ sound "bd ~ sn ~"
d2 $ sound "~ arpy ~ arpy"
d3 $ sound "hh ~ hh ~"
```

---

## Part 7: Your First Song

Let's put it all together! Try this:

```haskell
-- Kick and snare pattern
d1 $ gain 0.8 $ sound "bd ~ sn ~"

-- Hi-hats
d2 $ gain 0.5 $ pan 0.5 $ sound "~ hh ~ hh"

-- Melody
d3 $ gain 0.6 $ pan sine $ speed "1 1.2 1.5 1.2" $ sound "arpy ~ arpy ~"

-- Variation every 8 cycles
d4 $ every 8 (fast 2) $ gain 0.4 $ sound "~ ~ ~ cp"
```

**What to do:**
1. Type each line
2. Press **Shift+Enter** after each line
3. Listen to all the layers together!

**Try this:**
- Change the patterns
- Adjust the `gain` values to balance the mix
- Add `every` transformations to create variations
- Experiment with `pan` to create movement

---

## Part 8: Common Patterns to Try

Here are some patterns to experiment with:

### Simple Rock Beat
```haskell
d1 $ sound "bd ~ sn ~ bd ~ sn ~"
d2 $ sound "~ hh ~ hh ~ hh ~ hh"
```

### House Beat
```haskell
d1 $ sound "bd ~ ~ ~ bd ~ sn ~"
d2 $ sound "hh hh hh hh hh hh hh hh"
```

### Breakbeat
```haskell
d1 $ sound "bd sn ~ sn bd ~ sn ~"
d2 $ sound "~ ~ hh ~ ~ hh ~ hh"
```

### Experimental
```haskell
d1 $ every 4 (rev) $ density 2 $ sound "bd sn"
d2 $ pan sine $ speed "1 1.5 2 1.5" $ sound "arpy"
d3 $ gain 0.3 $ sound "hh ~ hh ~"
```

---

## Troubleshooting

### No Sound?

1. **Check SuperCollider:**
   - Is the server running? (green indicator in bottom-right)
   - Do you see "SuperDirt: listening to Tidal on port 57120"?

2. **Check Tidal:**
   - Do you see the `t>` prompt?
   - Any error messages?

3. **Check your pattern:**
   - Did you press **Shift+Enter** (not just Enter)?
   - Is the file saved with `.tidal` extension?
   - Check for typos in the pattern

4. **Check audio:**
   - Are your speakers/headphones connected?
   - Is system volume up?
   - Check SuperCollider audio settings: `Server → Options → Audio`

### Pattern Not Working?

- **Syntax error?** Check for typos, missing quotes, or missing `$`
- **Wrong sample name?** Try `bd` or `sn` first to test
- **Pattern too complex?** Start simple: `d1 $ sound "bd"`

### SuperCollider Errors?

- **"Class 'Vowel' not found"?** Install Vowel quark (see `INSTALL-macOS.md`)
- **Server not booting?** Check audio device settings
- **"Too many nodes"?** Restart SuperCollider

---

## Next Steps

Congratulations! You've made your first sounds with TidalCycles! 🎉

**What to explore next:**

1. **More transformations:**
   - `jux rev` - reverse only the left channel
   - `chop` - chop samples into pieces
   - `striate` - create stutter effects

2. **Pattern composition:**
   - `cat` - concatenate patterns
   - `slowcat` - concatenate slowly
   - `stack` - layer patterns

3. **Probability:**
   - `sometimes` - sometimes apply a transformation
   - `rand` - random values

4. **Learn more:**
   - See `START-Tidal.md` for more advanced patterns
   - See `GUIDE-SuperCollider.md` for SuperCollider basics
   - Check out the [TidalCycles documentation](https://tidalcycles.org/docs/)

**Remember:**
- Start simple, then add complexity
- Experiment and have fun!
- If something breaks, go back to a working pattern
- Save your favorite patterns in files

---

## Quick Reference

### Essential Commands
```haskell
d1 $ sound "bd sn"        -- Play a pattern
d1 silence                 -- Stop a pattern
hush                       -- Stop all patterns
setcps 0.8                 -- Change tempo
```

### Common Transformations
```haskell
fast 2                     -- Play 2x faster
slow 2                     -- Play 2x slower
rev                        -- Reverse pattern
every 4 (fast 2)           -- Transform every 4th cycle
density 2                  -- Double density
```

### Common Parameters
```haskell
gain 0.5                   -- Volume (0.0-1.0)
pan 0.5                    -- Panning (0.0=left, 1.0=right)
speed 1.5                  -- Playback speed/pitch
```

### Sample Names
- `bd`, `sn`, `hh`, `cp` - drums
- `arpy`, `bass`, `pluck` - other sounds

---

**Happy coding! 🎵**
