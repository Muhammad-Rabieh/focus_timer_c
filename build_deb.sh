#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Focus Timer .deb Package Builder${NC}"
echo "======================================"

# Configuration
PACKAGE_NAME="focus-timer"
VERSION="0.16.0"
MAINTAINER="Muhammad Rabieh <Muhammad.Rabieh@gmail.com>"
DESCRIPTION="A simple GTK-based focus timer application"
ARCH=$(dpkg --print-architecture)
BUILD_DIR="focus-timer-pkg"

# 1. Clean previous build directory
echo -e "${YELLOW}Cleaning previous build artifacts...${NC}"
rm -rf "$BUILD_DIR"
rm -f "${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"

# 2. Compile the program
echo -e "${YELLOW}Compiling program...${NC}"
gcc -o focus_timer focus_timer.c $(pkg-config --cflags --libs gtk+-3.0) -lasound -lm
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Compilation failed${NC}"
    exit 1
fi

# 3. Create directory structure
echo -e "${YELLOW}Creating directory structure...${NC}"
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/usr/bin"
mkdir -p "$BUILD_DIR/usr/share/applications"
mkdir -p "$BUILD_DIR/usr/share/icons/hicolor/128x128/apps"
mkdir -p "$BUILD_DIR/usr/share/icons/hicolor/64x64/apps"
mkdir -p "$BUILD_DIR/usr/share/icons/hicolor/48x48/apps"
mkdir -p "$BUILD_DIR/usr/share/icons/hicolor/32x32/apps"
mkdir -p "$BUILD_DIR/usr/share/icons/hicolor/16x16/apps"

# 4. Copy files
echo -e "${YELLOW}Copying files to package structure...${NC}"
cp focus_timer "$BUILD_DIR/usr/bin/focus-timer"

# Icons
if [ -f "assets/icons/focus_timer.png" ]; then
    ICON_SRC="assets/icons/focus_timer.png"
    cp "$ICON_SRC" "$BUILD_DIR/usr/share/icons/hicolor/128x128/apps/focus-timer.png"
    cp "$ICON_SRC" "$BUILD_DIR/usr/share/icons/hicolor/64x64/apps/focus-timer.png"
    cp "$ICON_SRC" "$BUILD_DIR/usr/share/icons/hicolor/48x48/apps/focus-timer.png"
    cp "$ICON_SRC" "$BUILD_DIR/usr/share/icons/hicolor/32x32/apps/focus-timer.png"
    cp "$ICON_SRC" "$BUILD_DIR/usr/share/icons/hicolor/16x16/apps/focus-timer.png"
fi

# Desktop Entry
cat <<EOF > "$BUILD_DIR/usr/share/applications/focus-timer.desktop"
[Desktop Entry]
Name=Focus Timer
Comment=A simple focus timer application
Exec=focus-timer
Icon=focus-timer
Terminal=false
Type=Application
Categories=Utility;
EOF

# 5. Create control file
echo -e "${YELLOW}Generating Debian control file...${NC}"
cat <<EOF > "$BUILD_DIR/DEBIAN/control"
Package: $PACKAGE_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Depends: libgtk-3-0, libasound2
Maintainer: $MAINTAINER
Description: $DESCRIPTION
 This is a simple GTK-based focus timer application with audio notifications.
EOF

# 6. Create postinst and postrm scripts
echo -e "${YELLOW}Generating maintainer scripts...${NC}"
cat <<EOF > "$BUILD_DIR/DEBIAN/postinst"
#!/bin/sh
set -e
if [ "\$1" = "configure" ]; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
    update-desktop-database -q /usr/share/applications || true
fi
EOF
chmod 755 "$BUILD_DIR/DEBIAN/postinst"

cat <<EOF > "$BUILD_DIR/DEBIAN/postrm"
#!/bin/sh
set -e
if [ "\$1" = "remove" ] || [ "\$1" = "purge" ]; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
    update-desktop-database -q /usr/share/applications || true
fi
EOF
chmod 755 "$BUILD_DIR/DEBIAN/postrm"

# 7. Build the package
echo -e "${YELLOW}Building .deb package...${NC}"
dpkg-deb --build "$BUILD_DIR"

if [ $? -eq 0 ]; then
    DEB_FILE="${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"
    mv "${BUILD_DIR}.deb" "$DEB_FILE"
    echo -e "${GREEN}Package created successfully: $DEB_FILE${NC}"
    echo "You can install it using: sudo dpkg -i $DEB_FILE"
else
    echo -e "${RED}Error: Package build failed${NC}"
    exit 1
fi

# Cleanup build directory
# rm -rf "$BUILD_DIR"
