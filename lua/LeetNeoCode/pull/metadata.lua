-- LeetCode problem list fetching module
local vim = vim
local C = require("LeetNeoCode.config")

local M = {}

-- Get full path to cache file
local function get_cache_path()
  return C.cache_dir .. "/" .. C.cache_subdir .. "/" .. C.cache_file
end

-- Ensure cache directory exists
local function ensure_cache_dir()
  local meta_dir = C.cache_dir .. "/" .. C.cache_subdir
  if vim.fn.isdirectory(meta_dir) == 0 then
    vim.fn.mkdir(meta_dir, "p")
    vim.notify("Created LeetCode cache directory: " .. meta_dir, vim.log.levels.INFO)
  end
end

-- Save Lua table to cache file
local function save_to_cache(data)
  ensure_cache_dir()
  local cache_file = get_cache_path()
  local f = io.open(cache_file, "w")
  if not f then
    vim.notify("Failed to write to cache file: " .. cache_file, vim.log.levels.ERROR)
    return false
  end
  f:write(vim.fn.json_encode(data))
  f:close()
  vim.notify("LeetCode problem data cached to: " .. cache_file, vim.log.levels.INFO)
  return true
end

-- Fetch & cache the full problem list (synchronous)
function M.pull_problems()
  vim.notify("Pulling LeetCode problem data...", vim.log.levels.INFO)

  ensure_cache_dir()
  local cache_file = get_cache_path()

  -- Synchronous fetch of the metadata JSON
  local json_str = vim.fn.system({ "curl", "-s", C.API_URL })
  if vim.v.shell_error ~= 0 or not json_str or #json_str == 0 then
    vim.notify("Failed to fetch LeetCode data (curl error)", vim.log.levels.ERROR)
    return
  end

  -- Parse JSON
  local ok, parsed = pcall(vim.fn.json_decode, json_str)
  if not ok or type(parsed) ~= "table" then
    vim.notify("Failed to parse LeetCode API response", vim.log.levels.ERROR)
    return
  end

  -- Save to cache
  if save_to_cache(parsed) then
    vim.notify("Successfully pulled " .. (parsed.num_total or "?") .. " LeetCode problems", vim.log.levels.INFO)
  end
end

return M
