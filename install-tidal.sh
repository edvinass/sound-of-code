#!/bin/bash

# Installation script for TidalCycles
# Installs all required components, skipping those already installed

set -e  # Exit on error (but we'll handle errors gracefully)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Track what needs to be installed
NEEDS_XCODE=false
NEEDS_HASKELL=false
NEEDS_TIDAL=false
NEEDS_SUPERCOLLIDER=false
NEEDS_SUPERDIRT=false
NEEDS_VOWEL=false

echo -e "${BLUE}=== TidalCycles Installation Script ===${NC}\n"
echo -e "${CYAN}This script will check and install all required components.${NC}"
echo -e "${CYAN}Components that are already installed will be skipped.${NC}\n"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if directory exists
dir_exists() {
    [ -d "$1" ]
}

# Function to check if file exists
file_exists() {
    [ -f "$1" ]
}

# 1. Check Xcode Command Line Tools
echo -e "${YELLOW}[1/6] Checking Xcode Command Line Tools...${NC}"
if xcode-select -p &>/dev/null; then
    XCODE_PATH=$(xcode-select -p)
    echo -e "${GREEN}✓ Xcode Command Line Tools installed at: ${XCODE_PATH}${NC}\n"
else
    echo -e "${YELLOW}✗ Xcode Command Line Tools not found${NC}"
    NEEDS_XCODE=true
    echo -e "${YELLOW}  Will prompt for installation...${NC}\n"
fi

# 2. Check Haskell (ghcup and cabal)
echo -e "${YELLOW}[2/6] Checking Haskell (ghcup and cabal)...${NC}"
if command_exists ghcup && command_exists cabal; then
    # Source ghcup env if available
    if [ -f "$HOME/.ghcup/env" ]; then
        . "$HOME/.ghcup/env"
    fi
    
    GHC_VERSION=$(ghc --version 2>/dev/null | head -n1 || echo "unknown")
    CABAL_VERSION=$(cabal --version 2>/dev/null | head -n1 || echo "unknown")
    echo -e "${GREEN}✓ Haskell found${NC}"
    echo -e "  ${GHC_VERSION}${NC}"
    echo -e "  ${CABAL_VERSION}${NC}\n"
else
    echo -e "${YELLOW}✗ Haskell not found${NC}"
    NEEDS_HASKELL=true
    echo -e "${YELLOW}  Will install via ghcup...${NC}\n"
fi

# 3. Check TidalCycles
echo -e "${YELLOW}[3/6] Checking TidalCycles...${NC}"
if [ -f "$HOME/.ghcup/env" ]; then
    . "$HOME/.ghcup/env"
fi

if command_exists cabal; then
    # Check if Tidal is installed
    if cabal list tidal 2>/dev/null | grep -q "Installed versions:" && cabal list tidal 2>/dev/null | grep -q "\[.*installed.*\]"; then
        TIDAL_VERSION=$(cabal info tidal 2>/dev/null | grep "Versions installed:" | awk '{print $3}' || echo "unknown")
        echo -e "${GREEN}✓ TidalCycles installed (version: ${TIDAL_VERSION})${NC}\n"
    else
        echo -e "${YELLOW}✗ TidalCycles not found${NC}"
        NEEDS_TIDAL=true
        echo -e "${YELLOW}  Will install via cabal...${NC}\n"
    fi
else
    echo -e "${YELLOW}✗ Cannot check TidalCycles (cabal not found)${NC}"
    NEEDS_TIDAL=true
    echo -e "${YELLOW}  Will install after Haskell is installed...${NC}\n"
fi

# 4. Check SuperCollider
echo -e "${YELLOW}[4/6] Checking SuperCollider...${NC}"
if dir_exists "/Applications/SuperCollider.app"; then
    SC_VERSION=$(/Applications/SuperCollider.app/Contents/Resources/scsynth -v 2>/dev/null | head -n1 || echo "unknown")
    echo -e "${GREEN}✓ SuperCollider found${NC}"
    echo -e "  ${SC_VERSION}${NC}\n"
