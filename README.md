# OnePiece GRUB Theme

This GRUB theme brings the world of One Piece to your boot screen with vibrant visuals, clean layout, and anime-inspired styling.

## Features

- Bold Fonts: Uses unique bold fonts to enhance the theme's visual appeal.
- Minimalistic Design: Focuses on simplicity with OnePiece Anime Characters.
- Multiple Backgrounds: Choose from 9 preloaded backgrounds (0.png to 8.png) during installation.
- Easy to Install: Follow the installation steps to quickly apply the theme to your GRUB.
- High Customizability: Modify colors, fonts, and more to make it your own.
- Image Tool Included: Easily resize and organize wallpapers for GRUB using the included shell utility.

## Installation

### Prerequisites

- Ensure you have grub2 installed on your system.
- A basic understanding of the Linux terminal.

1. Clone the Repository:
    ```
   git clone https://github.com/Jigarvarma2k20/OnePieceGRUB.git
   ```

2. Navigate to the Directory:
    ```
   cd OnePieceGRUB
   ```

### Install Via Script

3. Run install.sh:
    ```
   ./install.sh
   ```

## Wallpaper Tool Script

A helper script resize_and_manage.sh is included to automate image resizing and background management.

### Features

- Reads wallpapers from images/ directory
- Resizes all to 16:9 (1920x1080) and saves in background/
- Filenames are numbered sequentially (0.png, 1.png, ...)
- Automatically skips existing numbers and continues
- Includes a menu with an option to fix numbering gaps (e.g., if 17.png is deleted)

### Usage

1. Place your images in the images/ folder.
2. Run the tool:
    ```
   chmod +x resize_and_manage.sh
   ./resize_and_manage.sh
    ```

3. Choose an action from the menu:
   - Resize and Add New Wallpapers
   - Fix Background Image Filenames (if gaps exist)

Note: Requires ImageMagick 7+.

## Contributing

Contributions are welcome! If you’d like to improve this theme, feel free to submit a pull request or open an issue with suggestions.

## License

This project is licensed under the MIT License. See [LICENSE](/LICENSE) for details.

---

Enjoy the OnePiece GRUB and happy booting!
