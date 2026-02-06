# 🔥 Goku Context Menu - Dragon Ball Z Themed Windows 11 Right-Click Menu

<div align="center">

![Power Level](https://img.shields.io/badge/Power%20Level-OVER%209000!-orange?style=for-the-badge)
![Windows 11](https://img.shields.io/badge/Windows-11-blue?style=for-the-badge&logo=windows11)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue?style=for-the-badge&logo=powershell)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

*Transform your Windows 11 experience with the power of the Saiyans!*

</div>

---

## 📖 Overview

**Goku Context Menu** is a Dragon Ball Z themed enhancement for Windows 11's right-click context menu. Unleash the power of Goku and the Z-Fighters with themed actions that make file management fun and efficient!

### ✨ Features

- 🔥 **Super Saiyan Mode** - Open files/folders with administrator privileges
- ⚡ **Kamehameha** - Safely delete files with themed confirmation dialogs
- 🌟 **Instant Transmission** - Quick move files to common locations (Desktop, Documents, Downloads, etc.)
- 💪 **Power Level Scanner** - View detailed file/folder properties and statistics
- 🐉 **Summon Shenron** - Access a submenu with powerful custom actions
- 📁 **Hyperbolic Time Chamber** - Compress files and folders into ZIP archives

---

## 🎯 Menu Options Explained

### 🔥 Super Saiyan Mode
Transform your file access with administrator privileges! Opens files or folders with elevated permissions, perfect for system files and protected directories.

**Use Cases:**
- Open system configuration files
- Access protected directories
- Run applications as administrator

### ⚡ Kamehameha (Delete)
Unleash a powerful energy blast to obliterate files! Features a safety confirmation dialog that requires you to type "KAMEHAMEHA" before deletion.

**Features:**
- Safe deletion with confirmation
- Shows file sizes and types before deletion
- Animated themed output
- Handles both files and folders

### 🌟 Instant Transmission (Quick Move)
Teleport your files instantly to predefined locations! No more dragging and dropping across windows.

**Available Destinations:**
- Desktop
- Documents
- Downloads
- Pictures
- Videos
- Music

**Features:**
- Automatic name conflict resolution
- Opens destination folder after move
- Handles multiple file selections

### 💪 Power Level Scanner
Scan the power level of any file or folder! Displays comprehensive information in a beautiful themed interface.

**Information Displayed:**
- Basic file/folder information (name, type, path)
- Timestamps (created, modified, accessed)
- File attributes and permissions
- File size and folder statistics
- File type breakdown for folders
- Hash values for security verification
- Version information for executables

### 🐉 Summon Shenron (Custom Actions)
Gather the seven Dragon Balls and make your wish! Access a powerful submenu with advanced utilities.

**Available Wishes:**
1. 📋 **Copy Full Path** - Copy complete file paths to clipboard
2. 🔗 **Create Symbolic Link** - Generate symbolic links (requires admin)
3. 🎨 **Change Attributes** - Toggle Hidden/Read-Only attributes
4. 📅 **Modify Timestamps** - Update creation/modification dates
5. 🔍 **Search Duplicates** - Find duplicate files by name and size
6. 📊 **Generate Report** - Create detailed TXT reports
7. 🔄 **Rename Pattern** - Batch rename with custom patterns

### 📁 Hyperbolic Time Chamber (Compress)
Train in the time chamber and compress your files! Creates optimized ZIP archives with compression statistics.

**Features:**
- Custom archive naming
- Overwrite protection
- Compression ratio calculation
- Fun "training multiplier" Easter egg
- Opens archive location when complete

---

## 🚀 Installation

### Prerequisites

- **Operating System:** Windows 11 (may work on Windows 10)
- **PowerShell:** Version 5.1 or later (included with Windows)
- **Permissions:** User-level access (no administrator required for installation)

### Step-by-Step Installation

1. **Download the Repository**
   ```bash
   git clone https://github.com/change117/goku-context-menu.git
   ```
   
   Or download as ZIP and extract to a permanent location.

2. **Run the Installation Script**
   - Navigate to the extracted folder
   - Double-click `install.bat`
   - Click "Yes" when prompted by Registry Editor
   - Wait for the success message

3. **Verify Installation**
   - Right-click on any file or folder
   - Look for "🔥 Goku's Power Menu" in the context menu
   - Enjoy your new powers!

### Important Notes

- ⚠️ **Keep the installation folder**: Don't delete or move the folder after installation. The context menu points to these scripts.
- 🔧 **If you move the folder**: Run `uninstall.bat` from the old location, then `install.bat` from the new location.
- 🔄 **Updates**: To update, uninstall the old version first, then install the new one.
- 💡 **Windows 11 Users**: On Windows 11, custom context menus appear under "Show more options" (or press Shift+F10). To see Goku's Power Menu:
  1. Right-click on a file or folder
  2. Click "Show more options" at the bottom of the menu
  3. The Dragon Ball menu will appear in the classic context menu

#### Enabling Classic Context Menu by Default (Windows 11)

If you want the classic context menu to appear immediately without clicking "Show more options":

1. Open Command Prompt or PowerShell as Administrator
2. Run this command (creates an empty registry value that forces Windows 11 to use the classic context menu):
   ```batch
   reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
   ```
3. Restart Windows Explorer:
   ```batch
   taskkill /f /im explorer.exe && start explorer.exe
   ```

To revert back to the Windows 11 modern menu:
```batch
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
taskkill /f /im explorer.exe && start explorer.exe
```

---

## 🗑️ Uninstallation

To remove Goku's Power Menu from your system:

1. Navigate to the installation folder
2. Run `uninstall.bat` or `uninstall-generated.bat`
3. Wait for the confirmation message
4. (Optional) Delete the installation folder

The uninstaller will:
- Remove all context menu entries
- Refresh Windows Explorer
- Clean up registry entries
- Keep the installation files (you can delete them manually)

---

## 🛠️ Technical Details

### Architecture

- **Language:** PowerShell 5.1+
- **Installation Method:** Windows Registry modification (HKEY_CURRENT_USER)
- **Execution Policy:** Bypassed for scripts (safe, read-only operations)
- **Icon System:** Unicode emoji characters (Windows 11 native support)

### File Structure

```
goku-context-menu/
├── install.bat                      # Installation script
├── uninstall.bat                    # Uninstallation script
├── goku-menu.reg.template           # Registry template
├── README.md                        # This file
├── icons/                           # Icon resources and info
│   └── README.md                    # Icon customization guide
└── scripts/                         # PowerShell action scripts
    ├── super-saiyan.ps1            # Admin elevation
    ├── kamehameha.ps1              # Safe delete
    ├── instant-transmission.ps1    # Quick move
    ├── power-scanner.ps1           # File properties
    ├── shenron-menu.ps1            # Custom actions
    └── hyperbolic-chamber.ps1      # ZIP compression
```

### Registry Entries

The context menu is registered in three locations:
- `HKEY_CURRENT_USER\Software\Classes\*\shell\GokuMenu` - For files
- `HKEY_CURRENT_USER\Software\Classes\Directory\shell\GokuMenu` - For folders
- `HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\GokuMenu` - For background

---

## 🎨 Customization

### Changing Icons

See [icons/README.md](icons/README.md) for detailed instructions on using custom icons instead of emojis.

### Modifying Scripts

All PowerShell scripts are located in the `scripts/` directory and can be edited to customize behavior:

1. Open the script in a text editor
2. Make your changes
3. Save the file
4. Test by right-clicking and selecting the option

### Adding New Menu Items

To add new menu items:

1. Create a new PowerShell script in the `scripts/` folder
2. Edit `goku-menu.reg.template` to add new registry entries
3. Run `uninstall.bat` to remove old entries
4. Run `install.bat` to apply changes

---

## 🔒 Security & Safety

### Safety Features

- ✅ **Confirmation Dialogs**: Destructive operations require explicit confirmation
- ✅ **Error Handling**: All scripts include comprehensive error handling
- ✅ **User-Level Installation**: No administrator rights required for installation
- ✅ **Read-Only Execution**: Scripts don't modify system files
- ✅ **Open Source**: All code is visible and auditable

### Best Practices

- 🔐 **Review Before Deletion**: The Kamehameha function shows what will be deleted
- 📋 **Backup Important Files**: Always maintain backups of critical data
- ⚡ **Admin Privileges**: Super Saiyan Mode requests admin only when needed
- 🧪 **Test First**: Try the functions on test files before using on important data

### What Gets Modified

The installation only modifies:
- Registry entries in `HKEY_CURRENT_USER\Software\Classes\*\shell`
- No system files are changed
- No services are installed
- No startup items are added

---

## 🐛 Troubleshooting

### Context Menu Doesn't Appear

**Problem:** Right-click menu doesn't show Goku's Power Menu

**Solutions:**
1. **Windows 11**: Click "Show more options" in the context menu (or press Shift+F10) to access the classic menu where custom entries appear
2. Verify installation completed successfully
3. Restart Windows Explorer:
   ```batch
   taskkill /f /im explorer.exe && start explorer.exe
   ```
4. Check installation path hasn't been moved or deleted
5. Re-run `install.bat`

### Scripts Won't Execute

**Problem:** "Cannot be loaded because running scripts is disabled"

**Solution:** This should not happen as scripts use `-ExecutionPolicy Bypass`, but if it does:
1. Open PowerShell as Administrator
2. Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
3. Try the context menu action again

### "Path Not Found" Errors

**Problem:** Scripts can't find files or folders

**Solutions:**
1. Ensure you haven't moved the installation folder
2. Check file paths don't contain special characters
3. Re-run `install.bat` from the current location

### Admin Privileges Required

**Problem:** Some operations fail due to permissions

**Solution:**
- Use "Super Saiyan Mode" for files requiring admin access
- Some operations (like creating symlinks) always require admin rights

### Windows Explorer Freezes

**Problem:** Explorer becomes unresponsive after using menu

**Solution:**
1. Open Task Manager (Ctrl+Shift+Esc)
2. Find "Windows Explorer"
3. Right-click → Restart

---

## 📸 Screenshots

### Main Context Menu
*Right-click on any file or folder to see Goku's Power Menu*

```
┌─────────────────────────────────────┐
│  Open                               │
│  Open with                         →│
│  🔥 Goku's Power Menu              →│
│    🔥 Super Saiyan Mode (Admin)    │
│    ⚡ Kamehameha (Delete)          │
│    🌟 Instant Transmission (Move)  │
│    💪 Power Level Scanner          │
│    🐉 Summon Shenron (More)        │
│    📁 Hyperbolic Time Chamber(ZIP) │
│  ─────────────────────────────────  │
│  Cut                                │
│  Copy                               │
│  Paste                              │
└─────────────────────────────────────┘
```

### Power Level Scanner Output
```
🔍🔍🔍 POWER LEVEL SCANNER 🔍🔍🔍
======================================================================
📊 POWER LEVEL ANALYSIS REPORT
======================================================================

🎯 TARGET IDENTIFICATION:
  Name:          MyDocument.pdf
  Type:          📄 File
  Full Path:     C:\Users\Goku\Documents\MyDocument.pdf

⏰ TEMPORAL INFORMATION:
  Created:       1/15/2024 10:30:00 AM
  Modified:      1/20/2024 3:45:00 PM
  Accessed:      1/20/2024 4:15:00 PM

⚡ POWER LEVEL: 8425 ⚡
```

---

## 🤝 Contributing

Contributions are welcome! Whether it's:

- 🐛 Bug fixes
- ✨ New features
- 📝 Documentation improvements
- 🎨 UI/UX enhancements
- 🌍 Translations

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Disclaimer

**Legal Notice:**

- Dragon Ball, Dragon Ball Z, and all related characters and elements are trademarks of and © by Akira Toriyama, Shueisha, Toei Animation, and Funimation.
- This project is a fan-made tool and is **not officially affiliated with or endorsed** by the copyright holders.
- This tool is provided "as is" without warranty of any kind.
- Use at your own risk. Always backup important files before using file manipulation tools.
- The developers are not responsible for any data loss or system issues that may occur.

**Registry Modification Warning:**

This tool modifies the Windows Registry. While the modifications are safe and limited to user-level context menu entries:
- Always create a system restore point before installation
- Keep the installation files so you can uninstall if needed
- Review the code before installation if you have security concerns

---

## 💝 Acknowledgments

- **Akira Toriyama** - Creator of Dragon Ball
- **Dragon Ball Community** - For inspiration and enthusiasm
- **Windows Shell Team** - For the extensible context menu system
- **PowerShell Community** - For tools and documentation

---

## 🌟 Show Your Support

If you found this project useful or fun:

- ⭐ Star this repository
- 🐛 Report bugs or suggest features
- 📢 Share with friends and fellow Dragon Ball fans
- 🎨 Contribute improvements

Remember: *"Power comes in response to a need, not a desire."* - Goku

---

## 📞 Contact & Support

- **Issues:** [GitHub Issues](https://github.com/change117/goku-context-menu/issues)
- **Discussions:** [GitHub Discussions](https://github.com/change117/goku-context-menu/discussions)

---

<div align="center">

**Made with ❤️ by Dragon Ball fans for Dragon Ball fans**

*May your power level always be OVER 9000!*

⚡🔥🌟💪🐉📁⚡

</div>
