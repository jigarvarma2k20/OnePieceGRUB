#!/bin/bash

# ┌────────────────────────────────────────────────────────────┐
# │ OnePiece GRUB Theme Installer                              │
# │ Made by Jigarvarma2k20 | https://github.com/Jigarvarma2k20 │
# └────────────────────────────────────────────────────────────┘

# Show header
echo "######################################################"
echo "#                                                    #"
echo "#           OnePiece Theme Installer                 #"
echo "#            Made by Jigarvarma2k20                  #"
echo "#                   Visit                            #"
echo "#   https://github.com/Jigarvarma2k20/OnePieceGRUB   #"
echo "#                                                    #"
echo "######################################################"
echo ""

# Ask for sudo password
echo "Please enter your sudo password to install the theme:"
sudo -v

# Variables
THEME_DIR="/boot/grub/themes"
THEME_NAME="one-piece-grub-theme"
THEME_PATH="$THEME_DIR/$THEME_NAME/theme.txt"
GRUB_CONFIG="/etc/default/grub"

# Detect background image range
echo ""
echo "🔍 Detecting available background images..."
BACKGROUND_FILES=($(find background -type f -name "*.png" | sed 's|.*/||' | sort -n -t '.' -k1))

if [ ${#BACKGROUND_FILES[@]} -eq 0 ]; then
  echo "❌ No background images found in 'background/' folder."
  echo "💡 Hint: Run the tool script to generate properly named files like 0.png, 1.png, etc."
  exit 1
fi

FIRST_ID=$(basename "${BACKGROUND_FILES[0]}" .png)
LAST_ID=$(basename "${BACKGROUND_FILES[-1]}" .png)

echo "📸 Available Backgrounds: $FIRST_ID to $LAST_ID"

read -rp "Enter Background ID ($FIRST_ID-$LAST_ID): " BG_ID

# Validate input
if ! [[ "$BG_ID" =~ ^[0-9]+$ ]] || [ "$BG_ID" -lt "$FIRST_ID" ] || [ "$BG_ID" -gt "$LAST_ID" ]; then
  echo "❌ Invalid input. Please enter a number between $FIRST_ID and $LAST_ID."
  exit 1
fi

# Validate background image file
BACKGROUND_FILE="background/$BG_ID.png"
if [ ! -f "$BACKGROUND_FILE" ]; then
  echo "❌ Error: Background image '$BACKGROUND_FILE' not found!"
  echo "💡 Hint: Run the tool script to fix missing/incorrect background names."
  exit 1
fi

# Check if the theme folder exists locally
if [ ! -d "$THEME_NAME" ]; then
  echo "❌ Error: Theme folder '$THEME_NAME' not found in the current directory."
  exit 1
fi

# Set selected background
cp "$BACKGROUND_FILE" "$THEME_NAME/background.png"
echo "✅ Background image '$BG_ID.png' has been set."

# Remove old theme from GRUB directory
if [ -d "$THEME_DIR/$THEME_NAME" ]; then
  echo "⚠️ Theme already exists in $THEME_DIR. Removing old version..."
  sudo rm -rf "$THEME_DIR/$THEME_NAME"
fi

# Copy theme to GRUB directory
echo "📦 Installing theme to $THEME_DIR..."
sudo mkdir -p "$THEME_DIR"
sudo cp -r "$THEME_NAME" "$THEME_DIR/"
echo "✅ Theme installed."

# Set GRUB theme and disable console mode
echo "🛠️ Updating GRUB configuration..."
sudo sed -i '/^GRUB_THEME=/d' "$GRUB_CONFIG"
sudo sed -i '/^GRUB_TERMINAL=/d' "$GRUB_CONFIG"
sudo sed -i '/^GRUB_TERMINAL_OUTPUT=/d' "$GRUB_CONFIG"

echo "GRUB_THEME=\"$THEME_PATH\"" | sudo tee -a "$GRUB_CONFIG" >/dev/null
echo 'GRUB_TERMINAL_OUTPUT="gfxterm"' | sudo tee -a "$GRUB_CONFIG" >/dev/null


# Check command existence
has_command() { command -v "$1" >/dev/null 2>&1; }

# Update grub config
echo "🔄 Updating GRUB config for your system..."

if has_command update-grub; then
  sudo update-grub
elif has_command grub-mkconfig; then
  if [ -d /boot/grub ]; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  elif [ -d /boot/efi ]; then
    BOOT_EFI=$(ls /boot/efi/EFI | head -n 1)
    sudo grub-mkconfig -o "/boot/efi/EFI/$BOOT_EFI/grub.cfg"
  else
    echo "⚠️ Could not find grub.cfg path for grub-mkconfig"
  fi
elif has_command grub2-mkconfig; then
  if [ -d /boot/grub2 ]; then
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  elif [ -d /boot/efi ]; then
    BOOT_EFI=$(ls /boot/efi/EFI | grep -Ei 'rocky|centos|redhat|fedora' | head -n 1)
    if [ -n "$BOOT_EFI" ]; then
      sudo grub2-mkconfig -o "/boot/efi/EFI/$BOOT_EFI/grub.cfg"
    else
      echo "⚠️ Could not auto-detect EFI directory. Please update GRUB manually."
    fi
  else
    echo "⚠️ Could not find grub.cfg path for grub2-mkconfig"
  fi
else
  echo "❌ No known GRUB update command found. Please update manually."
fi

# Done!
echo ""
echo "🎉 OnePiece GRUB theme installed successfully with background '$BG_ID.png'!"
exit 0
