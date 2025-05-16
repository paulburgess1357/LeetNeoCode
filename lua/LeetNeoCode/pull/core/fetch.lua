-- Core fetching functionality for LeetCode
local vim = vim
local description = require "LeetNeoCode.pull.description"
local code = require "LeetNeoCode.pull.code"

local M = {}

-- Fetch both problem description and code snippet
function M.fetch_problem(slug, code_only)
  if not slug or slug == "" then
    vim.notify("Invalid problem slug provided", vim.log.levels.ERROR)
    return nil, nil
  end

  vim.notify("Fetching problem: " .. slug, vim.log.levels.INFO)

  -- Always fetch code
  local snippets = code.fetch_stub(slug)

  -- Only fetch description if not in code_only mode
  local problem_data
  if not code_only then
    problem_data = description.fetch_description(slug)
  else
    problem_data = { content = "" }
  end

  return problem_data, snippets
end

-- Fetch multiple problems by slugs (returns a table of results)
function M.fetch_problems(slugs, code_only)
  if not slugs or #slugs == 0 then
    vim.notify("No problem slugs provided", vim.log.levels.ERROR)
    return {}
  end

  vim.notify("Fetching " .. #slugs .. " problems...", vim.log.levels.INFO)

  local results = {}
  for i, slug in ipairs(slugs) do
    vim.notify("Fetching problem " .. i .. "/" .. #slugs .. ": " .. slug, vim.log.levels.INFO)
    local problem_data, snippets = M.fetch_problem(slug, code_only)
    if snippets then -- We always need snippets, but might not need problem_data
      results[slug] = {
        problem_data = problem_data,
        snippets = snippets,
      }
    end
  end

  return results
end

return M
