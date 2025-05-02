-- Image rendering module
local M = {}

local terminal = require "LeetNeoCode.images.util.terminal"
local image_cache = require "LeetNeoCode.images.render.core.cache"
local display = require "LeetNeoCode.images.render.core.display"
local C = require "LeetNeoCode.config"

-- Forward terminal utility functions
M.can_display_images = terminal.can_display_images
M.is_terminal_supported = terminal.is_terminal_supported

-- Render an image in the buffer directly from URL
function M.render_image(buf, win, image_url, line_num)
  -- If image rendering is disabled, just show a placeholder
  if C.render_image == false then
    display.show_placeholder(buf, line_num, "[Image: Display disabled - enable with render_image=true]")
    return
  end

  -- Fallback if image.nvim is not installed
  if not M.can_display_images() then
    display.show_placeholder(buf, line_num, "[Image: Unable to display - image.nvim not available]")
    return
  end

  -- only render if this 'win' is the left-most window in the current tab
  local wins = vim.api.nvim_tabpage_list_wins(0)
  if wins[1] ~= win then
    return
  end

  -- Check if we already rendered this image
  if image_cache.is_cached(buf, line_num) then
    return
  end

  -- Fallback if terminal does not support inline images
  if not M.is_terminal_supported() then
    display.show_placeholder(buf, line_num, "[Image: Unable to display - terminal doesn't support images]")
    return
  end

  -- Ensure the target line is empty before rendering
  vim.api.nvim_buf_set_lines(buf, line_num, line_num + 1, false, { "" })

  -- Render the image with the display utility
  display.render_with_library(buf, win, image_url, line_num)
end

return M
