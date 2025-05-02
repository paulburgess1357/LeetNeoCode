-- Pull module (main interface for problem list fetching)
local M = {}

-- Module references
M.metadata = require "LeetNeoCode.pull.metadata"
M.code = require "LeetNeoCode.pull.code"
M.description = require "LeetNeoCode.pull.description"

-- Core modules
M.core = {
  fetch = require "LeetNeoCode.pull.core.fetch"
}

-- API modules
M.api = {
  graphql = require "LeetNeoCode.pull.api.graphql"
}

-- Utility modules
M.util = {
  cache = require "LeetNeoCode.pull.util.cache"
}

-- Main function to pull problem list
function M.pull_problems()
  return M.metadata.pull_problems()
end

-- Fetch problem details (delegate to core/fetch)
function M.fetch_problem(slug)
  return M.core.fetch.fetch_problem(slug)
end

-- Fetch multiple problems by slugs
function M.fetch_problems(slugs)
  return M.core.fetch.fetch_problems(slugs)
end

return M
