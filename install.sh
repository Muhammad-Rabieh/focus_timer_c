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


# Create icon directories if they don't exist
echo -e "${YELLOW}Installing application icons...${NC}"
mkdir -p ~/.local/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128}/apps

# Copy icons
if [ -f "assets/icons/focus_timer.png" ]; then
    cp assets/icons/focus_timer.png ~/.local/share/icons/hicolor/128x128/apps/focus_timer.png
    cp assets/icons/focus_timer.png ~/.local/share/icons/hicolor/64x64/apps/focus_timer.png
    cp assets/icons/focus_timer.png ~/.local/share/icons/hicolor/48x48/apps/focus_timer.png
    cp assets/icons/focus_timer.png ~/.local/share/icons/hicolor/32x32/apps/focus_timer.png
    cp assets/icons/focus_timer.png ~/.local/share/icons/hicolor/16x16/apps/focus_timer.png
    echo -e "${GREEN}Icons installed successfully${NC}"
else
    echo -e "${RED}Warning: Icon file not found at assets/icons/focus_timer.png${NC}"
fi

# Create desktop entry
echo -e "${YELLOW}Creating desktop entry...${NC}"
mkdir -p "$HOME/.local/share/applications"
DESKTOP_FILE="$HOME/.local/share/applications/focus_timer.desktop"
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=Focus Timer
Comment=A simple focus timer application
Exec=$PWD/focus_timer
Icon=focus_timer
Terminal=false
Type=Application
Categories=Utility;
EOF

if [ -f "$DESKTOP_FILE" ]; then
    chmod +x "$DESKTOP_FILE"
    echo -e "${GREEN}Desktop entry created successfully${NC}"
else
    echo -e "${RED}Warning: Failed to create desktop entry${NC}"
fi

# Update icon cache
echo -e "${YELLOW}Updating icon cache...${NC}"
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache ~/.local/share/icons/hicolor -f 2>/dev/null || echo -e "${YELLOW}Note: Icon cache update had warnings (this is usually fine)${NC}"
else
    echo -e "${YELLOW}Note: gtk-update-icon-cache not found, icons may require logout/login to appear${NC}"
fi

# Update desktop database
echo -e "${YELLOW}Updating desktop database...${NC}"
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database ~/.local/share/applications/ 2>/dev/null || echo -e "${YELLOW}Note: Desktop database update had warnings (this is usually fine)${NC}"
else
    echo -e "${YELLOW}Note: update-desktop-database not found, you may need to logout/login for menu entry to appear${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "You can now:"
echo "  1. Run from terminal: ./focus_timer"
echo "  2. Find 'Focus Timer' in your application menu"
echo "  3. Add to desktop or favorites"
echo ""
echo -e "${YELLOW}Note: If icons don't appear immediately, try:${NC}"
echo "  - Logging out and back in"
echo "  - Running: gtk-update-icon-cache ~/.local/share/icons/hicolor -f"
