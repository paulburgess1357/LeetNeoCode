-- Central module for utilities
local M = {}

-- File system and paths
M.path = require "LeetNeoCode.utils.path"
M.file = require "LeetNeoCode.utils.file.operations"

-- UI related
M.notify = require "LeetNeoCode.utils.ui.notify"

-- Data related
M.cache = require "LeetNeoCode.utils.cache"
M.clipboard = require "LeetNeoCode.utils.clipboard"

-- LeetCode-specific utilities
M.leetcode_copy = require "LeetNeoCode.utils.leetcode_copy"

return M
