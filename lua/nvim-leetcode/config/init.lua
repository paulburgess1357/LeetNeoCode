-- Main configuration module for nvim-leetcode
local M = require("nvim-leetcode.config.options")

-- Export the directory utilities
M.get_dependencies_dir = require("nvim-leetcode.config.dirs").get_dependencies_dir
M.ensure_cache_dirs = require("nvim-leetcode.config.dirs").ensure_cache_dirs

return M
