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
command -v luarocks &>/dev/null || {
  warning "LuaRocks not detected."
  apt_ensure luarocks
}

# verify luarocks is now resolvable
command -v luarocks &>/dev/null || error "luarocks command still not found after installation."

success "LuaRocks is available: $(luarocks --version | head -1)"

# ── 3) magick Lua rock (skip if present) ──────────────────────────
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
  fi
done

# ── summary ───────────────────────────────────────────────────────
echo
echo "Summary:"
echo "  ✓ ImageMagick : $(convert --version | head -1)"
echo "  ✓ LuaRocks    : $(luarocks --version | head -1)"
echo "  ✓ cURL        : $(curl --version | head -1 | cut -d' ' -f1-3)"
echo "  ✓ magick rock : $(luarocks --lua-version=5.1 list | grep -m1 '^magick')"
success "image.nvim dependency check complete."
echo "Restart your terminal (or source your shell rc) before using :LC."
