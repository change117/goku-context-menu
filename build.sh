#!/bin/bash
set -e

# Build configuration
OUTPUT_DIR="${1:-dist}"
ARCHIVE_NAME="${2:-goku-context-menu.zip}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_PATH="$SCRIPT_DIR/$OUTPUT_DIR"
ARCHIVE_PATH="$DIST_PATH/$ARCHIVE_NAME"

echo "============================================================"
echo "       GOKU CONTEXT MENU BUILD SCRIPT"
echo "============================================================"
echo ""

# Items to include in the package
items=(
  "install.bat"
  "uninstall.bat"
  "menu-template.reg"
  "README.md"
  "icons"
  "scripts"
)

echo "[1/3] Checking required files..."
missing=()
for item in "${items[@]}"; do
  if [ ! -e "$SCRIPT_DIR/$item" ]; then
    missing+=("$item")
  fi
done

if [ ${#missing[@]} -gt 0 ]; then
  echo "[X] Missing required items:"
  printf '    - %s\n' "${missing[@]}"
  exit 1
fi

echo "[OK] All required files found"
echo ""

echo "[2/3] Creating distribution directory..."
mkdir -p "$DIST_PATH"
echo "[OK] Directory created: $DIST_PATH"
echo ""

echo "[3/3] Creating archive..."
if [ -f "$ARCHIVE_PATH" ]; then
  rm -f "$ARCHIVE_PATH"
fi

# Create zip archive
cd "$SCRIPT_DIR"
zip -r "$ARCHIVE_PATH" "${items[@]}" -x "*.git*" > /dev/null 2>&1

if [ -f "$ARCHIVE_PATH" ]; then
  SIZE=$(ls -lh "$ARCHIVE_PATH" | awk '{print $5}')
  echo "[OK] Archive created successfully!"
  echo ""
  echo "============================================================"
  echo "  Output: $ARCHIVE_PATH"
  echo "  Size: $SIZE"
  echo "============================================================"
  exit 0
else
  echo "[X] Failed to create archive"
  exit 1
fi
