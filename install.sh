#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Focus Timer Installer${NC}"
echo "========================="

# Detect package manager
if command -v apt-get >/dev/null 2>&1; then
    PKG_MANAGER="apt-get"
    INSTALL_CMD="sudo apt-get install -y"
    PACKAGES="libgtk-3-dev libasound2-dev build-essential"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
    PACKAGES="gtk3-devel alsa-lib-devel gcc"
elif command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
    PACKAGES="gtk3 alsa-lib base-devel"
elif command -v zypper >/dev/null 2>&1; then
    PKG_MANAGER="zypper"
    INSTALL_CMD="sudo zypper install -y"
    PACKAGES="gtk3-devel alsa-devel gcc"
else
    echo -e "${RED}Error: Could not detect package manager${NC}"
    echo "Please install the following packages manually:"
    echo "- GTK3 development libraries"
    echo "- ALSA development libraries"
    echo "- GCC compiler"
    exit 1
fi

# Check if pkg-config is available
if ! command -v pkg-config >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing pkg-config...${NC}"
    $INSTALL_CMD pkg-config
fi

# Install dependencies
echo -e "${YELLOW}Installing required packages using $PKG_MANAGER...${NC}"
$INSTALL_CMD $PACKAGES

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to install dependencies${NC}"
    exit 1
fi

# Compile the program
echo -e "${YELLOW}Compiling Focus Timer...${NC}"
gcc -o focus_timer focus_timer.c $(pkg-config --cflags --libs gtk+-3.0) -lasound -lm

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Compilation failed${NC}"
    exit 1
fi

# Make the program executable
chmod +x focus_timer

echo -e "${GREEN}Installation completed successfully!${NC}"
echo "You can now run Focus Timer using:"
echo "./focus_timer"

# Test ALSA
echo -e "${YELLOW}Testing sound system...${NC}"
speaker-test -t sine -f 1000 -l 1 >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Warning: Sound test failed. Please check your audio settings:${NC}"
    echo "1. Run 'alsamixer' to check volume levels"
    echo "2. Ensure your sound is not muted"
    echo "3. Try running 'speaker-test -t sine -f 1000 -l 1' manually"
else
    echo -e "${GREEN}Sound system test passed${NC}"
fi
