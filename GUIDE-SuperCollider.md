# SuperCollider Usage Guide

A practical guide to using SuperCollider for audio synthesis and algorithmic composition.

> **Source**: This guide is based on the [official SuperCollider website](https://supercollider.github.io/) and documentation.

## What is SuperCollider?

**SuperCollider** is a platform for audio synthesis and algorithmic composition, used by musicians, artists, and researchers. It's free, open-source, and runs on Windows, macOS, and Linux.

### The Three Components

SuperCollider consists of three major parts:

1. **scsynth** - A real-time audio engine (the **server**)
   - Generates sound
   - Runs audio processing
   - Handles synthesis and effects

2. **sclang** - An interpreted programming language (the **client**)
   - Controls the server
   - Sends commands and patterns
   - Handles timing and scheduling

3. **scide** - An editor for sclang with integrated help
   - The IDE you see when you open SuperCollider
   - Includes code editor, post window (logs), and help browser

### Client/Server Architecture

**Why this matters:** The separation between client (sclang) and server (scsynth) allows:
- Multiple clients to control one server
- Remote control over networks
- Stability (if client crashes, server keeps running)
- Integration with other languages (Python, JavaScript, Haskell, etc.)

**In practice:** When you write code in SuperCollider, `sclang` sends commands to `scsynth`, which generates the actual audio.

---

## Basic Usage

### Starting SuperCollider

1. **Open the SuperCollider application**
   - You'll see the editor window (where you type code)
   - You'll see the post window (shows logs and output)

2. **Boot the server**
   - The server must be running before you can make sound
   - Look at the bottom-right corner for server status

**Boot the server:**

```supercollider
s.boot;
```

**What to do:**
- Type `s.boot;` in the editor
- Place cursor on the line
- Press **Ctrl+Enter** (or **Cmd+Enter** on Mac)

**What to expect:**
- In the post window, you'll see messages about server booting
- Status indicator should show "running" (green)
- You should see: `-> localhost`

**Common failure modes:**
- **No audio device**: Go to Server → Options → Audio → select your output device
- **Port already in use**: Quit and restart SuperCollider
- **Permission errors**: Check system audio permissions

### Your First Sound

**Simple sine wave:**

```supercollider
{ SinOsc.ar(440, 0, 0.2) }.play;
```

**What to do:**
- Paste the code above
- Select it and press **Ctrl+Enter**

**What you should hear:**
- A 440 Hz tone (musical note A4)
- Continuous sound until you stop it

**What it means:**
- `SinOsc.ar` = sine wave oscillator (audio rate)
- `440` = frequency in Hz
- `0` = phase offset
- `0.2` = amplitude (volume, 0-1 range)
- `.play` = play this sound

**Stop the sound:**

```supercollider
CmdPeriod.run; // Mac
CtrlPeriod.run; // Windows/Linux
```

Or press **Ctrl+.** (period) to stop all sounds.

---

## Core Concepts

### Server vs Client

**Server (`s` or `Server.default`):**
- The audio engine (scsynth)
- Must be booted before making sound
- Handles all audio processing

**Client (sclang):**
- The programming language
- Sends commands to server
- Handles timing, patterns, control flow

**Check server status:**

```supercollider
s.booted; // returns true if server is running
s.serverRunning; // also checks if running
```

### Audio Rate vs Control Rate

**Audio rate (`.ar`):**
- Calculated every sample (typically 44,100+ times per second)
- Used for audio signals (oscillators, filters, etc.)
- Higher CPU usage

**Control rate (`.kr`):**
- Calculated less frequently (~1,000 times per second)
- Used for control signals (modulation, parameters)
- Lower CPU usage

**Example:**

```supercollider
// Audio rate oscillator
{ SinOsc.ar(440) * 0.2 }.play;

// Control rate for modulation
{ SinOsc.ar(440 + (SinOsc.kr(2) * 100)) * 0.2 }.play;
```

**What you'll hear:**
- First: steady tone
- Second: vibrato effect (frequency modulation)

### SynthDefs: Defining Reusable Synths

**SynthDef** = a definition of a synthesizer that can be reused

**Basic SynthDef:**

```supercollider
(
SynthDef(\sine, {
    |freq = 440, amp = 0.2|
    var sig;
    sig = SinOsc.ar(freq, 0, amp);
    Out.ar(0, sig);
}).add;
)
```

**What to do:**
- Select the entire block (including parentheses)
- Press **Ctrl+Enter**

**What it means:**
- `\sine` = name of the synth (symbol)
- `|freq = 440, amp = 0.2|` = arguments with default values
- `var sig;` = declare a variable
- `Out.ar(0, sig)` = send signal to output bus 0 (left channel)

**Play the SynthDef:**

```supercollider
x = Synth(\sine);
x.set(\freq, 880); // change frequency
x.free; // stop and remove
```

**Micro-exercise:**
1. Create a SynthDef with a different name
2. Add a `pan` argument (0 = left, 1 = right)
3. Use `Pan2.ar` to pan the signal
4. Play it and change the pan position

---

## Common Operations

### Booting and Quitting

```supercollider
s.boot;        // boot the server
s.quit;        // quit the server
s.reboot;      // reboot (useful after changing server options)
s.freeAll;     // free all synths (stop all sound)
```

### Server Options

Configure audio settings before booting:

```supercollider
s.options.numOutputBusChannels = 2; // stereo output
s.options.numInputBusChannels = 2;  // stereo input
s.options.sampleRate = 48000;       // sample rate
s.latency = 0.05;                    // scheduling latency
s.reboot; // options only apply after reboot
```

### Creating and Controlling Synths

```supercollider
// Create a synth and store reference
x = Synth(\sine, [\freq, 440]);

// Change parameters while playing
x.set(\freq, 880);
x.set(\amp, 0.5);

// Stop and remove
x.free;

// Or use a global variable
~synth = Synth(\sine);
~synth.free;
```

### Scheduling and Timing

**System clock:**

```supercollider
// Play a note every second
(
SystemClock.sched(0, {
    { SinOsc.ar(440, 0, 0.2) }.play;
    1.0; // return time until next execution
});
)
```

**Tempo clock:**

```supercollider
// Create a tempo clock (beats per minute)
t = TempoClock(120/60); // 120 BPM

// Schedule events
t.sched(0, {
    { SinOsc.ar(440, 0, 0.2) }.play;
    1.0; // next beat
});
```

---

## Working with SuperDirt (for TidalCycles)

When using TidalCycles, SuperDirt runs inside SuperCollider. Here's how to interact with it:

### Starting SuperDirt

See [`START-Tidal.md`](START-Tidal.md) for the full startup script. Minimal version:

```supercollider
SuperDirt.start;
```

### Accessing SuperDirt Orbits

SuperDirt uses "orbits" (channels) for different pattern streams:

```supercollider
// After SuperDirt starts, access orbits
~d1 = ~dirt.orbits[0]; // Tidal's d1
~d2 = ~dirt.orbits[1]; // Tidal's d2
// etc.

// Control from SuperCollider
~d1.set(\gain, 0.5); // set gain for d1
~d1.set(\pan, 0.5);  // pan d1 to center
```

### Loading Custom Samples

```supercollider
// Load samples from a directory
~dirt.loadSoundFiles("/path/to/samples/*");

// Or load specific files
~dirt.loadSoundFiles("/path/to/kick.wav");
```

---

## Examples

### Simple FM Synthesis

Frequency modulation creates rich, evolving tones:

```supercollider
{ SinOsc.ar(SinOsc.kr([1, 3]).exprange(100, 2000), 0, 0.2) }.play;
```

**What you'll hear:** Two oscillators with frequency modulation creating complex, bell-like tones.

**Exercise:** Change the modulation frequencies `[1, 3]` to different values and hear how it changes.

### Simple Drum Machine

```supercollider
(
{
    var snare, bdrum, hihat;
    var tempo = 4;
    
    tempo = Impulse.ar(tempo); // tempo trigger
    snare = WhiteNoise.ar(Decay2.ar(PulseDivider.ar(tempo, 4, 2), 0.005, 0.5));
    bdrum = SinOsc.ar(Line.ar(120, 60, 1), 0, Decay2.ar(PulseDivider.ar(tempo, 4, 0), 0.005, 0.5));
    hihat = HPF.ar(WhiteNoise.ar(1), 10000) * Decay2.ar(tempo, 0.005, 0.5);
    
    Out.ar(0, (snare + bdrum + hihat) * 0.4 ! 2)
}.play;
)
```

**What you'll hear:** A simple drum pattern with kick, snare, and hi-hat.

**What it means:**
- `Impulse.ar` = generates trigger pulses
- `PulseDivider` = divides tempo to create different drum hits
- `Decay2` = envelope for drum sounds
- `WhiteNoise` = noise source for snare/hihat
- `HPF` = high-pass filter

### SynthDef with Envelope

Envelopes control how sound changes over time:

```supercollider
(
SynthDef(\pluck, {
    |freq = 440, amp = 0.2|
    var sig, env;
    sig = SinOsc.ar(freq);
    env = EnvGen.kr(Env.perc(0.01, 0.3), doneAction: 2);
    Out.ar(0, sig * env * amp);
}).add;
)

// Play it
x = Synth(\pluck, [\freq, 440]);
```

**What you'll hear:** A plucked string sound that fades out automatically.

**What it means:**
- `Env.perc` = percussive envelope (attack, decay)
- `EnvGen.kr` = generates the envelope
- `doneAction: 2` = automatically frees the synth when done

---

## Help System

SuperCollider has excellent built-in help:

### Accessing Help

```supercollider
// Open help for any class or method
SinOsc.help;
Env.help;
Server.help;

// Or press Ctrl+D (Cmd+D on Mac) with cursor on a word
```

### Browsing Examples

```supercollider
// Open examples browser
HelpBrowser.openBrowsePage;

// Or: Help → Browse
```

### Finding Classes

```supercollider
// Search for classes
HelpBrowser.openSearchPage;

// Or: Help → Search
```

---

## Common Patterns and Best Practices

### Organizing Code

**Use blocks with parentheses:**

```supercollider
(
// Multiple lines of code
var x, y;
x = 440;
y = SinOsc.ar(x);
y.play;
)
```

**Use variables for reuse:**

```supercollider
~mySynth = SynthDef(\test, { /* ... */ }).add;
~myPattern = { /* ... */ };
```

### Error Handling

**Check server status:**

```supercollider
if(s.serverRunning, {
    "Server is running".postln;
}, {
    "Server is not running. Booting...".postln;
    s.boot;
});
```

**Safe synth creation:**

```supercollider
(
if(s.serverRunning, {
    x = Synth(\sine);
}, {
    "Server not running!".postln;
});
)
```

### Performance Tips

1. **Use control rate when possible** (`.kr` instead of `.ar`)
2. **Free synths when done** (`x.free` or `doneAction: 2`)
3. **Limit polyphony** (don't create unlimited synths)
4. **Use busses for effects** (reuse effects instead of creating new ones)
5. **Monitor CPU usage** (Server → Meter)

---

## Troubleshooting

### No Sound

**Checklist:**
1. Is server booted? (`s.booted` should return `true`)
2. Is audio device selected? (Server → Options → Audio)
3. Is system volume up?
4. Are synths actually playing? (check post window for errors)

### "Node not found" Errors

**Cause:** Trying to control a synth that's already been freed.

**Solution:** Store synth references and check before controlling:
```supercollider
if(x.isPlaying, { x.set(\freq, 440) });
```

### High CPU Usage

**Solutions:**
- Use `.kr` instead of `.ar` for control signals
- Reduce number of simultaneous synths
- Increase `s.latency` (trades timing precision for CPU)
- Use more efficient UGens (unit generators)

### "Buffer not found" Errors

**Cause:** Trying to use a buffer that hasn't been allocated.

**Solution:** Allocate buffers before use:
```supercollider
b = Buffer.alloc(s, 44100, 1); // allocate buffer
// ... use buffer ...
b.free; // free when done
```

---

## Next Steps

1. **Explore the help system**: Press Ctrl+D on any UGen or class
2. **Try the examples**: Help → Browse → Examples
3. **Learn about UGens**: The building blocks of synthesis
4. **Study SynthDefs**: Create your own synthesizers
5. **Explore patterns**: SuperCollider's pattern system for sequences

---

## Integration with TidalCycles

When using TidalCycles:
- **SuperCollider** runs SuperDirt (the audio engine)
- **Tidal** sends patterns via OSC (Open Sound Control)
- **SuperDirt** receives patterns and plays samples/synths
- You can still use SuperCollider directly for custom synths or effects

See [`START-Tidal.md`](START-Tidal.md) for how to start SuperDirt.

---

## References

- **[SuperCollider Official Website](https://supercollider.github.io/)** - Primary reference
- **[SuperCollider Documentation](https://doc.sccode.org/)** - Complete API reference
- **[SuperCollider Getting Started Guide](https://doc.sccode.org/Guides/Getting-Started.html)** - Tutorial series
- **[SuperCollider Examples](https://doc.sccode.org/Guides/Examples.html)** - Code examples
- **[SuperCollider Book](https://mitpress.mit.edu/9780262049702/the-supercollider-book/)** - Comprehensive reference book
- **[sccode.org](https://sccode.org/)** - User-contributed examples and tutorials
