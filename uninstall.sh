#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Focus Timer Uninstaller${NC}"
echo "==========================="

# Remove compiled binary
if [ -f "focus_timer" ]; then
    echo -e "${YELLOW}Removing focus_timer binary...${NC}"
    rm focus_timer
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Binary removed successfully${NC}"
    else
        echo -e "${RED}Error: Failed to remove binary${NC}"
    fi
else
    echo -e "${YELLOW}Focus timer binary not found in current directory${NC}"
fi

# Remove application icons
echo -e "${YELLOW}Removing application icons...${NC}"
ICONS_BASE="$HOME/.local/share/icons/hicolor"
SIZES=("16x16" "32x32" "48x48" "64x64" "128x128")
ICON_REMOVED=false

for SIZE in "${SIZES[@]}"; do
    ICON_PATH="$ICONS_BASE/$SIZE/apps/focus_timer.png"
    if [ -f "$ICON_PATH" ]; then
        rm "$ICON_PATH"
        echo "Removed icon at $ICON_PATH"
        ICON_REMOVED=true
    fi
done

if [ "$ICON_REMOVED" = true ]; then
    echo -e "${GREEN}Icons removed successfully${NC}"
else
    echo -e "${YELLOW}No installed icons found${NC}"
fi

# Remove desktop entry
DESKTOP_FILE="$HOME/.local/share/applications/focus_timer.desktop"
if [ -f "$DESKTOP_FILE" ]; then
    echo -e "${YELLOW}Removing desktop entry...${NC}"
    rm "$DESKTOP_FILE"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Desktop entry removed successfully${NC}"
    else
        echo -e "${RED}Error: Failed to remove desktop entry${NC}"
    fi
else
    echo -e "${YELLOW}Desktop entry not found${NC}"
fi

# Update icon cache
echo -e "${YELLOW}Updating icon cache...${NC}"
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache ~/.local/share/icons/hicolor -f 2>/dev/null || echo -e "${YELLOW}Note: Icon cache update had warnings${NC}"
else
    echo -e "${YELLOW}Note: gtk-update-icon-cache not found${NC}"
fi

# Update desktop database
echo -e "${YELLOW}Updating desktop database...${NC}"
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database ~/.local/share/applications/ 2>/dev/null || echo -e "${YELLOW}Note: Desktop database update had warnings${NC}"
else
    echo -e "${YELLOW}Note: update-desktop-database not found${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Uninstallation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
