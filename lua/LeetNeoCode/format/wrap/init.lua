-- Format module: Text wrapping utilities
local M = {}

local C = require "LeetNeoCode.config"
local detector = require "LeetNeoCode.format.wrap.core.detector"
local paragraph = require "LeetNeoCode.format.wrap.core.paragraph"

-- Determine if a line should be wrapped (delegate to detector)
M.should_wrap = detector.should_wrap

-- Wrap a paragraph to the specified width (delegate to paragraph)
M.wrap_paragraph = paragraph.wrap_paragraph

-- Apply custom wrapping to the entire text
function M.apply_custom_wrap(text)
  local split_ratio = C.description_split or 0.35
  local wrap_ratio = (C.description_split or 0.35) - (C.custom_wrap_offset or 0.10)
  if wrap_ratio < 0.05 then
    wrap_ratio = 0.05
  end

  local cols = vim.o.columns or 80
  local width = math.max(20, math.floor(cols * wrap_ratio) - 2)
  local wrapped = {}
  for line in text:gmatch "([^\n]*)\n?" do
    if M.should_wrap(line) and #line > width then
      line = M.wrap_paragraph(line, width)
    end
    table.insert(wrapped, line)
  end
  return table.concat(wrapped, "\n")
end

return M
