#!/usr/bin/env bash
# -----------------------------------------------------------
# Optional image-support bootstrap for nvim-leetcode
#   • Kitty terminal (optional)
#   • repo’s kitty.conf (optional, offered only if Kitty exists)
#   • ImageMagick + LuaRocks + magick rock (always)
# -----------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/colors.sh"

section "nvim-leetcode  –  image support"

echo "This step can set up:"
echo "  • Kitty terminal (for inline images)            – optional"
echo "  • kitty.conf from this repo                     – optional"
echo "  • ImageMagick, LuaRocks, magick Lua rock        – required for any image backend"
echo

read -rp "Run the image-support installer? (y/N): " yn
[[ ${yn,,} == y* ]] || {
  info "Skipping image support."
  exit 0
}

# ─────────────────────────────────────────────────────────────
# 1) Kitty terminal (optional)
# ─────────────────────────────────────────────────────────────
if ! command -v kitty &>/dev/null; then
  warning "Kitty terminal not detected."
  read -rp "Install Kitty now? (y/N): " kitty_yn
  if [[ ${kitty_yn,,} == y* ]]; then
    progress "Installing Kitty…"
    sudo apt update && sudo apt install -y kitty &&
      success "Kitty installed." || warning "Kitty install failed – continuing without Kitty."
  else
    info "Continuing without Kitty. Ensure your terminal supports inline images (WezTerm, iTerm2, etc.)."
  fi
else
  success "Kitty already installed."
fi

# ─────────────────────────────────────────────────────────────
# 2) kitty.conf (offered only if Kitty exists)
# ─────────────────────────────────────────────────────────────
if command -v kitty &>/dev/null; then
  read -rp "Install the repo’s kitty.conf? (y/N): " conf_yn
  if [[ ${conf_yn,,} == y* ]]; then
    KITTY_SRC="$SCRIPT_DIR/kitty.conf"
    KITTY_DIR="$HOME/.config/kitty"
    KITTY_DST="$KITTY_DIR/kitty.conf"

    if [[ -f $KITTY_SRC ]]; then
      mkdir -p "$KITTY_DIR"
      if [[ -f $KITTY_DST ]]; then
        cp --backup=numbered "$KITTY_DST" "${KITTY_DST}.bak"
        info "Existing kitty.conf backed up → ${KITTY_DST}.bak"
      fi
      cp "$KITTY_SRC" "$KITTY_DST"
      success "kitty.conf installed → $KITTY_DST"
    else
      warning "kitty.conf not found in the repo – skipping."
    fi
  else
    info "Keeping your existing kitty configuration."
  fi
fi

# ─────────────────────────────────────────────────────────────
# 3) ImageMagick + LuaRocks + magick rock
# ─────────────────────────────────────────────────────────────
IMG_SCRIPT="$SCRIPT_DIR/install_image_dependencies.sh"
[[ -f $IMG_SCRIPT ]] || error "Missing $IMG_SCRIPT – copy it into install/ first."

chmod +x "$IMG_SCRIPT"
bash "$IMG_SCRIPT"

section "Image support complete"
success "Setup finished.  Restart your terminal and open Neovim – :LC will now show images if your terminal supports them."
