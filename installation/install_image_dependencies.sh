#!/usr/bin/env bash
# ------------------------------------------------------------------
# install/install_image_dependencies.sh
# Installs (or verifies) everything image.nvim needs:
#   • ImageMagick + libmagickwand-dev
#   • LuaRocks
#   • magick Lua rock (5.1, --local)
#   • Adds LuaRocks PATH & lua paths to ~/.bashrc or ~/.zshrc (once)
#   • cURL (used by the installer & image.nvim fallback fetcher)
# ------------------------------------------------------------------
source "utils/colors.sh"
section "Installing image.nvim dependencies"

# ── 1) ImageMagick & dev lib ──────────────────────────────────────
if ! command -v convert &>/dev/null; then
  warning "ImageMagick (convert) not found."
  read -rp "Install imagemagick? (y/N): " yn
  if [[ ${yn,,} == y* ]]; then
    progress "Installing imagemagick …"
    sudo apt install -y imagemagick || error "Failed to install imagemagick."
    success "imagemagick installed."
  else
    error "imagemagick is required to continue."
  fi
else
  info "imagemagick already installed."
fi

# Check if libmagickwand-dev is installed
if ! dpkg -s libmagickwand-dev &>/dev/null; then
  warning "libmagickwand-dev not found."
  read -rp "Install libmagickwand-dev? (y/N): " yn
  if [[ ${yn,,} == y* ]]; then
    progress "Installing libmagickwand-dev …"
    sudo apt install -y libmagickwand-dev || error "Failed to install libmagickwand-dev."
    success "libmagickwand-dev installed."
  else
    error "libmagickwand-dev is required to continue."
  fi
else
  info "libmagickwand-dev already installed."
fi

# ── 2) LuaRocks ───────────────────────────────────────────────────
if ! command -v luarocks &>/dev/null; then
  warning "LuaRocks not found."
  read -rp "Install luarocks? (y/N): " yn
  if [[ ${yn,,} == y* ]]; then
    progress "Installing luarocks …"
    sudo apt install -y luarocks || error "Failed to install luarocks."

    # Source possible locations of luarocks to make it available immediately
    # Try to locate the luarocks executable
    for possible_path in "/usr/bin/luarocks" "/usr/local/bin/luarocks" "$HOME/.luarocks/bin/luarocks"; do
      if [[ -x "$possible_path" ]]; then
        export PATH="$(dirname "$possible_path"):$PATH"
        break
      fi
    done

    # Verify luarocks is now available
    if command -v luarocks &>/dev/null; then
      success "luarocks installed and available: $(luarocks --version | head -1)"
    else
      warning "luarocks installed but not in PATH. You'll need to restart your terminal."
      warning "Installation will continue but you may need to run this script again after restarting your terminal."
    fi
  else
    error "luarocks is required to continue."
  fi
else
  info "luarocks already installed: $(luarocks --version | head -1)"
fi

# ── 3) magick Lua rock (skip if present) ──────────────────────────
if command -v luarocks &>/dev/null; then
  if luarocks --lua-version=5.1 show magick >/dev/null 2>&1; then
    info "magick rock already installed."
    read -rp "Reinstall/upgrade magick rock? (y/N): " up
    [[ ${up,,} == y* ]] || magick_skip=true
  fi

  if [[ -z $magick_skip ]]; then
    progress "Installing magick Lua rock…"
    luarocks --local --lua-version=5.1 install magick ||
      error "Failed to install magick rock."
    success "magick rock installed."
  fi
else
  warning "Skipping magick rock installation because luarocks is not available yet."
  warning "You'll need to restart your terminal and run this script again to install magick rock."
fi

# ── 4) cURL ───────────────────────────────────────────────────────
if ! command -v curl &>/dev/null; then
  warning "cURL not found."
  read -rp "Install curl? (y/N): " yn
  if [[ ${yn,,} == y* ]]; then
    progress "Installing curl …"
    sudo apt install -y curl || error "Failed to install curl."
    success "curl installed."
  else
    error "curl is required to continue."
  fi
else
  info "curl already installed."
fi

# ── 5) add LuaRocks paths to shell rc (once) ──────────────────────
added_path=false
for profile in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [[ -f $profile ]] || continue
  if ! grep -q '# LuaRocks paths for image.nvim' "$profile"; then
    {
      echo -e "\n# LuaRocks paths for image.nvim"
      echo 'export PATH="$HOME/.luarocks/bin:$PATH"'
      echo 'eval "$(luarocks path --lua-version=5.1)"'
    } >>"$profile"
    success "LuaRocks paths added to $profile"
    added_path=true
  else
    info "LuaRocks paths already in $profile"
  fi
done

# ── summary ───────────────────────────────────────────────────────
echo
echo "Summary:"
echo "  ✓ ImageMagick : $(convert --version | head -1)"
echo "  $(command -v luarocks &>/dev/null && echo "✓" || echo "✗") LuaRocks    : $(command -v luarocks &>/dev/null && luarocks --version | head -1 || echo "Not available in current PATH")"
echo "  ✓ cURL        : $(curl --version | head -1 | cut -d' ' -f1-3)"

magick_installed=false
if command -v luarocks &>/dev/null; then
  if luarocks --lua-version=5.1 list | grep -q '^magick'; then
    echo "  ✓ magick rock : $(luarocks --lua-version=5.1 list | grep -m1 '^magick')"
    magick_installed=true
  else
    echo "  ✗ magick rock : Not installed"
  fi
else
  echo "  ✗ magick rock : Cannot check (LuaRocks not available in current PATH)"
fi

if command -v luarocks &>/dev/null && $magick_installed; then
  success "image.nvim dependency check complete. All dependencies installed!"
else
  if $added_path; then
    warning "image.nvim dependency check incomplete."
    echo -e "\nIMPORTANT: You need to restart your terminal or run:"
    echo -e "  source ~/.bashrc  (or ~/.zshrc if using zsh)"
    echo -e "Then run this script again to complete the installation."
  else
    warning "image.nvim dependency check incomplete. Some dependencies are missing."
    echo -e "\nPlease restart your terminal and run this script again."
  fi
fi
