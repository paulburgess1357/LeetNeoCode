-- Image rendering cache utilities
local M = {}

-- Initialize global image cache if needed
function M.init_cache()
  _G.leetcode_image_cache = _G.leetcode_image_cache or {}
end

-- Check if an image is already cached for a specific buffer and line
function M.is_cached(buf, line_num)
  M.init_cache()
  local cache_key = buf .. "-" .. line_num
  return _G.leetcode_image_cache[cache_key] ~= nil
end

-- Mark an image as cached
function M.mark_cached(buf, line_num)
  M.init_cache()
  local cache_key = buf .. "-" .. line_num
  _G.leetcode_image_cache[cache_key] = true
end

-- Clear cached images for a buffer
function M.clear_buffer_cache(buf)
  M.init_cache()
  for key, _ in pairs(_G.leetcode_image_cache) do
    if key:match("^" .. buf .. "%-") then
      _G.leetcode_image_cache[key] = nil
    end
  end
end

return M
