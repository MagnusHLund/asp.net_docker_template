#!/usr/bin/env bash

# Usage: ./rename.sh NewValue
# This replaces all occurrences of "WebshopDetector" in filenames and file contents.

# Require sudo
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run with sudo, to ensure proper file permissions."
  exec sudo "$0" "$@"
fi

# Require argument
if [ -z "$1" ]; then
  echo "Error: You must provide a replacement value."
  echo "Usage: $0 <NewValue>"
  exit 1
fi

REPLACEMENT="$1"

echo "Replacing contents inside files..."
grep -rl "WebshopDetector" . | while read -r file; do
  sed -i "s/WebshopDetector/${REPLACEMENT}/g" "$file"
done

echo "Renaming files and directories..."
find . -depth -name "*WebshopDetector*" | while read -r path; do
  newpath=$(echo "$path" | sed "s/WebshopDetector/${REPLACEMENT}/g")
  mv "$path" "$newpath"
done

# Ask whether to delete README
if [ -f "README.md" ]; then
  echo -n "Do you want to delete README.md? (y/N): "
  read answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm README.md
    echo "README.md deleted."
  else
    echo "README.md kept."
  fi
fi

echo "Deleting script..."
rm -- "$0"

echo "Done."
