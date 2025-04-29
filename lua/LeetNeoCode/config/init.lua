-- Main configuration module for LeetNeoCode
local M = require "LeetNeoCode.config.options"

-- Export the directory utilities
M.get_dependencies_dir = require("LeetNeoCode.config.dirs").get_dependencies_dir
M.ensure_cache_dirs = require("LeetNeoCode.config.dirs").ensure_cache_dirs

return M
