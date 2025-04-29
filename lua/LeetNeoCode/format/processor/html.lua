-- Format module: HTML tags processing
local M = {}

local entities = require "LeetNeoCode.format.entities"
local superscript = require "LeetNeoCode.format.entities.superscript"
local subscript = require "LeetNeoCode.format.entities.subscript"
local C = require "LeetNeoCode.config"

-- Extract and preserve code blocks to prevent modification
function M.process_code_blocks(text)
  local blocks, id = {}, 0
  local out = text:gsub("<code>(.-)</code>", function(c)
    id = id + 1
    local ph = ("___CODE_PLACEHOLDER_%d___"):format(id)
    blocks[ph] = c
    return ph
  end)
  return out, blocks
end

-- Restore code blocks back to the text with configured markers
function M.restore_code_blocks(t, blocks)
  local start_marker = C.code_block_start or "⌊" -- Default to floor bracket if not configured
  local end_marker = C.code_block_end or "⌋" -- Default to ceiling bracket if not configured

  for ph, code in pairs(blocks) do
    -- Add user-configured markers around the code content
    t = t:gsub(ph, start_marker .. code .. end_marker)
  end
  return t
end

-- Process all HTML entities and special tags like sup/sub
function M.process_entities(text)
  local processed = entities.process(text)

  -- Process superscript and subscript tags
  processed = processed
    :gsub("<sup>(.-)</sup>", function(s)
      return superscript.to_super(s)
    end)
    :gsub("<sub>(.-)</sub>", function(s)
      return subscript.to_sub(s)
    end)

  return processed
end

-- Process all HTML tags in the text
function M.process_tags(text)
  local t, blocks = M.process_code_blocks(text)

  t = t
    :gsub("<br%s*/?>", "\n")
    :gsub("<[bB]>(.-)</[bB]>", "%1")
    :gsub("<strong>(.-)</strong>", "%1")
    :gsub("<[iI]>(.-)</[iI]>", "%1")
    :gsub("<em>(.-)</em>", "%1")
    :gsub("<pre>(.-)</pre>", "\n%1\n")
    :gsub("<ul>(.-)</ul>", function(c)
      return c:gsub("<li>(.-)</li>", "\n• %1\n")
    end)
    :gsub("<ol>(.-)</ol>", function(c)
      local out, n = "\n", 1
      for it in c:gmatch "<li>(.-)</li>" do
        out = out .. n .. ". " .. it .. "\n"
        n = n + 1
      end
      return out
    end)
    :gsub("<h%d>(.-)</h%d>", "\n%1\n")
    :gsub("<p>(.-)</p>", "%1\n\n")
    :gsub("<code>(.-)</code>", "%1")
    :gsub("<img[^>]-/>", "") -- drop images
    :gsub("<[^>]+>", "") -- any remaining tag

  return M.restore_code_blocks(t, blocks)
end

return M
