-- Problem data fetching utilities
local vim = vim
local pull = require "LeetNeoCode.pull"

local M = {}

-- Fetch problem data (description and code)
function M.fetch_problem_data(slug)
  local problem_data = {}
  do
    local ok, result = pcall(pull.description.fetch_description, slug)
    problem_data = ok and type(result) == "table" and result or { content = "" }
    if problem_data.content == "" then
      vim.notify("Could not fetch description for problem", vim.log.levels.WARN)
    end
  end

  local snippets
  do
    local ok, res = pcall(pull.code.fetch_stub, slug)
    snippets = ok and res or nil
    if not snippets then
      vim.notify("Could not fetch code stub for problem", vim.log.levels.WARN)
    end
  end

  return problem_data, snippets
end

return M
