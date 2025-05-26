-- Image directory management utilities
local M = {}
local C = require "LeetNeoCode.config"

-- Get image cache directory path for a specific problem with zero-padded number
function M.get_image_cache_dir(num, title, slug)
  local safe_title = (title or slug):gsub("%W+", "_"):gsub("^_+", ""):gsub("_+$", "")
  local sol_base = C.cache_dir
  -- Use zero-padded 5-digit number format
  local img_dir = sol_base .. "/" .. C.images_subdir .. "/LC" .. string.format("%05d", num) .. "_" .. safe_title

  -- Create the directory if it doesn't exist
  if vim.fn.isdirectory(sol_base .. "/" .. C.images_subdir) == 0 then
    vim.fn.mkdir(sol_base .. "/" .. C.images_subdir, "p")
  end
  if vim.fn.isdirectory(img_dir) == 0 then
    vim.fn.mkdir(img_dir, "p")
  end

  return img_dir
end

return M
