-- Configuration loading functionality
local M = {}
local options = require "LeetNeoCode.config.options"

-- Merge user config with defaults
function M.merge_user_config(user_config)
  if not user_config then
    return options
  end

  local merged = vim.deepcopy(options)
  for k, v in pairs(user_config) do
    merged[k] = v
  end

  return merged
end

return M
