#!/bin/bash

# Create a temporary file to store the combined content
temp_file=$(mktemp)

# Function to add a file's content to our temp file with nice formatting
copy_file() {
  local file=$1
  echo "" >>"$temp_file"
  echo "=======================================" >>"$temp_file"
  echo "FILE: $file" >>"$temp_file"
  echo "=======================================" >>"$temp_file"
  echo "" >>"$temp_file"
  cat "$file" >>"$temp_file"
  echo "" >>"$temp_file"
}

# Starting directory
cd ~/.config/nvim/lua/plugins/dummy

# Copy leetcode.lua first
if [ -f "leetcode.lua" ]; then
  copy_file "leetcode.lua"
else
  echo "Error: leetcode.lua not found!" >>"$temp_file"
fi

# Copy all .lua files in leetcode_dependencies directory
if [ -d "leetcode_dependencies" ]; then
  cd leetcode_dependencies
  for file in *.lua; do
    if [ -f "$file" ]; then
      copy_file "$file"
    fi
  done

  # Also check for any nested .lua files
  if [ -d "leetcode_dependencies" ]; then
    cd leetcode_dependencies
    for file in *.lua; do
      if [ -f "$file" ]; then
        copy_file "$file"
      fi
    done
    cd ..
  fi
else
  echo "Error: leetcode_dependencies directory not found!" >>"$temp_file"
fi

# Copy the content to clipboard
if command -v xclip >/dev/null; then
  # For Linux with X11
  cat "$temp_file" | xclip -selection clipboard
  echo "Files copied to clipboard using xclip!"
elif command -v wl-copy >/dev/null; then
  # For Linux with Wayland
  cat "$temp_file" | wl-copy
  echo "Files copied to clipboard using wl-copy!"
elif command -v pbcopy >/dev/null; then
  # For macOS
  cat "$temp_file" | pbcopy
  echo "Files copied to clipboard using pbcopy!"
elif command -v clip.exe >/dev/null; then
  # For Windows with WSL
  cat "$temp_file" | clip.exe
  echo "Files copied to clipboard using clip.exe!"
else
  echo "No clipboard utility found. Content saved to: $temp_file"
  exit 1
fi

# Clean up
rm "$temp_file"
