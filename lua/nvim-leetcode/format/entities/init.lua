-- Format module: HTML entities processing
local M = {}

-- HTML entities mapping
M.html_entities = {
  ["&nbsp;"] = " ",
  ["&#39;"] = "'",
  ["&quot;"] = '"',
  ["&lt;"] = "<",
  ["&gt;"] = ">",
  ["&amp;"] = "&",
  ["&ndash;"] = "–",
  ["&mdash;"] = "—",
  ["&#8594;"] = "→",
  ["&#8592;"] = "←",
  ["&#8593;"] = "↑",
  ["&#8595;"] = "↓",
  ["&#8596;"] = "↔",
  ["&le;"] = "≤",
  ["&ge;"] = "≥",
  ["&ne;"] = "≠",
  ["&asymp;"] = "≈",
  ["&#10;"] = "\n",
  ["&bull;"] = "•",
  ["&ast;"] = "*",
}

-- Process all HTML entities in a text
function M.process(text)
  for pat, rep in pairs(M.html_entities) do
    text = text:gsub(pat, rep)
  end
  return text
end

return M
