#!/bin/bash

# Startup script for TidalCycles
# Automates launching SuperCollider with SuperDirt and Pulsar

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STARTUP_SCD_SOURCE="${SCRIPT_DIR}/startup.scd"
SUPERCOLLIDER_STARTUP_DIR="${HOME}/Library/Application Support/SuperCollider"
SUPERCOLLIDER_STARTUP_FILE="${SUPERCOLLIDER_STARTUP_DIR}/startup.scd"

echo -e "${BLUE}=== TidalCycles Startup Script ===${NC}\n"

# Check if SuperCollider is installed
echo -e "${YELLOW}Checking for SuperCollider...${NC}"
if [ ! -d "/Applications/SuperCollider.app" ]; then
    echo -e "${RED}Error: SuperCollider is not installed.${NC}"
    echo "Please install SuperCollider first. See INSTALL-macOS.md for instructions."
    exit 1
fi
echo -e "${GREEN}✓ SuperCollider found${NC}\n"

# Check if startup.scd source file exists
if [ ! -f "${STARTUP_SCD_SOURCE}" ]; then
    echo -e "${RED}Error: startup.scd not found in script directory.${NC}"
    echo "Expected location: ${STARTUP_SCD_SOURCE}"
    exit 1
fi

# Create SuperCollider startup directory if it doesn't exist
echo -e "${YELLOW}Setting up SuperCollider startup file...${NC}"
mkdir -p "${SUPERCOLLIDER_STARTUP_DIR}"

# Backup existing startup file if it exists
if [ -f "${SUPERCOLLIDER_STARTUP_FILE}" ]; then
    BACKUP_FILE="${SUPERCOLLIDER_STARTUP_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}Backing up existing startup.scd to: ${BACKUP_FILE}${NC}"
    cp "${SUPERCOLLIDER_STARTUP_FILE}" "${BACKUP_FILE}"
fi

# Copy startup file
cp "${STARTUP_SCD_SOURCE}" "${SUPERCOLLIDER_STARTUP_FILE}"
echo -e "${GREEN}✓ Startup file installed${NC}\n"

# Launch SuperCollider
echo -e "${YELLOW}Launching SuperCollider...${NC}"
open -a SuperCollider
echo -e "${GREEN}✓ SuperCollider launched${NC}"

# Wait for SuperCollider to initialize
echo -e "${YELLOW}Waiting for SuperCollider to initialize (10 seconds)...${NC}"
sleep 10
echo -e "${GREEN}✓ Initialization complete${NC}\n"

# Check if Pulsar is installed and launch it
echo -e "${YELLOW}Checking for Pulsar...${NC}"
if [ -d "/Applications/Pulsar.app" ]; then
    echo -e "${YELLOW}Launching Pulsar...${NC}"
    open -a Pulsar
    echo -e "${GREEN}✓ Pulsar launched${NC}\n"
elif [ -d "/Applications/Atom.app" ]; then
    echo -e "${YELLOW}Pulsar not found, but Atom is available. Launching Atom...${NC}"
    open -a Atom
    echo -e "${GREEN}✓ Atom launched${NC}\n"
else
    echo -e "${YELLOW}Note: Pulsar not found. You can launch your Tidal editor manually.${NC}\n"
fi

# Final instructions
echo -e "${BLUE}=== Startup Complete ===${NC}\n"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Check SuperCollider's post window for:"
echo "   ${BLUE}SuperDirt: listening to Tidal on port 57120${NC}"
echo ""
echo "2. In Pulsar (or your editor):"
echo "   - Create/open a file with .tidal extension"
echo "   - Go to ${BLUE}Packages → TidalCycles → Boot Tidal Cycles${NC}"
echo "   - Wait for the ${BLUE}t>${NC} prompt to appear"
echo ""
echo "3. Try your first pattern:"
echo "   ${BLUE}d1 \$ sound \"bd sn\"${NC}"
echo "   (Place cursor on the line and press Shift+Enter)"
echo ""
echo -e "${GREEN}Happy coding! 🎵${NC}"
