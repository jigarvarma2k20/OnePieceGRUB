#!/bin/bash
# -----------------------------------------------------------------------------
#  Tool Script for OnePiece GRUB Theme
#
#  Author   : Jigar Varma (Jigarvarma2k20)
#  GitHub   : https://github.com/Jigarvarma2k20
#  License  : MIT
#  Created  : 2025
#
#  Description:
#    This script assists in renaming or organizing background images used by
#    the OnePiece GRUB theme. It ensures proper file naming (0.png to N.png)
#    for compatibility with the installer.
#
#  Copyright (c) 2025 Jigar Varma
# -----------------------------------------------------------------------------


INPUT_DIR="images"
OUTPUT_DIR="background"
WIDTH=1920
HEIGHT=1080

resize_and_add() {
  if [ ! -d "$INPUT_DIR" ]; then
    echo "❌ ERROR: '$INPUT_DIR/' directory not found. Please create it and add images."
    return
  fi

  mkdir -p "$OUTPUT_DIR"

  last_num=$(find "$OUTPUT_DIR" -maxdepth 1 -name '*.png' | sed -n 's/.*\/\([0-9]\+\)\.png/\1/p' | sort -n | tail -1)
  last_num=${last_num:- -1}
  next_num=$((last_num + 1))

  for img in "$INPUT_DIR"/*.{png,jpg,jpeg,JPG,JPEG}; do
    [ -f "$img" ] || continue
    dest_file="${OUTPUT_DIR}/${next_num}.png"
    echo "[$next_num] Resizing: $img → $dest_file"
    magick "$img" -resize "${WIDTH}x${HEIGHT}^" -gravity center -extent "${WIDTH}x${HEIGHT}" "$dest_file"
    ((next_num++))
  done

  echo "✅ Images added to $OUTPUT_DIR/"
}

fix_names() {
  echo "🔄 Renaming files in $OUTPUT_DIR/ to fill gaps..."
  mkdir -p "$OUTPUT_DIR"

  temp_dir="${OUTPUT_DIR}_temp"
  mkdir -p "$temp_dir"

  i=0
  for file in $(find "$OUTPUT_DIR" -maxdepth 1 -name '*.png' | sort -V); do
    cp "$file" "$temp_dir/$i.png"
    ((i++))
  done

  rm "$OUTPUT_DIR"/*.png
  mv "$temp_dir"/* "$OUTPUT_DIR/"
  rmdir "$temp_dir"

  echo "✅ All files renamed from 0.png to $((i - 1)).png"
}

show_menu() {
  echo "========= GRUB Theme Image Tool ========="
  echo "1) Resize & Add Images"
  echo "2) Fix Names in background/"
  echo "0) Exit"
  echo "========================================="
  read -p "Choose an option: " choice

  case "$choice" in
    1) resize_and_add ;;
    2) fix_names ;;
    0) echo "Bye!" && exit 0 ;;
    *) echo "❌ Invalid choice!" ;;
  esac
}

while true; do
  show_menu
done
