#!/bin/bash

# Uninstall script for TidalCycles
# Removes all components installed by install.sh

set -e  # Exit on error (but we'll handle errors gracefully)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}TidalCycles Uninstall Script${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

echo -e "${RED}⚠ WARNING: This will remove all TidalCycles components!${NC}\n"
echo -e "${CYAN}This script will remove:${NC}"
echo -e "  • TidalCycles (Haskell package)"
echo -e "  • SuperCollider application and all related files"
echo -e "  • SuperCollider startup file and configuration"
echo -e "  • SuperDirt and Vowel quarks"
echo -e "  • All SuperCollider quarks and extensions"
echo -e "  • Pulsar editor (if installed via Homebrew)"
echo -e "  • TidalCycles plugin for Pulsar"
echo -e "  • Command-line aliases and symlinks"
echo -e "  • Haskell/ghcup (optional - see below)\n"

echo -e "${YELLOW}Note:${NC}"
echo -e "  • ${CYAN}Xcode Command Line Tools${NC} will NOT be removed (system tool)"
echo -e "  • ${CYAN}Haskell/ghcup${NC} removal is optional (may be used by other projects)\n"

# Ask for confirmation
read -p "Are you sure you want to continue? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo -e "${YELLOW}Uninstall cancelled.${NC}"
    exit 0
fi

echo ""

# Helper functions
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

dir_exists() {
    [ -d "$1" ]
}

file_exists() {
    [ -f "$1" ]
}

# Track what was found/removed
FOUND_TIDAL=false
FOUND_STARTUP=false
FOUND_QUARKS=false
FOUND_SUPERCOLLIDER=false
FOUND_PULSAR=false
FOUND_PLUGIN=false
FOUND_HASKELL=false

# 1. Remove TidalCycles
echo -e "${BLUE}[1/7] Removing TidalCycles...${NC}"
if command_exists cabal; then
    # Source ghcup env if available
    if [ -f "$HOME/.ghcup/env" ]; then
        . "$HOME/.ghcup/env"
    fi
    
    if cabal list tidal 2>/dev/null | grep -q "Installed versions:" && cabal list tidal 2>/dev/null | grep -q "\[.*installed.*\]"; then
        FOUND_TIDAL=true
        echo -e "${YELLOW}Uninstalling TidalCycles via cabal...${NC}"
        cabal v1-uninstall tidal 2>/dev/null || {
            echo -e "${YELLOW}⚠ Could not uninstall via cabal (may need manual removal)${NC}"
        }
        echo -e "${GREEN}✓ TidalCycles removed${NC}\n"
    else
        echo -e "${CYAN}  TidalCycles not found (already removed)${NC}\n"
    fi
else
    echo -e "${CYAN}  cabal not found (TidalCycles may not be installed)${NC}\n"
fi

# 2. Remove SuperCollider startup file
echo -e "${BLUE}[2/7] Removing SuperCollider startup file...${NC}"
SUPERCOLLIDER_STARTUP_FILE="$HOME/Library/Application Support/SuperCollider/startup.scd"
if [ -f "$SUPERCOLLIDER_STARTUP_FILE" ]; then
    FOUND_STARTUP=true
    # Check if it's our startup file (contains SuperDirt)
    if grep -q "SuperDirt" "$SUPERCOLLIDER_STARTUP_FILE" 2>/dev/null; then
        echo -e "${YELLOW}Removing SuperCollider startup file...${NC}"
        rm -f "$SUPERCOLLIDER_STARTUP_FILE"
        echo -e "${GREEN}✓ SuperCollider startup file removed${NC}\n"
    else
        echo -e "${CYAN}  Startup file exists but doesn't appear to be from this installer${NC}"
        echo -e "${CYAN}  Keeping it (you can remove manually if needed)${NC}\n"
    fi
else
    echo -e "${CYAN}  Startup file not found${NC}\n"
fi

# 3. Remove SuperCollider and all related files
echo -e "${BLUE}[3/8] Removing SuperCollider and all related files...${NC}"
if dir_exists "/Applications/SuperCollider.app"; then
    FOUND_SUPERCOLLIDER=true
    
    # First, try to remove quarks programmatically (optional, may fail if SuperCollider is running)
    echo -e "${YELLOW}Attempting to remove quarks...${NC}"
    # Clean up any old temp files first
    rm -f /tmp/uninstall_quarks_*.scd 2>/dev/null || true
    
    # Create uninstall script
    TEMP_UNINSTALL_SCRIPT=$(mktemp /tmp/uninstall_quarks_XXXXXX.scd 2>/dev/null || echo "/tmp/uninstall_quarks_$$.scd")
    
    cat > "$TEMP_UNINSTALL_SCRIPT" << 'EOF'
