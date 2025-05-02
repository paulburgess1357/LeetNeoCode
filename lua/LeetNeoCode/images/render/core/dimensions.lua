-- Image dimension calculation utilities
local M = {}
local C = require "LeetNeoCode.config"

-- Calculate image dimensions based on configuration and window size
function M.calculate_dimensions(win)
  local default_max_width = math.floor(vim.o.columns * 0.35)
  local max_width = nil
  local max_height = nil

  -- Get window dimensions for percentage calculations
  local win_width = vim.api.nvim_win_get_width(win)
  local win_height = vim.api.nvim_win_get_height(win)

  -- Calculate dimensions based on percentages or fixed values
  if C.image_max_width_pct and C.image_max_width_pct > 0 then
    max_width = math.floor(win_width * (C.image_max_width_pct / 100))
  else
    max_width = C.image_max_width or default_max_width
  end

  if C.image_max_height_pct and C.image_max_height_pct > 0 then
    max_height = math.floor(win_height * (C.image_max_height_pct / 100))
  else
    max_height = C.image_max_height or 20
  end

  return max_width, max_height
end

return M
