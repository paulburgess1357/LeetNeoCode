-- Main configuration module for LeetNeoCode
local options = require "LeetNeoCode.config.options"
local loader = require "LeetNeoCode.config.core.loader"
local dirs = require "LeetNeoCode.config.dirs"

local M = options

-- Export the directory utilities
M.get_dependencies_dir = dirs.get_dependencies_dir
M.ensure_cache_dirs = dirs.ensure_cache_dirs

-- Apply user configuration
function M.apply_config(user_config)
  if user_config then
    for k, v in pairs(user_config) do
      M[k] = v
    end
  end
end

return M
