-- Image extraction module
local M = {}
local html_parser = require "LeetNeoCode.images.extract.parsers.html"

-- Extract image URLs from HTML content
function M.extract_image_urls(html_content)
  return html_parser.extract_urls(html_content)
end

-- Prepare image URLs for rendering
function M.prepare_image_urls(html_content)
  local urls = M.extract_image_urls(html_content)
  local image_data = {}

  for i, url in ipairs(urls) do
    table.insert(image_data, { index = i, url = url })
  end

  return image_data
end

return M
