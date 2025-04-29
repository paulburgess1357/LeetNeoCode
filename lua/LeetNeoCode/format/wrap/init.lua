-- Format module: Text wrapping utilities
local M = {}

local C = require "LeetNeoCode.config"

-- Determine if a line should be wrapped
function M.should_wrap(line)
  return not (
    line:match "^%s*•"
    or line:match "^%s*%d+%."
    or line:match "^%s*Example %d+:"
    or line:match "^%s*Input:"
    or line:match "^%s*Output:"
    or line:match "^%s*Explanation:"
    or line:match "^%s*Constraints:"
    or line:match "^%-+$"
    or line:match "^%s*$"
  )
end

-- Wrap a paragraph to the specified width
function M.wrap_paragraph(line, width)
  local out, remain = {}, line
  while #remain > width do
    local cut = remain:sub(1, width):match ".*()%s+" or width
    if cut < width * 0.3 then
      cut = width
    end
    local segment = remain:sub(1, cut):gsub("%s+$", "")
    table.insert(out, segment)
    remain = remain:sub(cut + 1):gsub("^%s+", "")
  end
  table.insert(out, remain)
  return table.concat(out, "\n")
end

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
