-- Cache utilities for problem management
local vim = vim
local C = require "LeetNeoCode.config"

local M = {}

-- Get cache file path
function M.get_cache_path()
  return C.cache_dir .. "/" .. C.cache_subdir .. "/" .. C.cache_file
end

-- Get solution directory path
function M.get_solution_dir()
  return C.cache_dir .. "/" .. C.solutions_subdir
end

-- Check if cache is stale or missing
function M.cache_stale_or_missing(path)
  local stat = vim.loop.fs_stat(path)
  if not stat then
    return true
  end
  local mtime_secs = stat.mtime.sec or stat.mtime
  return (os.time() - mtime_secs) > (C.cache_expiry_days * 86400)
end

-- Load metadata from cache
function M.load_cache(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local raw = f:read "*a"
  f:close()
  local ok, data = pcall(vim.fn.json_decode, raw)
  return ok and data or nil
end

return M
