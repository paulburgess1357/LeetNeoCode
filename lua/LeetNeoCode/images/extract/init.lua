-- Image extraction utilities
local M = {}

-- Extract image URLs from HTML content
function M.extract_image_urls(html_content)
  if not html_content or html_content == "" then
    return {}
  end
  local urls = {}
  -- Improved regex to better capture image tags
  for url in html_content:gmatch '<img[^>]-src="([^"]-)"' do
    if url:sub(1, 4) ~= "http" then
      url = "https://leetcode.com" .. url
    end
    table.insert(urls, url)
  end
  return urls
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
