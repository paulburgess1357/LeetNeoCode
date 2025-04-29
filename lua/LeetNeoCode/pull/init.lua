-- Pull module (main interface for problem list fetching)
local M = {}

M.metadata = require "LeetNeoCode.pull.metadata"
M.code = require "LeetNeoCode.pull.code"
M.description = require "LeetNeoCode.pull.description"

-- Main function to pull problem list
function M.pull_problems()
  return M.metadata.pull_problems()
end

-- Fetch problem details
function M.fetch_problem(slug)
  local description = M.description.fetch_description(slug)
  local code = M.code.fetch_stub(slug)
  return description, code
end

return M
