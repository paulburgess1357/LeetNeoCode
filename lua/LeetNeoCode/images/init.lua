-- Main image handling module
local M = {}

local directory = require "LeetNeoCode.images.core.directory"
local extract = require "LeetNeoCode.images.extract"
local render = require "LeetNeoCode.images.render"

-- Get image cache directory path for a specific problem
M.get_image_cache_dir = directory.get_image_cache_dir

-- Export the extract module functions
M.extract_image_urls = extract.extract_image_urls
M.prepare_image_urls = extract.prepare_image_urls

-- Export the render module functions
M.can_display_images = render.can_display_images
M.is_terminal_supported = render.is_terminal_supported
M.render_image = render.render_image

return M