(
var quarks = Quarks.installed;
var superdirtInstalled = quarks.any({ |q| q.name == "SuperDirt" });
var vowelInstalled = quarks.any({ |q| q.name == "Vowel" });

if (superdirtInstalled, {
    "SUPERDIRT_FOUND".postln;
}, {
    "SUPERDIRT_NOT_FOUND".postln;
});

if (vowelInstalled, {
    "VOWEL_FOUND".postln;
}, {
    "VOWEL_NOT_FOUND".postln;
});

0.exit;
)
EOF

    SC_LANG="/Applications/SuperCollider.app/Contents/Resources/sclang"
    if [ -f "$SC_LANG" ]; then
        QUARK_OUTPUT=$("$SC_LANG" "$TEMP_UNINSTALL_SCRIPT" 2>/dev/null || true)
        rm -f "$TEMP_UNINSTALL_SCRIPT"
        
        if echo "$QUARK_OUTPUT" | grep -q "SUPERDIRT_FOUND\|VOWEL_FOUND"; then
            FOUND_QUARKS=true
            echo -e "${CYAN}  Quarks found (will be removed with SuperCollider files)${NC}"
        fi
    fi
    rm -f "$TEMP_UNINSTALL_SCRIPT" 2>/dev/null || true
    
    # Remove SuperCollider application
    echo -e "${YELLOW}Removing SuperCollider application...${NC}"
    rm -rf "/Applications/SuperCollider.app" || {
        echo -e "${YELLOW}⚠ Could not remove SuperCollider.app${NC}"
        echo -e "${CYAN}  It may be in use. Please quit SuperCollider and try again.${NC}"
        echo -e "${CYAN}  Or remove manually: ${YELLOW}rm -rf /Applications/SuperCollider.app${NC}\n"
        read -p "Press Enter to continue (SuperCollider will be skipped)... "
    }
    
    if [ ! -d "/Applications/SuperCollider.app" ]; then
        echo -e "${GREEN}✓ SuperCollider application removed${NC}\n"
    fi
    
    # Remove SuperCollider configuration and data directories
    echo -e "${YELLOW}Removing SuperCollider configuration and data...${NC}"
    
    SC_SUPPORT_DIR="$HOME/Library/Application Support/SuperCollider"
    if [ -d "$SC_SUPPORT_DIR" ]; then
        rm -rf "$SC_SUPPORT_DIR" || {
            echo -e "${YELLOW}⚠ Could not remove all SuperCollider support files${NC}"
        }
        echo -e "${GREEN}✓ SuperCollider support directory removed${NC}"
    fi
    
    # Remove SuperCollider preferences
    SC_PREFS=(
        "$HOME/Library/Preferences/com.audiosynth.supercollider.plist"
        "$HOME/Library/Preferences/org.supercollider.SuperCollider.plist"
        "$HOME/Library/Preferences/net.sourceforge.supercollider.plist"
    )
    
    for pref in "${SC_PREFS[@]}"; do
        if [ -f "$pref" ]; then
            rm -f "$pref"
            echo -e "${GREEN}✓ Removed preferences: $(basename "$pref")${NC}"
        fi
    done
    
    # Remove SuperCollider caches
    SC_CACHE_DIR="$HOME/Library/Caches/SuperCollider"
    if [ -d "$SC_CACHE_DIR" ]; then
        rm -rf "$SC_CACHE_DIR"
        echo -e "${GREEN}✓ SuperCollider cache removed${NC}"
    fi
    
    # Remove SuperCollider saved state (if exists)
    SC_SAVED_STATE="$HOME/Library/Saved Application State/com.audiosynth.supercollider.savedState"
    if [ -d "$SC_SAVED_STATE" ]; then
        rm -rf "$SC_SAVED_STATE"
        echo -e "${GREEN}✓ SuperCollider saved state removed${NC}"
    fi
    
    # Remove any SuperCollider logs
    SC_LOGS=(
        "$HOME/Library/Logs/SuperCollider"
        "$HOME/.supercollider"
    )
    
    for log_dir in "${SC_LOGS[@]}"; do
        if [ -d "$log_dir" ]; then
            rm -rf "$log_dir"
            echo -e "${GREEN}✓ Removed: $log_dir${NC}"
        fi
    done
    
    echo -e "${GREEN}✓ SuperCollider and all related files removed${NC}\n"
