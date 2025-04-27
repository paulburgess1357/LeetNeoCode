#!/usr/bin/env bash
# uninstall/uninstall_image_support.sh
# -----------------------------------------------------------
# Interactive remover for *everything* image_support.sh added:
#   • kitty.conf backup / restore / delete
#   • Kitty package (apt)      – optional
#   • ImageMagick + libmagickwand-dev (apt) – optional
#   • LuaRocks magick rock     – optional
#   • LuaRocks itself (apt)    – optional
#   • Removes LuaRocks PATH lines from ~/.bashrc / ~/.zshrc
# -----------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/colors.sh"

section "nvim-leetcode  –  image-support uninstaller"

confirm() { # $1 prompt  $2 default n/y
  local def=${2:-n}
  local prompt="[${def^^}/$([[ $def == y ]] && echo n || echo y)]"
  read -rp "$(echo -e ${BOLD}${YELLOW}$1 $prompt:${RESET}) " ans
  [[ -z $ans ]] && ans=$def
  [[ ${ans,,} == y* ]]
}

# ── kitty.conf & Kitty terminal ─────────────────────────────
if command -v kitty &>/dev/null; then
  if confirm "Delete ~/.config/kitty/kitty.conf installed by the script?" n; then
    CONF=~/.config/kitty/kitty.conf
    if [[ -f $CONF ]]; then
      rm -f "$CONF" && success "Removed kitty.conf."
      # restore latest numbered backup if present
      BACKUP=$(ls -1 ~/.config/kitty/kitty.conf.bak* 2>/dev/null | tail -n1)
      if [[ -n $BACKUP ]]; then
        if confirm "Restore most recent backup ($BACKUP)?" y; then
          mv "$BACKUP" "$CONF" && success "Backup restored."
        fi
      fi
    else
      info "kitty.conf not found – nothing to remove."
    fi
  fi

  if confirm "Uninstall Kitty itself (apt remove kitty)?" n; then
    progress "Removing Kitty…"
    sudo apt remove -y kitty && success "Kitty removed." ||
      warning "Failed to remove Kitty."
  fi
else
  info "Kitty not installed – skipping."
fi

# ── ImageMagick ─────────────────────────────────────────────
if confirm "Remove ImageMagick + dev library?" n; then
  progress "Removing ImageMagick…"
  sudo apt remove -y imagemagick libmagickwand-dev &&
    success "ImageMagick removed." ||
    warning "Failed to remove ImageMagick."
fi

# ── LuaRocks & magick rock ─────────────────────────────────
if command -v luarocks &>/dev/null; then
  if luarocks --lua-version=5.1 show magick >/dev/null 2>&1; then
    if confirm "Remove magick Lua rock?" y; then
      luarocks --lua-version=5.1 remove --local magick &&
        success "magick rock removed."
    fi
  fi

  if confirm "Uninstall LuaRocks itself?" n; then
    sudo apt remove -y luarocks && success "LuaRocks removed."
  fi

  # clean ~/.bashrc / ~/.zshrc
  for profile in ~/.bashrc ~/.zshrc; do
    [[ -f $profile ]] || continue
    if grep -q '# LuaRocks paths for image.nvim' "$profile"; then
      progress "Cleaning LuaRocks PATH lines from $profile…"
      sed -i '/# LuaRocks paths for image.nvim/,+2d' "$profile"
      success "Removed LuaRocks block from $profile."
    fi
  done
else
  info "LuaRocks not installed – skipping."
fi

section "Uninstall complete"
success "Requested components have been removed (where chosen)."
info "If you removed LuaRocks PATH lines, restart your shell."
