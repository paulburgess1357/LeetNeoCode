-- Main HTML formatting module for LeetNeoCode
local M = {}
local formatter = require "LeetNeoCode.format.core.formatter"
local highlight = require "LeetNeoCode.format.highlighting.setup"

-- Main function to format problem text
M.format_problem_text = formatter.format_problem_text

-- Setup syntax highlighting for problem description
M.setup_highlighting = highlight.setup_highlighting

return M