else
    echo -e "${CYAN}  SuperCollider not found${NC}\n"
fi

# 4. Remove Pulsar (if installed via Homebrew)
echo -e "${BLUE}[4/8] Removing Pulsar...${NC}"
if dir_exists "/Applications/Pulsar.app"; then
    FOUND_PULSAR=true
    if command_exists brew; then
        # Check if installed via Homebrew
        if brew list --cask pulsar &>/dev/null 2>&1; then
            echo -e "${YELLOW}Removing Pulsar via Homebrew...${NC}"
            brew uninstall --cask pulsar || {
                echo -e "${YELLOW}⚠ Could not uninstall via Homebrew${NC}"
                echo -e "${CYAN}  You may need to remove manually from /Applications${NC}\n"
            }
            echo -e "${GREEN}✓ Pulsar removed${NC}\n"
        else
            echo -e "${CYAN}  Pulsar found but not installed via Homebrew${NC}"
            echo -e "${CYAN}  Please remove manually from /Applications/Pulsar.app${NC}\n"
        fi
    else
        echo -e "${CYAN}  Pulsar found but Homebrew not available${NC}"
        echo -e "${CYAN}  Please remove manually from /Applications/Pulsar.app${NC}\n"
    fi
else
    echo -e "${CYAN}  Pulsar not found${NC}\n"
fi

# 5. Remove TidalCycles plugin for Pulsar
echo -e "${BLUE}[5/8] Removing TidalCycles plugin for Pulsar...${NC}"
PULSAR_PLUGIN_DIR="$HOME/.pulsar/packages/tidalcycles"
if [ -d "$PULSAR_PLUGIN_DIR" ]; then
    FOUND_PLUGIN=true
    echo -e "${YELLOW}Removing TidalCycles plugin...${NC}"
    rm -rf "$PULSAR_PLUGIN_DIR"
    echo -e "${GREEN}✓ TidalCycles plugin removed${NC}\n"
else
    echo -e "${CYAN}  Plugin not found${NC}\n"
fi

# 6. Remove command-line aliases and symlinks
echo -e "${BLUE}[6/8] Removing command-line aliases and symlinks...${NC}"

# Remove symlink
if [ -L "/usr/local/bin/pulsar" ]; then
    echo -e "${YELLOW}Removing /usr/local/bin/pulsar symlink...${NC}"
    rm -f "/usr/local/bin/pulsar" 2>/dev/null || {
        echo -e "${YELLOW}⚠ Could not remove symlink (may need sudo)${NC}"
        echo -e "${CYAN}  Run: ${YELLOW}sudo rm /usr/local/bin/pulsar${NC}\n"
    }
    echo -e "${GREEN}✓ Symlink removed${NC}\n"
else
    echo -e "${CYAN}  Symlink not found${NC}\n"
fi

# Remove aliases from shell config
SHELL_CONFIGS=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile")
REMOVED_ALIAS=false

for config in "${SHELL_CONFIGS[@]}"; do
    if [ -f "$config" ] && grep -q "alias pulsar=" "$config"; then
        REMOVED_ALIAS=true
        echo -e "${YELLOW}Removing pulsar alias from $config...${NC}"
        # Remove the alias line and any comment lines above it
        sed -i.bak '/# Pulsar editor alias/,/^alias pulsar=/d' "$config" 2>/dev/null || {
            # Fallback: just remove the alias line
            sed -i.bak '/^alias pulsar=/d' "$config" 2>/dev/null || {
                echo -e "${YELLOW}⚠ Could not remove alias from $config${NC}"
                echo -e "${CYAN}  Please remove manually${NC}\n"
            }
        }
        rm -f "${config}.bak" 2>/dev/null || true
        echo -e "${GREEN}✓ Alias removed from $config${NC}\n"
    fi
done

if [ "$REMOVED_ALIAS" = false ]; then
    echo -e "${CYAN}  No aliases found${NC}\n"
fi

