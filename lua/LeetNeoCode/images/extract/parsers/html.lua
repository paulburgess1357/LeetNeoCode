-- HTML image extraction utilities
local M = {}

-- Extract image URLs from HTML content
function M.extract_urls(html_content)
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

return M
