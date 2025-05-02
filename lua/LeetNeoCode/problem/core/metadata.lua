-- Problem metadata management
local vim = vim
local C = require "LeetNeoCode.config"
local pull = require "LeetNeoCode.pull"
local cache_utils = require "LeetNeoCode.problem.util.cache_utils"

local M = {}

-- Export cache utility functions for backward compatibility
M.get_cache_path = cache_utils.get_cache_path
M.get_solution_dir = cache_utils.get_solution_dir
M.load_cache = cache_utils.load_cache
M.cache_stale_or_missing = cache_utils.cache_stale_or_missing

-- Ensure cache is fresh, pull if needed
function M.ensure_fresh_cache()
  local cache_path = cache_utils.get_cache_path()
  if cache_utils.cache_stale_or_missing(cache_path) then
    vim.notify(
      ("Metadata cache missing/older than %d days; pulling…"):format(C.cache_expiry_days),
      vim.log.levels.INFO
    )
    pull.pull_problems()
  end
end

-- Resolve problem by number, return metadata
function M.resolve_problem(num)
  local cache_path = cache_utils.get_cache_path()
  local meta = cache_utils.load_cache(cache_path)
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