# 7. Optional: Remove Haskell/ghcup
echo -e "${BLUE}[7/8] Haskell/ghcup removal (optional)...${NC}"
if [ -d "$HOME/.ghcup" ] || command_exists ghcup; then
    FOUND_HASKELL=true
    echo -e "${YELLOW}Haskell/ghcup is installed.${NC}"
    echo -e "${CYAN}Note: This may be used by other projects.${NC}\n"
    read -p "Remove Haskell/ghcup? (yes/no): " -r
    echo
    if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        echo -e "${YELLOW}Removing Haskell/ghcup...${NC}"
        
        # Remove ghcup directory
        if [ -d "$HOME/.ghcup" ]; then
            rm -rf "$HOME/.ghcup"
            echo -e "${GREEN}✓ Removed ~/.ghcup directory${NC}"
        fi
        
        # Remove from shell configs
        for config in "${SHELL_CONFIGS[@]}"; do
            if [ -f "$config" ] && grep -q ".ghcup/env" "$config"; then
                echo -e "${YELLOW}Removing ghcup from $config...${NC}"
                sed -i.bak '/\.ghcup\/env/d' "$config" 2>/dev/null || true
                rm -f "${config}.bak" 2>/dev/null || true
                echo -e "${GREEN}✓ Removed from $config${NC}"
            fi
        done
        
        echo -e "${GREEN}✓ Haskell/ghcup removed${NC}\n"
    else
        echo -e "${CYAN}  Keeping Haskell/ghcup${NC}\n"
    fi
else
    echo -e "${CYAN}  Haskell/ghcup not found${NC}\n"
fi

# Final summary
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Uninstall Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

REMOVED_ANY=false
[ "$FOUND_TIDAL" = true ] && echo -e "${GREEN}✓${NC} TidalCycles removed" && REMOVED_ANY=true
[ "$FOUND_STARTUP" = true ] && echo -e "${GREEN}✓${NC} SuperCollider startup file removed" && REMOVED_ANY=true
[ "$FOUND_SUPERCOLLIDER" = true ] && echo -e "${GREEN}✓${NC} SuperCollider and all related files removed" && REMOVED_ANY=true
[ "$FOUND_PULSAR" = true ] && echo -e "${GREEN}✓${NC} Pulsar removed" && REMOVED_ANY=true
[ "$FOUND_PLUGIN" = true ] && echo -e "${GREEN}✓${NC} TidalCycles plugin removed" && REMOVED_ANY=true
[ "$REMOVED_ALIAS" = true ] && echo -e "${GREEN}✓${NC} Command-line aliases removed" && REMOVED_ANY=true

if [ "$REMOVED_ANY" = false ] && [ "$FOUND_HASKELL" = false ]; then
    echo -e "${CYAN}No TidalCycles components were found to remove.${NC}\n"
elif [ "$REMOVED_ANY" = false ]; then
    echo -e "${CYAN}No TidalCycles components were found (except Haskell/ghcup).${NC}\n"
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Manual Cleanup (if needed):${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}\n"

# Check if anything still needs manual cleanup
NEEDS_MANUAL=false

if dir_exists "/Applications/SuperCollider.app"; then
    NEEDS_MANUAL=true
    echo -e "${YELLOW}SuperCollider is still installed (could not be removed automatically).${NC}"
    echo -e "${CYAN}To remove manually:${NC}"
    echo -e "  1. Quit SuperCollider if it's running"
    echo -e "  2. Run: ${YELLOW}rm -rf /Applications/SuperCollider.app${NC}\n"
fi

if dir_exists "/Applications/Pulsar.app"; then
    NEEDS_MANUAL=true
    echo -e "${YELLOW}Pulsar is still installed (could not be removed automatically).${NC}"
    echo -e "${CYAN}To remove manually:${NC}"
    echo -e "  Drag /Applications/Pulsar.app to Trash\n"
fi

# Check for any remaining SuperCollider files
if [ -d "$HOME/Library/Application Support/SuperCollider" ]; then
    NEEDS_MANUAL=true
    echo -e "${YELLOW}Some SuperCollider files may still exist.${NC}"
    echo -e "${CYAN}To remove manually:${NC}"
    echo -e "  ${YELLOW}rm -rf \"$HOME/Library/Application Support/SuperCollider\"${NC}\n"
fi

if [ "$NEEDS_MANUAL" = false ]; then
    echo -e "${GREEN}All components have been removed automatically!${NC}\n"
fi

echo -e "${GREEN}Uninstall complete!${NC}\n"
echo -e "${CYAN}Note: You may need to restart your terminal for changes to take effect.${NC}\n"
