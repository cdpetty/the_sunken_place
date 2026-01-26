#!/bin/bash

# THE SUNKEN PLACE - Add Album Script
# Run this to add a new album and push to GitHub

echo ""
echo "╔════════════════════════════════════╗"
echo "║      THE SUNKEN PLACE              ║"
echo "║      Add New Album/Song            ║"
echo "╚════════════════════════════════════╝"
echo ""

# Get album info from user
read -p "Artist name: " artist
read -p "Album/Song title: " title
read -p "Album art URL: " albumArt
read -p "Type (album/song) [album]: " type
type=${type:-album}
read -p "Year: " year
read -p "Spotify URL (optional): " spotifyUrl

# Confirm
echo ""
echo "─────────────────────────────────────"
echo "Artist:    $artist"
echo "Title:     $title"
echo "Art URL:   $albumArt"
echo "Type:      $type"
echo "Year:      $year"
[[ -n "$spotifyUrl" ]] && echo "Spotify:   $spotifyUrl"
echo "─────────────────────────────────────"
echo ""
read -p "Add this entry? (y/n) [y]: " confirm
confirm=${confirm:-y}

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Cancelled."
    exit 0
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_FILE="$SCRIPT_DIR/data.js"

# Create the new entry (with or without Spotify URL)
if [[ -n "$spotifyUrl" ]]; then
  NEW_ENTRY="  {
    albumArt: \"$albumArt\",
    artist: \"$artist\",
    title: \"$title\",
    type: \"$type\",
    year: $year,
    spotifyUrl: \"$spotifyUrl\"
  },"
else
  NEW_ENTRY="  {
    albumArt: \"$albumArt\",
    artist: \"$artist\",
    title: \"$title\",
    type: \"$type\",
    year: $year
  },"
fi

# Insert after "const musicFeed = [" line
TEMP_FILE=$(mktemp)
awk -v entry="$NEW_ENTRY" '
  /const musicFeed = \[/ {
    print
    print entry
    next
  }
  { print }
' "$DATA_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$DATA_FILE"

echo ""
echo "✓ Added to data.js"

# Git operations
cd "$SCRIPT_DIR"

read -p "Commit and push to GitHub? (y/n) [y]: " push
push=${push:-y}

if [[ "$push" == "y" || "$push" == "Y" ]]; then
    git add data.js
    git commit -m "Add: $artist - $title"
    git push
    echo ""
    echo "✓ Pushed to GitHub!"
else
    echo ""
    echo "Changes saved locally. Run 'git add data.js && git commit && git push' when ready."
fi

echo ""
echo "...sink into the sound..."
echo ""
