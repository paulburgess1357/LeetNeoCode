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

# ── helper to prompt/apt-install if package missing ───────────────
apt_ensure() { # $1 = package name
  dpkg -s "$1" &>/dev/null && {
    info "$1 already installed."
    return
  }
  read -rp "Install $1? (y/N): " yn
  [[ ${yn,,} == y* ]] || error "$1 is required to continue."
  progress "Installing $1 …"
  sudo apt install -y "$1" || error "Failed to install $1."
  hash -r # refresh shell hash so new cmd is visible
  success "$1 installed."
}

# ── 1) ImageMagick & dev lib ──────────────────────────────────────
command -v convert &>/dev/null || warning "ImageMagick (convert) not found."
apt_ensure imagemagick
apt_ensure libmagickwand-dev

# ── 2) LuaRocks ───────────────────────────────────────────────────
luarocks_installed=false
if command -v luarocks &>/dev/null; then
  info "LuaRocks already installed: $(luarocks --version | head -1)"
  luarocks_installed=true
else
  warning "LuaRocks not detected."
  apt_ensure luarocks

  # Update PATH temporarily so luarocks becomes available in this script
  export PATH="$HOME/.luarocks/bin:$PATH"
  hash -r # refresh shell hash so new commands are visible

  # Verify luarocks is now resolvable
  if command -v luarocks &>/dev/null; then
    luarocks_installed=true
    success "LuaRocks is now available: $(luarocks --version | head -1)"
  else
    # Try to find luarocks binary
    LUAROCKS_PATH=$(find /usr -name luarocks 2>/dev/null | head -1)
    if [[ -n "$LUAROCKS_PATH" ]]; then
      export PATH="$(dirname "$LUAROCKS_PATH"):$PATH"
      hash -r
      if command -v luarocks &>/dev/null; then
        luarocks_installed=true
        success "Found LuaRocks at: $LUAROCKS_PATH"
        success "LuaRocks is now available: $(luarocks --version | head -1)"
      fi
    fi
  fi

  if ! $luarocks_installed; then
    error "luarocks command still not found after installation. You may need to restart your terminal."
  fi
fi

# ── 3) magick Lua rock (skip if present) ──────────────────────────
if $luarocks_installed; then
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
  warning "Skipping magick rock installation since LuaRocks is not available."
fi

# ── 4) cURL ───────────────────────────────────────────────────────
command -v curl &>/dev/null || apt_ensure curl

# ── 5) add LuaRocks paths to shell rc (once) ──────────────────────
for profile in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [[ -f $profile ]] || continue
  if ! grep -q '# LuaRocks paths for image.nvim' "$profile"; then
    {
      echo -e "\n# LuaRocks paths for image.nvim"
      echo 'export PATH="$HOME/.luarocks/bin:$PATH"'
      echo 'eval "$(luarocks path --lua-version=5.1)"'
    } >>"$profile"
    success "LuaRocks paths added to $profile"
  else
    info "LuaRocks paths already in $profile"
  fi
done

# ── summary ───────────────────────────────────────────────────────
echo
echo "Summary:"
echo "  ✓ ImageMagick : $(convert --version | head -1)"
echo "  $(if $luarocks_installed; then echo "✓"; else echo "✗"; fi) LuaRocks    : $(command -v luarocks &>/dev/null && luarocks --version | head -1 || echo "Not found in current PATH")"
echo "  ✓ cURL        : $(curl --version | head -1 | cut -d' ' -f1-3)"

if $luarocks_installed; then
  echo "  $(luarocks --lua-version=5.1 list | grep -q '^magick' && echo "✓" || echo "✗") magick rock : $(luarocks --lua-version=5.1 list | grep -m1 '^magick' || echo "Not installed")"
else
  echo "  ✗ magick rock : Cannot check (LuaRocks not available)"
fi

if $luarocks_installed; then
  success "image.nvim dependency check complete."
else
  warning "image.nvim dependency check incomplete - LuaRocks not found."
  echo -e "\nIMPORTANT: You need to restart your terminal or run:"
  echo -e "  source ~/.bashrc  (or ~/.zshrc if using zsh)"
  echo -e "Then run this script again to complete the installation."
fi

echo "Restart your terminal (or source your shell rc) before using :LC."
