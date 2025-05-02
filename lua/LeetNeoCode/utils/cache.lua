-- Cache manipulation utilities
local M = {}
local path = require "LeetNeoCode.utils.path"

-- Check if cache is stale or missing
function M.is_stale_or_missing(file_path, config)
  local stat = vim.loop.fs_stat(file_path)
  if not stat then
    return true
  end
  local mtime_secs = stat.mtime.sec or stat.mtime
  return (os.time() - mtime_secs) > (config.cache_expiry_days * 86400)
end

-- Load data from cache file
function M.load_from_cache(file_path)
  local f = io.open(file_path, "r")
  if not f then
    return nil
  end
  local raw = f:read "*a"
  f:close()
  local ok, data = pcall(vim.fn.json_decode, raw)
  return ok and data or nil
end

-- Save data to cache file
function M.save_to_cache(data, file_path, config)
  M.ensure_cache_dir(config)
  local f = io.open(file_path, "w")
  if not f then
    vim.notify("Failed to write to cache file: " .. file_path, vim.log.levels.ERROR)
    return false
  end
  f:write(vim.fn.json_encode(data))
  f:close()
  vim.notify("Data cached to: " .. file_path, vim.log.levels.INFO)
  return true
end

-- Ensure cache directory exists
function M.ensure_cache_dir(config)
  local cache_dir = config.cache_dir
  local meta_dir = cache_dir .. "/" .. config.cache_subdir
  if vim.fn.isdirectory(meta_dir) == 0 then
    vim.fn.mkdir(meta_dir, "p")
    vim.notify("Created cache directory: " .. meta_dir, vim.log.levels.INFO)
    return true
  end
  return false
end

return M