else
    echo -e "${YELLOW}✗ SuperCollider not found${NC}"
    NEEDS_SUPERCOLLIDER=true
    echo -e "${YELLOW}  Note: SuperCollider must be installed manually.${NC}"
    echo -e "${YELLOW}  Download from: https://supercollider.github.io/download${NC}\n"
fi

# 5. Check SuperDirt and Vowel quarks
echo -e "${YELLOW}[5/6] Checking SuperCollider Quarks (SuperDirt, Vowel)...${NC}"
if dir_exists "/Applications/SuperCollider.app"; then
    # Create a temporary SuperCollider script to check quarks
    TEMP_SC_SCRIPT=$(mktemp /tmp/check_quarks_XXXXXX.scd)
    
    cat > "$TEMP_SC_SCRIPT" << 'EOF'
(
var quarks = Quarks.installed;
var superdirtInstalled = quarks.any({ |q| q.name == "SuperDirt" });
var vowelInstalled = quarks.any({ |q| q.name == "Vowel" });

if (superdirtInstalled, {
    "SUPERDIRT_INSTALLED".postln;
}, {
    "SUPERDIRT_MISSING".postln;
});

if (vowelInstalled, {
    "VOWEL_INSTALLED".postln;
}, {
    "VOWEL_MISSING".postln;
});

0.exit;
)
EOF

    # Run the script via SuperCollider's sclang
    SC_LANG="/Applications/SuperCollider.app/Contents/Resources/sclang"
    if [ -f "$SC_LANG" ]; then
        QUARK_OUTPUT=$("$SC_LANG" "$TEMP_SC_SCRIPT" 2>/dev/null || true)
        
        if echo "$QUARK_OUTPUT" | grep -q "SUPERDIRT_INSTALLED"; then
            echo -e "${GREEN}✓ SuperDirt quark installed${NC}"
        else
            echo -e "${YELLOW}✗ SuperDirt quark not found${NC}"
            NEEDS_SUPERDIRT=true
        fi
        
        if echo "$QUARK_OUTPUT" | grep -q "VOWEL_INSTALLED"; then
            echo -e "${GREEN}✓ Vowel quark installed${NC}\n"
        else
            echo -e "${YELLOW}✗ Vowel quark not found${NC}\n"
            NEEDS_VOWEL=true
        fi
        
        rm -f "$TEMP_SC_SCRIPT"
    else
        echo -e "${YELLOW}⚠ Cannot check quarks (sclang not found)${NC}"
        echo -e "${YELLOW}  Will attempt to install SuperDirt and Vowel...${NC}\n"
        NEEDS_SUPERDIRT=true
        NEEDS_VOWEL=true
    fi
else
    echo -e "${YELLOW}⚠ SuperCollider not installed, cannot check quarks${NC}\n"
    NEEDS_SUPERDIRT=true
    NEEDS_VOWEL=true
fi

# 6. Check Pulsar (optional)
echo -e "${YELLOW}[6/6] Checking Pulsar (optional editor)...${NC}"
if dir_exists "/Applications/Pulsar.app"; then
    echo -e "${GREEN}✓ Pulsar found${NC}\n"
else
    echo -e "${YELLOW}⚠ Pulsar not found (optional - you can use another editor)${NC}\n"
fi

# Summary
echo -e "${BLUE}=== Installation Summary ===${NC}\n"

if [ "$NEEDS_XCODE" = false ] && [ "$NEEDS_HASKELL" = false ] && [ "$NEEDS_TIDAL" = false ] && \
   [ "$NEEDS_SUPERCOLLIDER" = false ] && [ "$NEEDS_SUPERDIRT" = false ] && [ "$NEEDS_VOWEL" = false ]; then
    echo -e "${GREEN}All components are already installed!${NC}\n"
    echo -e "${CYAN}You can run ./start-tidal.sh to start TidalCycles.${NC}\n"
    exit 0
fi

