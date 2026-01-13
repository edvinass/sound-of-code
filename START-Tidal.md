# Starting TidalCycles

This guide explains how to launch TidalCycles and get your first sounds playing.

> **Source**: This guide is based on the [official TidalCycles "Start Tidal" documentation](https://tidalcycles.org/docs/getting-started/tidal_start).

## Understanding the Components

TidalCycles is not a single monolithic application. Think of it as an interconnection between several components:

### Pattern Library
1. **Your text editor** (Pulsar, VS Code, etc.)
2. **The interpreter** (Haskell)

### Audio Engine
1. **SuperDirt** - Receives messages and turns them into sound
2. **SuperCollider** - Sends sound to your speakers/headphones

## The Two-Step Launch Process

**Always follow these two steps in order:**

1. **Start SuperCollider** and then **SuperDirt** inside of it
2. **Start Tidal Cycles** from your text editor

---

## Step 1: Start SuperCollider and SuperDirt

### Quick Start (Minimal)

The simplest way to start SuperDirt:

```supercollider
SuperDirt.start;
```

**What to do:**
- Open **SuperCollider** application
- Paste the line above in the editor
- Select the text and press **Ctrl+Enter** (or **Cmd+Enter** on Mac)

**What to expect:**
- This uses SuperCollider's default server options
- May not be optimal for your audio setup
- Good for quick testing

### Recommended Startup Script

For better audio configuration and performance, use this script:

```supercollider
(
s.reboot { // server options are only updated on reboot
    // configure the sound server: here you could add hardware specific options
    // see http://doc.sccode.org/Classes/ServerOptions.html
    s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
    s.options.memSize = 8192 * 32; // increase this if you get "alloc failed" messages
    s.options.numWireBufs = 64; // increase this if you get "exceeded number of interconnect buffers" messages 
    s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
    s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
    s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
    // boot the server and start SuperDirt
    s.waitForBoot {
        ~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
        ~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
        // for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
        // s.sync; // optionally: wait for samples to be read
        ~dirt.start(57120, 0 ! 12);   // start listening on port 57120, create two busses each sending audio to channel 0

        // optional, needed for convenient access from sclang:
        (
            ~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
            ~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
            ~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
            ~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
        );
    };

    s.latency = 0.3; // increase this if you get "late" messages
};
);
```

**What to do:**
- Open **SuperCollider**
- Paste the entire script above
- Select all the text
- Press **Ctrl+Enter** (or **Cmd+Enter** on Mac)

**What to expect:**
- After a few seconds, you should see in the logs:
  ```
  SuperDirt: listening to Tidal on port 57120
  ```
- This means SuperDirt is ready to receive patterns from Tidal

**Common failure modes:**
- **No sound**: Check SuperCollider's audio device settings (Server → Options → Audio)
- **"alloc failed" messages**: Increase `s.options.memSize` in the script
- **"too many nodes" messages**: Increase `s.options.maxNodes` in the script
- **"late" messages**: Increase `s.latency` value in the script

### Automate Startup (Boot SuperDirt Every Time)

To avoid running the startup script manually each time:

1. In SuperCollider, click **File → Open startup file**
2. Paste the recommended startup script above
3. Save the file

**Result:** SuperCollider will automatically boot SuperDirt every time you launch it.

---

## Step 2: Start Tidal Cycles from Your Editor

This guide assumes you're using **Pulsar** (previously Atom). For other editors, see the [TidalCycles editor documentation](https://tidalcycles.org/docs/getting-started/get_a_text_editor).

### Steps

1. **Start Pulsar** application

2. **Create a new file** and save it with a `.tidal` extension
   - Example: `test.tidal` or `my-pattern.tidal`

3. **Boot Tidal Cycles:**
   - Open the **Packages** menu
   - Select **TidalCycles → Boot Tidal Cycles**
   - A small window will open at the bottom showing the `t>` prompt

**What to expect:**
- The `t>` prompt appears (this is the Tidal REPL)
- No error messages should appear
- If you see errors, check the troubleshooting section below

### Your First Pattern

Type this pattern in your `.tidal` file:

```haskell
d1 $ sound "bd sn"
```

**What to do:**
- Place cursor on the line
- Press **Shift+Enter** to evaluate (or **Ctrl+Enter** for multiple lines)

**What you should hear:**
- A kick drum (`bd`) followed by a snare (`sn`) repeating in a loop
- If you hear sound, **congratulations!** 🎉 Tidal is working

**Common failure modes:**
- **No sound**: Make sure SuperDirt is running and shows "listening to Tidal on port 57120"
- **Error messages**: Check that Tidal booted successfully (look for `t>` prompt)
- **Pattern not evaluating**: Make sure you're pressing Shift+Enter, not just Enter

---

## Troubleshooting

### SuperDirt Not Starting

**Symptoms:**
- No "listening to Tidal" message
- Error messages in SuperCollider

**Solutions:**
1. Check that SuperDirt is installed (Language → Quarks → SuperDirt should be checked)
2. Try restarting SuperCollider
3. Check SuperCollider's post window for specific error messages
4. Verify audio device is selected (Server → Options → Audio)

### Tidal Can't Connect to SuperDirt

**Symptoms:**
- Tidal boots but patterns don't make sound
- Connection errors in Tidal

**Solutions:**
1. **Verify SuperDirt is listening**: Check SuperCollider logs for "listening to Tidal on port 57120"
2. **Check port number**: Default is 57120, make sure both Tidal and SuperDirt use the same port
3. **Restart both**: Quit and restart SuperCollider, then reboot Tidal in your editor
4. **Check firewall**: Ensure port 57120 isn't blocked

### Audio Issues

**Symptoms:**
- No sound output
- Distorted/clipping audio
- Dropouts or glitches

**Solutions:**
1. **Check audio device**: SuperCollider → Server → Options → Audio → select your output device
2. **Adjust latency**: Increase `s.latency` in startup script (try 0.5 or higher)
3. **Increase buffers**: Increase `s.options.numBuffers` if loading many samples
4. **Check system audio**: Ensure your system volume isn't muted

### Pattern Syntax Errors

**Symptoms:**
- Tidal shows parse errors
- Patterns don't evaluate

**Solutions:**
1. **Check syntax**: Ensure proper spacing and quotes
2. **Verify Tidal booted**: Look for `t>` prompt
3. **Check file extension**: File must end in `.tidal`
4. **Restart Tidal**: Packages → TidalCycles → Boot Tidal Cycles

---

## Next Steps

Once you have sound working:

1. **Try more patterns**: See `agents.md` Phase 1 curriculum for basic patterns
2. **Explore transformations**: Try `fast`, `slow`, `rev`, `jux` on your patterns
3. **Learn control parameters**: Experiment with `gain`, `pan`, `speed`, `cut`
4. **Join the community**: Get help on [Discord](https://discord.gg/tidalcycles) or [Discourse forums](https://club.tidalcycles.org/)

---

## Alternative Components

While **Pulsar** and **SuperDirt** are the standard setup, you have alternatives:

- **Text editors**: VS Code, Vim, Emacs (see [Get a Text Editor](https://tidalcycles.org/docs/getting-started/get_a_text_editor))
- **Audio engines**: Alternative synths and samplers (see TidalCycles documentation sidebar)

---

## References

- **[TidalCycles Start Tidal (Official Source)](https://tidalcycles.org/docs/getting-started/tidal_start)** - Primary reference for this guide
- [TidalCycles Official Docs](https://tidalcycles.org/docs/)
- [SuperCollider ServerOptions Documentation](http://doc.sccode.org/Classes/ServerOptions.html)
- [TidalCycles Community](https://club.tidalcycles.org/)
