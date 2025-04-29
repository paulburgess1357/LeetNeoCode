-- Format module (main interface for formatting)
local M = {}

M.html = require "LeetNeoCode.format.html"
M.syntax = require "LeetNeoCode.format.syntax"

-- Format problem text
function M.format_problem_text(html)
  return M.html.format_problem_text(html)
end

-- Setup syntax highlighting
function M.setup_highlighting()
  return M.html.setup_highlighting()
end

-- Format problem metadata
function M.format_metadata(metadata)
  if not metadata or not metadata.title or not metadata.difficulty or not metadata.questionId then
    return ""
  end
  return "* Problem: LC#" .. metadata.questionId .. " " .. metadata.title
end

-- Format problem difficulty
function M.format_difficulty(metadata)
  if not metadata or not metadata.difficulty then
    return ""
  end
  return "* Difficulty: " .. metadata.difficulty
end

-- Format problem tags
function M.format_tags(tags)
  if not tags or #tags == 0 then
    return "* LC Tags: None"
  end

  local tag_names = {}
  for _, tag in ipairs(tags) do
    table.insert(tag_names, tag.name)
  end

  return "* LC Tags: " .. table.concat(tag_names, ", ")
end

-- Create user tags section
function M.create_user_tags_section()
  return "* User Tags:"
end

return M
