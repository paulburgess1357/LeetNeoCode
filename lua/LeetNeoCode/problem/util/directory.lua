-- Directory operations for problem setup
local vim = vim
local C = require "LeetNeoCode.config"
local file_utils = require "LeetNeoCode.problem.util.file_utils"

local M = {}

-- Prepare solution directory for a problem
function M.prepare_solution_dir(num, title, slug)
  local safe_title = (title or slug):gsub("%W+", "_"):gsub("^_+", ""):gsub("_+$", "")
  local sol_base = C.cache_dir .. "/" .. C.solutions_subdir

  file_utils.ensure_directory(sol_base)

  local prob_dir = sol_base .. "/LC" .. num .. "_" .. safe_title
  file_utils.ensure_directory(prob_dir)

  return prob_dir
end

-- Get problem-specific subdirectory
function M.get_problem_subdir(num, title, slug, subdir)
  local prob_dir = M.prepare_solution_dir(num, title, slug)

  -- Create specific subdirectory if needed
  if subdir and subdir ~= "" then
    local sub_path = prob_dir .. "/" .. subdir
    file_utils.ensure_directory(sub_path)
    return sub_path
  end

  return prob_dir
end

return M
