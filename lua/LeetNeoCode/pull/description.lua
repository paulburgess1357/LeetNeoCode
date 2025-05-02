-- LeetCode problem description fetching module
local vim = vim
local C = require "LeetNeoCode.config"
local graphql = require "LeetNeoCode.pull.api.graphql"

local M = {}

-- Fetch HTML description and metadata for given slug
function M.fetch_description(slug)
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

  local data, err = graphql.request(query, { titleSlug = slug })
  if not data or not data.question then
    return nil
  end

  -- Return both the content and metadata
  return {
    content = data.question.content,
    difficulty = data.question.difficulty,
    topicTags = data.question.topicTags,
    stats = data.question.stats,
    title = data.question.title,
    questionId = data.question.questionFrontendId,
  }
end

return M
