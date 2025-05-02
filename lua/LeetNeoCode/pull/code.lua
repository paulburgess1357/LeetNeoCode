-- LeetCode code stub fetching module
local vim = vim
local C = require "LeetNeoCode.config"
local graphql = require "LeetNeoCode.pull.api.graphql"

local M = {}

-- Fetch starter code for given slug
function M.fetch_stub(slug)
  local query = [[
    query questionSnippets($titleSlug: String!) {
      question(titleSlug: $titleSlug) {
        codeSnippets { langSlug code }
      }
    }
  ]]

  local data, err = graphql.request(query, { titleSlug = slug })
  if not data or not data.question or not data.question.codeSnippets then
    return nil
  end

  local snippets = data.question.codeSnippets
  for _, sn in ipairs(snippets) do
    if sn.langSlug == C.default_language then
      return sn.code
    end
  end

  return nil
end

return M
