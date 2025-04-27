#!/bin/bash

# Source common color and function definitions
source "utils/colors.sh"

echo "===== Installing image.nvim Dependencies ====="
echo "This script will install dependencies required by image.nvim"
echo "These dependencies are needed for the LeetCode plugin to display images."
echo

# Check if ImageMagick is installed
check_imagemagick() {
  if ! command -v convert &>/dev/null; then
    read -p "ImageMagick is required but not installed. Install it now? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      echo "Installing ImageMagick development version..."
      sudo apt install -y libmagickwand-dev imagemagick
      if [ $? -ne 0 ]; then
        error "Failed to install ImageMagick. Aborting."
      fi
      success "ImageMagick installed successfully."
    else
      error "ImageMagick is required to continue."
    fi
  else
    echo "ImageMagick is already installed."

    # Check if development version is installed
    if ! dpkg -l | grep -q "libmagickwand-dev"; then
      read -p "ImageMagick development version is required but not installed. Install it now? (y/n): " choice
      if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo "Installing ImageMagick development version..."
        sudo apt install -y libmagickwand-dev
        if [ $? -ne 0 ]; then
          error "Failed to install ImageMagick development version. Aborting."
        fi
        success "ImageMagick development version installed successfully."
      else
        error "ImageMagick development version is required to continue."
      fi
    else
      echo "ImageMagick development version is already installed."
    fi
  fi
}

# Check if LuaRocks is installed
check_luarocks() {
  if ! command -v luarocks &>/dev/null; then
    read -p "LuaRocks is required but not installed. Install it now? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      echo "Installing LuaRocks..."
      sudo apt install -y luarocks
      if [ $? -ne 0 ]; then
        error "Failed to install LuaRocks. Aborting."
      fi
      success "LuaRocks installed successfully."
    else
      error "LuaRocks is required to continue."
    fi
  else
    echo "LuaRocks is already installed."
  fi
}

# Install Magick Lua rock
install_magick_rock() {
  echo "Installing magick Lua rock..."
  luarocks --local --lua-version=5.1 install magick
  if [ $? -ne 0 ]; then
    error "Failed to install magick Lua rock. Aborting."
  fi
  success "Magick Lua rock installed successfully."

  # Add LuaRocks paths to user's shell profile
  local shell_profile=""
  if [ -f "$HOME/.bashrc" ]; then
    shell_profile="$HOME/.bashrc"
  elif [ -f "$HOME/.zshrc" ]; then
    shell_profile="$HOME/.zshrc"
  fi

  if [ -n "$shell_profile" ]; then
    echo "Adding LuaRocks paths to $shell_profile..."

    # Check if the paths are already in the file
    if ! grep -q "package.path.*luarocks/share/lua" "$shell_profile"; then
      echo >>"$shell_profile"
      echo "# LuaRocks paths for image.nvim" >>"$shell_profile"
      echo "export PATH=\"\$HOME/.luarocks/bin:\$PATH\"" >>"$shell_profile"
      echo "eval \"\$(luarocks path --lua-version=5.1)\"" >>"$shell_profile"
      success "LuaRocks paths added to $shell_profile."
    else
      echo "LuaRocks paths already present in $shell_profile."
    fi
  else
    echo "Could not find a shell profile to update. Please manually add LuaRocks paths to your shell profile."
  fi
}

# Check if cURL is installed
check_curl() {
  if ! command -v curl &>/dev/null; then
    read -p "cURL is required but not installed. Install it now? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      echo "Installing cURL..."
      sudo apt install -y curl
      if [ $? -ne 0 ]; then
        error "Failed to install cURL. Aborting."
      fi
      success "cURL installed successfully."
    else
      error "cURL is required to continue."
    fi
  else
    echo "cURL is already installed."
  fi
}

# Update package lists
progress "Updating package lists..."
sudo apt update

# Install dependencies
check_imagemagick
check_luarocks
check_curl
install_magick_rock

echo
echo "Summary of image.nvim dependencies:"
echo "-----------------------------"
echo "✓ ImageMagick: $(convert --version | head -n 1)"
echo "✓ LuaRocks: $(luarocks --version)"
echo "✓ cURL: $(curl --version | head -n 1)"
echo "✓ Magick Lua rock: Installed locally"

success "image.nvim dependencies installation completed."
echo
echo "You will need to restart your terminal or source your shell profile for the changes to take effect."
echo "After that, the LeetCode plugin should be able to display images properly."
