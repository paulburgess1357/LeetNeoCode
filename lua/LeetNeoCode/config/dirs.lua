-- Directory management functions for LeetNeoCode
local M = {}
local options = require "LeetNeoCode.config.options"
local paths = require "LeetNeoCode.utils.path"

-- Find dependencies directory (now using the centralized function)
function M.get_dependencies_dir()
  return paths.find_dependencies_dir()
end

-- Ensure cache directories exist
function M.ensure_cache_dirs()
  -- main dir
  if vim.fn.isdirectory(options.cache_dir) == 0 then
    vim.fn.mkdir(options.cache_dir, "p")
  end
  -- metadata
  local meta_dir = options.cache_dir .. "/" .. options.cache_subdir
  if vim.fn.isdirectory(meta_dir) == 0 then
    vim.fn.mkdir(meta_dir, "p")
  end
  -- solutions
  local sol_dir = options.cache_dir .. "/" .. options.solutions_subdir
  if vim.fn.isdirectory(sol_dir) == 0 then
    vim.fn.mkdir(sol_dir, "p")
  end
  -- images (only if we cache locally)
  if not options.use_direct_urls then
    local img_dir = options.cache_dir .. "/" .. options.images_subdir
    if vim.fn.isdirectory(img_dir) == 0 then
      vim.fn.mkdir(img_dir, "p")
  end
  -- recent solutions (always create this)
  local recent_dir = options.cache_dir .. "/" .. options.solutions_recent_subdir
  if vim.fn.isdirectory(recent_dir) == 0 then
    vim.fn.mkdir(recent_dir, "p")
  end
  -- random solutions (always create this)
  local random_dir = options.cache_dir .. "/" .. options.solutions_random_subdir
  if vim.fn.isdirectory(random_dir) == 0 then
    vim.fn.mkdir(random_dir, "p")
  end
  -- keyword search directory (always create this)
  local keyword_dir = options.cache_dir .. "/" .. "solutions_keywords"
  if vim.fn.isdirectory(keyword_dir) == 0 then
    vim.fn.mkdir(keyword_dir, "p")
    end
  end
end

return M
