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
    success "Main ImageMagick packages removed." ||
    warning "Failed to remove main ImageMagick packages."

  # Check for any remaining ImageMagick packages
  REMAINING_PACKAGES=$(dpkg -l | grep -i imagemagick | awk '{print $2}')
  if [[ -n "$REMAINING_PACKAGES" ]]; then
    echo "Remaining ImageMagick-related packages found:"
    for pkg in $REMAINING_PACKAGES; do
      echo "  - $pkg"
    done

    if confirm "Would you like to remove all remaining ImageMagick packages?" y; then
      if confirm "Use purge instead of remove (will also delete configuration files)?" n; then
        progress "Purging all remaining ImageMagick packages…"
        sudo apt purge -y $REMAINING_PACKAGES &&
          success "All ImageMagick packages purged." ||
          warning "Failed to purge some ImageMagick packages."
      else
        progress "Removing all remaining ImageMagick packages…"
        sudo apt remove -y $REMAINING_PACKAGES &&
          success "All ImageMagick packages removed." ||
          warning "Failed to remove some ImageMagick packages."
      fi
    fi
  else
    success "No remaining ImageMagick packages found."
  fi

  # Also check for magickwand-related packages
  MAGICK_WAND_PACKAGES=$(dpkg -l | grep -i magickwand | awk '{print $2}')
  if [[ -n "$MAGICK_WAND_PACKAGES" ]]; then
    echo "MagickWand-related packages found:"
    for pkg in $MAGICK_WAND_PACKAGES; do
      echo "  - $pkg"
    done

    if confirm "Would you like to remove all MagickWand packages?" y; then
      if confirm "Use purge instead of remove (will also delete configuration files)?" n; then
        progress "Purging all MagickWand packages…"
        sudo apt purge -y $MAGICK_WAND_PACKAGES &&
          success "All MagickWand packages purged." ||
          warning "Failed to purge some MagickWand packages."
      else
        progress "Removing all MagickWand packages…"
        sudo apt remove -y $MAGICK_WAND_PACKAGES &&
          success "All MagickWand packages removed." ||
          warning "Failed to remove some MagickWand packages."
      fi
    fi
  else
    success "No MagickWand packages found."
  fi

  # Cleanup any unused dependencies
  if confirm "Run apt autoremove to clean up any unused dependencies?" y; then
    progress "Cleaning up unused dependencies…"
    sudo apt autoremove -y &&
      success "Unused dependencies removed." ||
      warning "Failed to remove some unused dependencies."
  fi
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

    # Check for any remaining LuaRocks packages
    REMAINING_LUAROCKS=$(dpkg -l | grep -i luarocks | awk '{print $2}')
    if [[ -n "$REMAINING_LUAROCKS" ]]; then
      echo "Remaining LuaRocks-related packages found:"
      for pkg in $REMAINING_LUAROCKS; do
        echo "  - $pkg"
      done

      if confirm "Would you like to remove all remaining LuaRocks packages?" y; then
        if confirm "Use purge instead of remove (will also delete configuration files)?" n; then
          progress "Purging all remaining LuaRocks packages…"
          sudo apt purge -y $REMAINING_LUAROCKS &&
            success "All LuaRocks packages purged." ||
            warning "Failed to purge some LuaRocks packages."
        else
          progress "Removing all remaining LuaRocks packages…"
          sudo apt remove -y $REMAINING_LUAROCKS &&
            success "All LuaRocks packages removed." ||
            warning "Failed to remove some LuaRocks packages."
        fi
      fi
    else
      success "No remaining LuaRocks packages found."
    fi
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

# Check if any Lua-related packages are still installed
if confirm "Check for any remaining Lua packages?" n; then
  LUA_PACKAGES=$(dpkg -l | grep -i lua | awk '{print $2}')
  if [[ -n "$LUA_PACKAGES" ]]; then
    echo "The following Lua-related packages are still installed:"
    for pkg in $LUA_PACKAGES; do
      echo "  - $pkg"
    done

    if confirm "Would you like to list these in a file for reference?" y; then
      echo "$LUA_PACKAGES" >lua-packages.txt
      success "Listed Lua packages in $(pwd)/lua-packages.txt"
    fi

    if confirm "Would you like to remove ALL Lua-related packages? (USE WITH CAUTION)" n; then
      if confirm "Use purge instead of remove (will also delete configuration files)?" n; then
        progress "Purging all Lua-related packages…"
        sudo apt purge -y $LUA_PACKAGES &&
          success "All Lua-related packages purged." ||
          warning "Failed to purge some Lua-related packages."
      else
        progress "Removing all Lua-related packages…"
        sudo apt remove -y $LUA_PACKAGES &&
          success "All Lua-related packages removed." ||
          warning "Failed to remove some Lua-related packages."
      fi
    fi
  else
    success "No Lua-related packages found."
  fi
fi

section "Uninstall complete"
success "Requested components have been removed (where chosen)."
info "If you removed LuaRocks PATH lines, restart your shell."

# Final verification
echo
echo "Final verification:"
echo "  ImageMagick packages: $(dpkg -l | grep -i imagemagick | wc -l) remaining"
echo "  MagickWand packages: $(dpkg -l | grep -i magickwand | wc -l) remaining"
echo "  LuaRocks packages: $(dpkg -l | grep -i luarocks | wc -l) remaining"
echo
if command -v convert &>/dev/null; then
  warning "ImageMagick 'convert' command is still available."
else
  success "ImageMagick 'convert' command has been removed."
fi
if command -v luarocks &>/dev/null; then
  warning "LuaRocks command is still available."
else
  success "LuaRocks command has been removed."
fi
