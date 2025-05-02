-- Problem module (main interface)
local M = {}

-- Import submodules
M.metadata = require "LeetNeoCode.problem.core.metadata"
M.setup = require "LeetNeoCode.problem.setup"
M.render = require "LeetNeoCode.problem.render"

-- Helper modules
M.helpers = {
  languages = require "LeetNeoCode.problem.helper.languages",
  file = require "LeetNeoCode.problem.util.file_utils",
  directory = require "LeetNeoCode.problem.util.directory",
  fetcher = require "LeetNeoCode.problem.util.fetcher",
  cache = require "LeetNeoCode.problem.util.cache_utils"
}

-- View modules
M.view = {
  description = require "LeetNeoCode.problem.view.description",
  buffer = require "LeetNeoCode.problem.view.buffer"
}

-- Global state
_G.leetcode_opened = _G.leetcode_opened or {}

-- Main function to open a problem
function M.open_problem(number)
  local num = tonumber(number)
  if not num then
    vim.notify("Invalid problem number: " .. tostring(number), vim.log.levels.ERROR)
    return
  end

  -- 1) Refresh metadata if needed
  M.metadata.ensure_fresh_cache()

  -- 2) Load metadata and resolve slug
  local meta, slug, title, paid_only = M.metadata.resolve_problem(num)
  if not meta then
    return
  end
  if paid_only then
    vim.notify(string.format("Problem #%d (%s) is premium", num, title), vim.log.levels.WARN)
    return
  end

  -- 3) Prepare solution directory
  local prob_dir = M.setup.prepare_solution_dir(num, title, slug)

  -- 4) Set up dependencies
  M.setup.setup_dependencies(prob_dir)

  -- 5) Fetch problem data
  local problem_data, snippets = M.setup.fetch_problem_data(slug)

  -- 6) Save solution file
  local fpath, version = M.setup.save_solution_file(prob_dir, snippets, problem_data)

  -- 7) Record open count
  _G.leetcode_opened[slug] = (_G.leetcode_opened[slug] or 0) + 1

  -- 8) Open tab with splits
  M.render.open_problem_view(problem_data, snippets, fpath, num, title, slug)

  vim.notify(string.format("Loaded problem #%d: %s (v%d)", num, title, version), vim.log.levels.INFO)
end

-- Alias for backward compatibility
M.problem = M.open_problem

return M
