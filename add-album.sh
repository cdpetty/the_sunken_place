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
read -p "Type (album/song/EP/single) [album]: " type
type=${type:-album}
read -p "Year: " year
read -p "Spotify URL (optional): " spotifyUrl
read -p "SoundCloud URL (optional): " soundcloudUrl
read -p "YouTube URL (optional): " youtubeUrl

# Confirm
echo ""
echo "─────────────────────────────────────"
echo "Artist:    $artist"
echo "Title:     $title"
echo "Art URL:   $albumArt"
echo "Type:      $type"
echo "Year:      $year"
[[ -n "$spotifyUrl" ]] && echo "Spotify:   $spotifyUrl"
[[ -n "$soundcloudUrl" ]] && echo "SoundCloud: $soundcloudUrl"
[[ -n "$youtubeUrl" ]] && echo "YouTube:    $youtubeUrl"
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

# Escape special characters for JavaScript strings (backslash and quotes)
escape_js() {
  local str="$1"
  str="${str//\\/\\\\}"  # escape backslashes
  str="${str//\"/\\\"}"  # escape quotes
  echo "$str"
}

artist_escaped=$(escape_js "$artist")
title_escaped=$(escape_js "$title")

# Create temp files
TEMP_FILE=$(mktemp)
ENTRY_FILE=$(mktemp)

# Build optional URL fields
URL_FIELDS=""
[[ -n "$spotifyUrl" ]] && URL_FIELDS="${URL_FIELDS}, spotifyUrl: \"$spotifyUrl\""
[[ -n "$soundcloudUrl" ]] && URL_FIELDS="${URL_FIELDS}, soundcloudUrl: \"$soundcloudUrl\""
[[ -n "$youtubeUrl" ]] && URL_FIELDS="${URL_FIELDS}, youtubeUrl: \"$youtubeUrl\""

# Write the new entry to a file (avoids all escaping issues)
cat > "$ENTRY_FILE" << ENTRY_EOF
  { albumArt: "$albumArt", artist: "$artist_escaped", title: "$title_escaped", type: "$type", year: $year${URL_FIELDS} },
ENTRY_EOF

# Find line number of "const musicFeed = [" and insert after it
LINE_NUM=$(grep -n "^const musicFeed = \[" "$DATA_FILE" | cut -d: -f1)

if [[ -z "$LINE_NUM" ]]; then
    echo "✗ Error: Could not find musicFeed array in data.js"
    rm -f "$TEMP_FILE" "$ENTRY_FILE"
    exit 1
fi

# Build new file: head up to array line, new entry, rest of file
head -n "$LINE_NUM" "$DATA_FILE" > "$TEMP_FILE"
cat "$ENTRY_FILE" >> "$TEMP_FILE"
tail -n +"$((LINE_NUM + 1))" "$DATA_FILE" >> "$TEMP_FILE"

# Replace original file
mv "$TEMP_FILE" "$DATA_FILE"
rm -f "$ENTRY_FILE"

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
