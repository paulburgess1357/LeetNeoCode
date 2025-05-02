-- Core formatting functionality
local M = {}

local html_processor = require "LeetNeoCode.format.processor.html"
local problem_formatter = require "LeetNeoCode.format.processor.adapters.problem_formatter"
local wrap_util = require "LeetNeoCode.format.wrap"
local C = require "LeetNeoCode.config"

-- Format problem text (main entry point)
function M.format_problem_text(html)
  if type(html) ~= "string" or html == "" then
    return ""
  end

  -- Step 1: Process HTML entities and special tags
  local t = html_processor.process_entities(html)

  -- Step 2: Process HTML tags
  t = html_processor.process_tags(t)

  -- Step 3: Process LeetCode-specific patterns
  t = problem_formatter.process_patterns(t)

  -- Step 4: Apply custom wrapping if enabled
  if C.enable_custom_wrap ~= false then
    t = wrap_util.apply_custom_wrap(t)
  end

  -- Ensure exactly one trailing newline
  t = t:gsub("\n+$", "\n")

  return t
end

return M
