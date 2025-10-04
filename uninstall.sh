#!/bin/bash
set -e

# ┌────────────────────────────────────────────────────────────┐
# │ OnePiece GRUB Theme Uninstaller                            │
# │ Made by Jigarvarma2k20 | https://github.com/Jigarvarma2k20 │
# └────────────────────────────────────────────────────────────┘

echo "OnePiece Theme Uninstaller"
sudo -v

THEME_DIR="/boot/grub/themes"
THEME_NAME="one-piece-grub-theme"
GRUB_CONFIG="/etc/default/grub"
BACKUP_BASE="${GRUB_CONFIG}.onepiece.bak"

has_command() { command -v "$1" >/dev/null 2>&1; }

get_backup_to_restore() {
  # Prefer the initial backup; else use the newest timestamped backup
  if [ -f "$BACKUP_BASE" ]; then
    echo "$BACKUP_BASE"
    return
  fi
  if ls "${BACKUP_BASE}."* >/dev/null 2>&1; then
    ls -1t "${BACKUP_BASE}."* | head -n 1
    return
  fi
  echo ""
}

restore_or_sanitize_grub() {
  local ts
  ts=$(date +%Y%m%d-%H%M%S)
  if [ -f "$GRUB_CONFIG" ]; then
    sudo cp -p "$GRUB_CONFIG" "${GRUB_CONFIG}.onepiece.uninstall.bak.${ts}" || true
  fi

  local candidate
  candidate="$(get_backup_to_restore)"
  if [ -n "$candidate" ]; then
    echo "Restoring GRUB config from backup: $candidate"
    sudo cp -f "$candidate" "$GRUB_CONFIG"
    return
  fi

  echo "No OnePiece backup found. Sanitizing $GRUB_CONFIG"
  if [ -f "$GRUB_CONFIG" ]; then
    sudo sed -i \
      -e '/^GRUB_THEME=/d' \
      -e '/^GRUB_TERMINAL_OUTPUT=/d' \
      -e '/^GRUB_TERMINAL=/d' \
      "$GRUB_CONFIG"
    echo 'GRUB_TERMINAL="console"' | sudo tee -a "$GRUB_CONFIG" >/dev/null
  else
    echo 'GRUB_TERMINAL="console"' | sudo tee "$GRUB_CONFIG" >/dev/null
  fi
}

remove_theme() {
  if [ -d "$THEME_DIR/$THEME_NAME" ]; then
    echo "Removing theme directory: $THEME_DIR/$THEME_NAME"
    sudo rm -rf "$THEME_DIR/$THEME_NAME"
  else
    echo "Theme directory not found: $THEME_DIR/$THEME_NAME"
  fi
  if [ -d "$THEME_DIR" ] && [ -z "$(ls -A "$THEME_DIR")" ]; then
    sudo rmdir "$THEME_DIR" 2>/dev/null || true
  fi
}

rebuild_grub_cfg() {
  echo "Regenerating GRUB configuration..."
  if has_command update-grub; then
    sudo update-grub
  elif has_command grub-mkconfig; then
    if [ -d /boot/grub ]; then
      sudo grub-mkconfig -o /boot/grub/grub.cfg
    elif [ -d /boot/efi ]; then
      BOOT_EFI=$(ls /boot/efi/EFI 2>/dev/null | head -n 1)
      if [ -n "$BOOT_EFI" ]; then
        sudo grub-mkconfig -o "/boot/efi/EFI/$BOOT_EFI/grub.cfg"
      else
        echo "Could not auto-detect EFI directory for grub-mkconfig."
      fi
    else
      echo "Could not find grub.cfg path for grub-mkconfig."
    fi
  elif has_command grub2-mkconfig; then
    if [ -d /boot/grub2 ]; then
      sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    elif [ -d /boot/efi ]; then
      BOOT_EFI=$(ls /boot/efi/EFI 2>/dev/null | grep -Ei 'rocky|centos|redhat|fedora' | head -n 1)
      if [ -n "$BOOT_EFI" ]; then
        sudo grub2-mkconfig -o "/boot/efi/EFI/$BOOT_EFI/grub.cfg"
      else
        echo "Could not auto-detect EFI directory for grub2-mkconfig."
      fi
    else
      echo "Could not find grub.cfg path for grub2-mkconfig."
    fi
  else
    echo "No known GRUB update command found. Please update manually."
  fi
}

echo "Uninstalling OnePiece GRUB theme..."
restore_or_sanitize_grub
remove_theme
rebuild_grub_cfg
echo "Done. Restored backed-up GRUB config (or console fallback) and removed the theme."
