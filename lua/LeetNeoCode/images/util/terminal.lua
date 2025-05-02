-- Terminal capability detection utilities
local M = {}
local C = require "LeetNeoCode.config"

-- Check if image.nvim is available
function M.can_display_images()
  return pcall(require, "image")
end

-- Check if terminal supports images (Kitty, etc.)
function M.is_terminal_supported()
  for _, check in ipairs(C.image_terminals or {}) do
    local v = os.getenv(check.var)
    if v then
      if not check.match or v:find(check.match, 1, true) then
        return true
      end
    end
  end
  return false
end

return M
