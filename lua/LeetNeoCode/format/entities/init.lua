-- Format module: HTML entities processing
local M = {}
local html_entities = require "LeetNeoCode.format.entities.mappings.html_entities"

-- HTML entities mapping (for backward compatibility)
M.html_entities = html_entities.entities

-- Process all HTML entities in a text
M.process = html_entities.process

return M
