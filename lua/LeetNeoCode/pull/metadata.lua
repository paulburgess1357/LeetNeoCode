-- LeetCode problem list fetching module
local vim = vim
local C = require "LeetNeoCode.config"
local cache_utils = require "LeetNeoCode.pull.util.cache"

local M = {}

-- Fetch & cache the full problem list (synchronous)
function M.pull_problems()
  vim.notify("Pulling LeetCode problem data...", vim.log.levels.INFO)

  cache_utils.ensure_cache_dir()
  local cache_file = cache_utils.get_cache_path()

  -- Synchronous fetch of the metadata JSON
  local json_str = vim.fn.system { "curl", "-s", C.API_URL }
  if vim.v.shell_error ~= 0 or not json_str or #json_str == 0 then
    vim.notify("Failed to fetch LeetCode data (curl error)", vim.log.levels.ERROR)
    return false
  end

  -- Parse JSON
  local ok, parsed = pcall(vim.fn.json_decode, json_str)
  if not ok or type(parsed) ~= "table" then
    vim.notify("Failed to parse LeetCode API response", vim.log.levels.ERROR)
    return false
  end

  -- Save to cache
  if cache_utils.save_to_cache(parsed) then
    vim.notify("Successfully pulled " .. (parsed.num_total or "?") .. " LeetCode problems", vim.log.levels.INFO)
    return true
  end

  return false
end

return M
