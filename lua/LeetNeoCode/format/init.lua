-- Format module (main interface for formatting)
local M = {}

-- Import submodules
local formatter = require "LeetNeoCode.format.core.formatter"
local metadata = require "LeetNeoCode.format.core.metadata"
local highlight = require "LeetNeoCode.format.highlighting.setup"

-- HTML formatting (public API)
M.html = require "LeetNeoCode.format.html"
M.syntax = require "LeetNeoCode.format.syntax"

-- Format problem text
function M.format_problem_text(html)
  return formatter.format_problem_text(html)
end

-- Setup syntax highlighting
function M.setup_highlighting()
  return highlight.setup_highlighting()
end

-- Metadata formatting functions
M.format_metadata = metadata.format_metadata
M.format_difficulty = metadata.format_difficulty
M.format_tags = metadata.format_tags
M.create_user_tags_section = metadata.create_user_tags_section

return M
