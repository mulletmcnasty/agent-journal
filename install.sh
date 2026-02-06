#!/bin/bash
# Install agent-journal CLI tool

LOBSTER="🦞"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}${LOBSTER} Installing agent-journal...${NC}"
echo ""

INSTALL_DIR="/usr/local/bin"
SCRIPT="agent-journal"

# Check if running as root for /usr/local/bin
if [ "$EUID" -ne 0 ] && [ ! -w "$INSTALL_DIR" ]; then
    echo "Note: You may need sudo to install to $INSTALL_DIR"
    read -p "Continue? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

if [ -f "$SCRIPT" ]; then
    echo -e "${BLUE}Installing:${NC} $SCRIPT → $INSTALL_DIR/$SCRIPT"
    if cp "$SCRIPT" "$INSTALL_DIR/" && chmod +x "$INSTALL_DIR/$SCRIPT"; then
        echo ""
        echo -e "${GREEN}✅ Installed successfully!${NC}"
        echo ""
        echo "Try: agent-journal help"
        echo "     agent-journal init"
        echo ""
        echo -e "${LOBSTER} Context will betray you. Files won't."
    else
        echo -e "${RED}Failed to install $SCRIPT${NC}"
        exit 1
    fi
else
    echo -e "${RED}Error: $SCRIPT not found${NC}"
    exit 1
fi
