-- Text wrapping detection utilities
local M = {}

-- Determine if a line should be wrapped based on its structure
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

return M
