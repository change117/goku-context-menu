# Dragon Ball Z Icons for Goku Context Menu

This directory contains information about icons used in the Goku Context Menu system.

## Icon Usage

The context menu uses emoji characters for icons, which are displayed directly in Windows 11 context menus:

- 🔥 **Super Saiyan Mode** - Fire emoji for power/admin
- ⚡ **Kamehameha** - Lightning bolt for energy attack
- 🌟 **Instant Transmission** - Star for teleportation
- 💪 **Power Level Scanner** - Flexed muscle for power
- 🐉 **Summon Shenron** - Dragon emoji for the eternal dragon
- 📁 **Hyperbolic Time Chamber** - Folder with compression symbol

## Custom Icons (Optional)

If you want to use custom Dragon Ball Z icons instead of emojis:

### Option 1: Using ICO Files

1. Download or create Dragon Ball Z themed `.ico` files
2. Place them in this directory with these names:
   - `super-saiyan.ico`
   - `kamehameha.ico`
   - `instant-transmission.ico`
   - `power-scanner.ico`
   - `shenron.ico`
   - `hyperbolic-chamber.ico`

3. Edit the `goku-menu.reg.template` file and update the Icon entries:
   ```
   "Icon"="%INSTALL_PATH%\\icons\\super-saiyan.ico"
   ```

### Option 2: Using System Icons

You can also reference Windows system icons:
```
"Icon"="shell32.dll,137"  ; Folder icon
"Icon"="imageres.dll,2"   ; Folder icon
```

### Option 3: Using External Icons

You can use icons from Dragon Ball Z games or applications:
```
"Icon"="C:\\Program Files\\YourApp\\icon.ico"
```

## Free Icon Resources

Here are some places to find Dragon Ball themed icons:

- **DeviantArt**: Search for "Dragon Ball Z icons"
- **IconArchive**: https://www.iconarchive.com/
- **Flaticon**: https://www.flaticon.com/ (search for "dragon ball")
- **Icons8**: https://icons8.com/ (search for anime-style icons)

## Creating Your Own Icons

To create custom icons:

1. Find Dragon Ball Z images (with proper licensing)
2. Use tools like:
   - GIMP (free)
   - Adobe Photoshop
   - Online converters (e.g., convertio.co)
3. Convert to `.ico` format (32x32 or 48x48 pixels recommended)
4. Save in this directory

## Notes

- Windows 11 context menus display emojis natively
- For best results with custom icons, use 32x32 or 48x48 pixel `.ico` files
- Ensure you have proper licensing for any icons you use
- The default emoji icons work great and require no additional setup!

## Legal Notice

Dragon Ball, Dragon Ball Z, and all related characters and elements are trademarks of and © by their respective owners. This project is a fan-made tool and is not officially affiliated with or endorsed by the copyright holders.
