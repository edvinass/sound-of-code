// SuperCollider script to install SuperDirt and Vowel quarks
// Run this in SuperCollider: select all and press Cmd+Enter

(
var quarks = Quarks.installed;
var superdirtInstalled = quarks.any({ |q| q.name == "SuperDirt" });
var vowelInstalled = quarks.any({ |q| q.name == "Vowel" });

"=== Checking SuperCollider Quarks ===".postln;
"".postln;

if (superdirtInstalled, {
    "✓ SuperDirt is already installed".postln;
}, {
    "Installing SuperDirt...".postln;
    Quarks.checkForUpdates({
        Quarks.install("SuperDirt", "v1.7.3");
        "✓ SuperDirt installed".postln;
        thisProcess.recompile();
    });
});

if (vowelInstalled, {
    "✓ Vowel is already installed".postln;
}, {
    "Installing Vowel...".postln;
    Quarks.checkForUpdates({
        Quarks.install("Vowel");
        "✓ Vowel installed".postln;
        thisProcess.recompile();
    });
});

"".postln;
"=== Installation complete ===".postln;
"Please wait for compilation to finish, then restart SuperCollider.".postln;
)
