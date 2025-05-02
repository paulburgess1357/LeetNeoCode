-- Image display utilities
local M = {}
local terminal = require "LeetNeoCode.images.util.terminal"
local dimensions = require "LeetNeoCode.images.render.core.dimensions"
local image_cache = require "LeetNeoCode.images.render.core.cache"
local C = require "LeetNeoCode.config"

-- Show a placeholder message in the buffer
function M.show_placeholder(buf, line_num, message)
  vim.api.nvim_buf_set_lines(buf, line_num, line_num + 1, false, { message })
end

-- Render image with image.nvim library
function M.render_with_library(buf, win, image_url, line_num)
  local img_lib = require "image"
  local max_width, max_height = dimensions.calculate_dimensions(win)

  -- Only try to use image.nvim functions if we're sure it's properly set up
  local success, _ = pcall(function()
    -- Clear any existing images at this position
    img_lib.clear { buffer = buf, window = win }

    -- Fetch and render the image with proper type-compatible geometry
    img_lib.from_url(image_url, {
      window = win,
      buffer = buf,
      with_virtual_padding = true,
      x = 0,
      y = line_num,
      max_width_window_percentage = C.image_max_width_pct,
      max_height_window_percentage = C.image_max_height_pct,
    }, function(img)
      if img then
        -- Render with proper geometry properties according to type definitions
        img:render {
          width = max_width,
          height = max_height,
        }
        -- Only mark as rendered if we successfully loaded and rendered the image
        image_cache.mark_cached(buf, line_num)
      else
        M.show_placeholder(buf, line_num, "[Image: Failed to load from URL]")
      end
    end)
  end)

  -- If there was an error using image.nvim, show a placeholder
  if not success then
    M.show_placeholder(buf, line_num, "[Image: Disabled or image.nvim may not be set up]")
  end
end

return M
