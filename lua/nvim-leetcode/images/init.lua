-- Main image handling module
local M = {}

local C = require("nvim-leetcode.config")
local extract = require("nvim-leetcode.images.extract")
local render = require("nvim-leetcode.images.render")

-- Get image cache directory path for a specific problem
function M.get_image_cache_dir(num, title, slug)
  local safe_title = (title or slug):gsub("%W+", "_"):gsub("^_+", ""):gsub("_+$", "")
  local sol_base = C.cache_dir
  local img_dir = sol_base .. "/images/LC" .. num .. "_" .. safe_title

  -- Create the directory if it doesn't exist
  if vim.fn.isdirectory(sol_base .. "/images") == 0 then
    vim.fn.mkdir(sol_base .. "/images", "p")
  end
  if vim.fn.isdirectory(img_dir) == 0 then
    vim.fn.mkdir(img_dir, "p")
  end

  return img_dir
end

-- Forward the extract module functions
M.extract_image_urls = extract.extract_image_urls
M.prepare_image_urls = extract.prepare_image_urls

-- Forward the render module functions
M.can_display_images = render.can_display_images
M.is_terminal_supported = render.is_terminal_supported
M.render_image = render.render_image

return M
