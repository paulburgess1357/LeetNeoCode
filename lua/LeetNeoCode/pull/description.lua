-- LeetCode problem description fetching module
local vim = vim
local C = require "LeetNeoCode.config"

-- Internal: perform GraphQL request and return decoded table
local function graphql_request(slug)
  local query = [[
    query questionContent($titleSlug: String!) {
      question(titleSlug: $titleSlug) {
        content
        difficulty
        topicTags {
          name
          slug
        }
        stats
        title
        questionFrontendId
      }
    }
  ]]
  local payload = vim.fn.json_encode { query = query, variables = { titleSlug = slug } }
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
  return decoded.data.question
end

local M = {}

-- Fetch HTML description and metadata for given slug
function M.fetch_description(slug)
  local question = graphql_request(slug)
  if not question then
    return nil
  end

  -- Return both the content and metadata
  return {
    content = question.content,
    difficulty = question.difficulty,
    topicTags = question.topicTags,
    stats = question.stats,
    title = question.title,
    questionId = question.questionFrontendId,
  }
end

return M
