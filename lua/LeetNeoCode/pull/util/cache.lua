-- Cache utilities for pull operations
local vim = vim
local C = require "LeetNeoCode.config"

local M = {}

-- Get full path to cache file
function M.get_cache_path()
  return C.cache_dir .. "/" .. C.cache_subdir .. "/" .. C.cache_file
end

-- Ensure cache directory exists
function M.ensure_cache_dir()
  local meta_dir = C.cache_dir .. "/" .. C.cache_subdir
  if vim.fn.isdirectory(meta_dir) == 0 then
    vim.fn.mkdir(meta_dir, "p")
    vim.notify("Created LeetCode cache directory: " .. meta_dir, vim.log.levels.INFO)
    return true
  end
  return false
end

-- Save data to cache file
function M.save_to_cache(data)
  M.ensure_cache_dir()
  local cache_file = M.get_cache_path()
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

return M
