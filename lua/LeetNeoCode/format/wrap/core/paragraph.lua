-- Paragraph wrapping utilities
local M = {}

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

return M
