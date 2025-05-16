-- Problem data fetching utilities
local vim = vim
local description = require "LeetNeoCode.pull.description"
local code = require "LeetNeoCode.pull.code"

local M = {}

-- Fetch problem description only
function M.fetch_problem_description(slug)
  if not slug or slug == "" then
    vim.notify("Invalid problem slug provided", vim.log.levels.ERROR)
    return nil
  end

  return description.fetch_description(slug)
end

-- Fetch code stub only
function M.fetch_code_stub(slug)
  if not slug or slug == "" then
    vim.notify("Invalid problem slug provided", vim.log.levels.ERROR)
    return nil
  end

  return code.fetch_stub(slug)
end

-- Fetch both problem description and code snippet (original function for backward compatibility)
function M.fetch_problem(slug)
  if not slug or slug == "" then
    vim.notify("Invalid problem slug provided", vim.log.levels.ERROR)
    return nil, nil
  end

  vim.notify("Fetching problem: " .. slug, vim.log.levels.INFO)

  -- Fetch description and code
  local problem_data = M.fetch_problem_description(slug)
  local snippets = M.fetch_code_stub(slug)

  return problem_data, snippets
end

return M
