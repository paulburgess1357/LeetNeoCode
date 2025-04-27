-- LeetCode code stub fetching module
local vim = vim
local C = require("LeetNeoCode.config")

-- Internal: perform GraphQL request and return decoded table
local function graphql_request(slug)
  local query = [[
    query questionSnippets($titleSlug: String!) {
      question(titleSlug: $titleSlug) {
        codeSnippets { langSlug code }
      }
    }
  ]]
  local payload = vim.fn.json_encode({ query = query, variables = { titleSlug = slug } })
  local cmd = {
    "curl",
    "-s",
    "https://leetcode.com/graphql",
    "-H",
    "Content-Type: application/json",
    "-H",
    "Origin: https://leetcode.com",
    "-H",
    "Referer: https://leetcode.com/problems/" .. slug .. "/",
    "-d",
    payload,
  }
  local resp = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    return nil
  end
  local ok, decoded = pcall(vim.fn.json_decode, resp)
  if not ok or not decoded.data or not decoded.data.question then
    return nil
  end
  return decoded.data.question.codeSnippets
end

local M = {}

-- Fetch starter code for given slug
function M.fetch_stub(slug)
  local snippets = graphql_request(slug)
  if not snippets then
    return nil
  end
  for _, sn in ipairs(snippets) do
    if sn.langSlug == C.default_language then
      return sn.code
    end
  end
  return nil
end

return M
