-- Problem cache handling
local vim = vim
local C = require("nvim-leetcode.config")
local pull = require("nvim-leetcode.pull")

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
  local raw = f:read("*a")
  f:close()
  local ok, data = pcall(vim.fn.json_decode, raw)
  return ok and data or nil
end

-- Ensure cache is fresh, pull if needed
function M.ensure_fresh_cache()
  local cache_path = M.get_cache_path()
  if M.cache_stale_or_missing(cache_path) then
    vim.notify(
      ("Metadata cache missing/older than %d days; pulling…"):format(C.cache_expiry_days),
      vim.log.levels.INFO
    )
    pull.pull_problems()
  end
end

-- Resolve problem by number, return metadata
function M.resolve_problem(num)
  local cache_path = M.get_cache_path()
  local meta = M.load_cache(cache_path)
  if not meta or not meta.stat_status_pairs then
    vim.notify("Failed to load metadata cache", vim.log.levels.ERROR)
    return nil
  end

  -- Find problem by number
  local slug, title, paid_only, found
  for _, pair in ipairs(meta.stat_status_pairs) do
    if pair.stat.frontend_question_id == num then
      slug = pair.stat.question__title_slug
      title = pair.stat.question__title
      paid_only = pair.paid_only
      found = true
      break
    end
  end

  if not found then
    vim.notify("Problem #" .. num .. " not found.", vim.log.levels.ERROR)
    return nil
  end

  return meta, slug, title, paid_only
end

return M