echo -e "${CYAN}Components to install:${NC}"
[ "$NEEDS_XCODE" = true ] && echo -e "  ${YELLOW}•${NC} Xcode Command Line Tools"
[ "$NEEDS_HASKELL" = true ] && echo -e "  ${YELLOW}•${NC} Haskell (ghcup, cabal)"
[ "$NEEDS_TIDAL" = true ] && echo -e "  ${YELLOW}•${NC} TidalCycles"
[ "$NEEDS_SUPERCOLLIDER" = true ] && echo -e "  ${YELLOW}•${NC} SuperCollider (manual install required)"
[ "$NEEDS_SUPERDIRT" = true ] && echo -e "  ${YELLOW}•${NC} SuperDirt quark"
[ "$NEEDS_VOWEL" = true ] && echo -e "  ${YELLOW}•${NC} Vowel quark"
echo ""

# Ask for confirmation
read -p "Proceed with installation? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installation cancelled.${NC}"
    exit 0
fi

echo ""

# Install Xcode Command Line Tools
if [ "$NEEDS_XCODE" = true ]; then
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Step: Installing Xcode Command Line Tools${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${CYAN}Xcode Command Line Tools are required for building software.${NC}\n"
    echo -e "${YELLOW}This will open a system dialog.${NC}"
    echo -e "${CYAN}Steps:${NC}"
    echo -e "  1. A dialog will appear asking to install Command Line Tools"
    echo -e "  2. Click ${GREEN}'Install'${NC}"
    echo -e "  3. Accept the license agreement"
    echo -e "  4. Wait for installation (20-30 minutes)"
    echo -e "  5. Come back here and press Enter when done\n"
    
    read -p "Press Enter to open the installation dialog... "
    
    /usr/bin/xcode-select --install 2>/dev/null || {
        echo -e "${GREEN}✓ Installation dialog opened${NC}"
    }
    
    echo -e "\n${YELLOW}⚠ Installation is running in the background.${NC}"
    echo -e "${CYAN}Please complete the installation dialog, then come back here.${NC}\n"
    read -p "Press Enter when Xcode Command Line Tools installation is complete... "
    
    # Verify installation
    if xcode-select -p &>/dev/null; then
        echo -e "${GREEN}✓ Xcode Command Line Tools verified${NC}\n"
    else
        echo -e "${YELLOW}⚠ Could not verify installation. Continuing anyway...${NC}\n"
    fi
fi

# Install Haskell via ghcup
if [ "$NEEDS_HASKELL" = true ]; then
    echo -e "${BLUE}Installing Haskell (ghcup)...${NC}"
    echo -e "${YELLOW}This may take 20-30 minutes...${NC}"
    
    # Install ghcup
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh || {
        echo -e "${RED}Error: Failed to install ghcup${NC}"
        echo -e "${YELLOW}You may need to install it manually.${NC}"
        exit 1
    }
    
    # Source ghcup env
    if [ -f "$HOME/.ghcup/env" ]; then
        . "$HOME/.ghcup/env"
        # Add to shell config
        if [ -f "$HOME/.zshrc" ]; then
            if ! grep -q ".ghcup/env" "$HOME/.zshrc"; then
                echo '. $HOME/.ghcup/env' >> "$HOME/.zshrc"
            fi
        elif [ -f "$HOME/.bashrc" ]; then
            if ! grep -q ".ghcup/env" "$HOME/.bashrc"; then
                echo '. $HOME/.ghcup/env' >> "$HOME/.bashrc"
            fi
        fi
    fi
    
    echo -e "${GREEN}✓ Haskell (ghcup) installed${NC}"
    echo -e "${YELLOW}Note: You may need to restart your terminal or run: source ~/.ghcup/env${NC}\n"
fi

# Install TidalCycles
if [ "$NEEDS_TIDAL" = true ]; then
    echo -e "${BLUE}Installing TidalCycles...${NC}"
    echo -e "${YELLOW}This may take a while...${NC}"
    
    # Source ghcup env if available
    if [ -f "$HOME/.ghcup/env" ]; then
        . "$HOME/.ghcup/env"
    fi
    
    if ! command_exists cabal; then
        echo -e "${RED}Error: cabal not found. Please install Haskell first.${NC}"
        exit 1
    fi
    
    cabal update
    cabal v1-install tidal || {
        echo -e "${RED}Error: Failed to install TidalCycles${NC}"
        exit 1
    }
    
    echo -e "${GREEN}✓ TidalCycles installed${NC}\n"
fi

# Install SuperCollider quarks (SuperDirt and Vowel)
if [ "$NEEDS_SUPERDIRT" = true ] || [ "$NEEDS_VOWEL" = true ]; then
    if ! dir_exists "/Applications/SuperCollider.app"; then
        echo -e "${RED}Error: SuperCollider must be installed before installing quarks.${NC}"
        echo -e "${YELLOW}Please install SuperCollider from: https://supercollider.github.io/download${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Step: Installing SuperCollider Quarks${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${CYAN}Quark installation requires SuperCollider to be running.${NC}"
    echo -e "${CYAN}I'll guide you through this step-by-step.${NC}\n"
    
    # Check if install-quarks.scd exists in the repo
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    QUARK_SCRIPT="${SCRIPT_DIR}/install-quarks.scd"
    
    if [ "$NEEDS_VOWEL" = true ]; then
        echo -e "${YELLOW}⚠ Vowel quark is missing (required for SuperDirt)${NC}"
    fi
    if [ "$NEEDS_SUPERDIRT" = true ]; then
        echo -e "${YELLOW}⚠ SuperDirt quark is missing${NC}"
    fi
    echo ""
    
    echo -e "${CYAN}Method 1: Using the installation script (Recommended)${NC}\n"
    echo -e "${YELLOW}Step 1:${NC} I'll open SuperCollider for you..."
    read -p "Press Enter to open SuperCollider... "
    
    # Open SuperCollider
    open -a SuperCollider
    sleep 4
    
    if [ -f "$QUARK_SCRIPT" ]; then
        echo -e "${YELLOW}Step 2:${NC} Opening the installation script in SuperCollider..."
        open -a SuperCollider "$QUARK_SCRIPT"
        sleep 2
        
        echo -e "${GREEN}✓ Installation script opened in SuperCollider${NC}\n"
        echo -e "${CYAN}Now follow these steps in SuperCollider:${NC}\n"
        echo -e "${YELLOW}  Step 3:${NC} Select all text in the editor (${CYAN}Cmd+A${NC})"
        echo -e "${YELLOW}  Step 4:${NC} Run the code (${CYAN}Cmd+Enter${NC})"
        echo -e "${YELLOW}  Step 5:${NC} Watch the post window (bottom) for messages like:"
        echo -e "         ${GREEN}✓ SuperDirt is already installed${NC}"
        echo -e "         ${GREEN}✓ Vowel installed${NC}"
        echo -e "         ${GREEN}compiling class library...${NC}\n"
        echo -e "${CYAN}The installation will:${NC}"
        if [ "$NEEDS_SUPERDIRT" = true ]; then
            echo -e "  • Install SuperDirt quark"
        fi
        if [ "$NEEDS_VOWEL" = true ]; then
            echo -e "  • Install Vowel quark"
        fi
        echo -e "  • Recompile the class library (this takes 10-30 seconds)\n"
    else
        echo -e "${YELLOW}Installation script not found. Using manual method...${NC}\n"
        echo -e "${CYAN}In SuperCollider, paste and run this code:${NC}\n"
        
        if [ "$NEEDS_VOWEL" = true ]; then
            echo -e "${GREEN}Quarks.checkForUpdates({Quarks.install(\"Vowel\"); thisProcess.recompile()})${NC}\n"
        fi
        if [ "$NEEDS_SUPERDIRT" = true ]; then
            echo -e "${GREEN}Quarks.checkForUpdates({Quarks.install(\"SuperDirt\", \"v1.7.3\"); thisProcess.recompile()})${NC}\n"
        fi
        
        echo -e "${CYAN}Steps:${NC}"
        echo -e "  1. Copy the code above"
        echo -e "  2. Paste it into SuperCollider's editor"
        echo -e "  3. Select the line and press ${CYAN}Cmd+Enter${NC}"
        echo -e "  4. Wait for compilation to complete\n"
    fi
    
    echo -e "${BLUE}───────────────────────────────────────────────────────────${NC}"
    echo -e "${YELLOW}⚠ Important: Wait for compilation to finish!${NC}"
    echo -e "${CYAN}You'll see messages in the post window. When you see:${NC}"
    echo -e "${GREEN}  *** Welcome to SuperCollider 3.x.x ***${NC}"
    echo -e "${CYAN}compilation is complete.${NC}\n"
    echo -e "${BLUE}───────────────────────────────────────────────────────────${NC}\n"
    
    read -p "Press Enter when compilation is complete and you've restarted SuperCollider... "
    
    # Verify installation
    echo -e "\n${YELLOW}Verifying installation...${NC}"
    sleep 2
    
    # Create verification script
    TEMP_VERIFY_SCRIPT=$(mktemp /tmp/verify_quarks_XXXXXX.scd)
    cat > "$TEMP_VERIFY_SCRIPT" << 'EOF'
(
var quarks = Quarks.installed;
var superdirtInstalled = quarks.any({ |q| q.name == "SuperDirt" });
var vowelInstalled = quarks.any({ |q| q.name == "Vowel" });

if (superdirtInstalled, {
    "SUPERDIRT_OK".postln;
}, {
    "SUPERDIRT_MISSING".postln;
});

if (vowelInstalled, {
    "VOWEL_OK".postln;
}, {
    "VOWEL_MISSING".postln;
});

0.exit;
)
EOF

    SC_LANG="/Applications/SuperCollider.app/Contents/Resources/sclang"
    if [ -f "$SC_LANG" ]; then
        VERIFY_OUTPUT=$("$SC_LANG" "$TEMP_VERIFY_SCRIPT" 2>/dev/null || true)
        rm -f "$TEMP_VERIFY_SCRIPT"
        
        ALL_OK=true
        if [ "$NEEDS_SUPERDIRT" = true ] && ! echo "$VERIFY_OUTPUT" | grep -q "SUPERDIRT_OK"; then
            echo -e "${RED}✗ SuperDirt still not installed${NC}"
            ALL_OK=false
        elif [ "$NEEDS_SUPERDIRT" = true ]; then
            echo -e "${GREEN}✓ SuperDirt verified${NC}"
        fi
        
        if [ "$NEEDS_VOWEL" = true ] && ! echo "$VERIFY_OUTPUT" | grep -q "VOWEL_OK"; then
            echo -e "${RED}✗ Vowel still not installed${NC}"
            ALL_OK=false
        elif [ "$NEEDS_VOWEL" = true ]; then
            echo -e "${GREEN}✓ Vowel verified${NC}"
        fi
        
        if [ "$ALL_OK" = true ]; then
            echo -e "${GREEN}✓ All quarks installed successfully!${NC}\n"
        else
            echo -e "${YELLOW}⚠ Some quarks are still missing.${NC}"
            echo -e "${YELLOW}Please try the installation again in SuperCollider.${NC}\n"
            read -p "Press Enter to continue anyway, or Ctrl+C to exit and try again... "
        fi
    else
        echo -e "${YELLOW}⚠ Could not verify installation automatically${NC}"
        echo -e "${CYAN}Please verify manually in SuperCollider:${NC}"
        echo -e "${CYAN}  Language → Quarks → Check for SuperDirt and Vowel${NC}\n"
    fi
    
    echo ""
fi

# Final summary
echo -e "${BLUE}=== Installation Complete ===${NC}\n"
echo -e "${GREEN}Installation finished!${NC}\n"
echo -e "${CYAN}Next steps:${NC}"
echo -e "1. If you installed Haskell, restart your terminal or run: ${YELLOW}source ~/.ghcup/env${NC}"
echo -e "2. If you installed SuperCollider quarks, restart SuperCollider"
echo -e "3. Run ${YELLOW}./start-tidal.sh${NC} to start TidalCycles"
echo ""
