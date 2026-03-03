#!/usr/bin/env bash

# Usage: ./rename.sh NewValue
# This replaces all occurrences of "ChangeMe" and "change_me" in filenames and file contents.

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
SCRIPT_NAME="$(basename "$0")"

echo "Replacing contents inside files..."
grep -rl "ChangeMe" . --exclude-dir=".git" | while IFS= read -r file; do
  if [[ "$(basename "$file")" == "$SCRIPT_NAME" ]]; then
    continue
  fi
  sed -i "s/ChangeMe/${REPLACEMENT}/g" "$file"
done

echo "Replacing contents inside files (change_me)..."
grep -rl "change_me" . --exclude-dir=".git" | while IFS= read -r file; do
  if [[ "$(basename "$file")" == "$SCRIPT_NAME" ]]; then
    continue
  fi
  sed -i "s/change_me/${REPLACEMENT,,}/g" "$file"
done

echo "Renaming files..."
find . -type f -name "*ChangeMe*" -not -path "./.git/*" | while IFS= read -r file; do
  if [[ "$(basename "$file")" == "$SCRIPT_NAME" ]]; then
    continue
  fi
  newfile="${file//ChangeMe/$REPLACEMENT}"
  mv "$file" "$newfile"
done

find . -type f -name "*change_me*" -not -path "./.git/*" | while IFS= read -r file; do
  if [[ "$(basename "$file")" == "$SCRIPT_NAME" ]]; then
    continue
  fi
  newfile="${file//change_me/${REPLACEMENT,,}}"
  mv "$file" "$newfile"
done

echo "Renaming directories..."
find . -depth -type d -name "*ChangeMe*" -not -path "./.git*" | while IFS= read -r dir; do
  newdir="${dir//ChangeMe/$REPLACEMENT}"
  mv "$dir" "$newdir"
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
