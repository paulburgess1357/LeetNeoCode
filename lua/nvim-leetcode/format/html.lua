-- lua/nvim‑leetcode/format/html.lua
-- ===========================================================================
--  Problem description formatter for nvim‑leetcode
-- ===========================================================================

local M = {}

-------------------------------------------------------------------------------
-- Configuration --------------------------------------------------------------
-------------------------------------------------------------------------------
local C = require("nvim-leetcode.config")

local split_ratio = C.description_split or 0.35
local wrap_enabled = C.enable_custom_wrap ~= false
local wrap_ratio = (C.description_split or 0.35) - (C.custom_wrap_offset or 0.10)
if wrap_ratio < 0.05 then
	wrap_ratio = 0.05
end

local main_sep_ratio, example_sep_ratio = 0.50, 0.25

-------------------------------------------------------------------------------
-- HTML entities --------------------------------------------------------------
-------------------------------------------------------------------------------
local html_entities = {
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

-------------------------------------------------------------------------------
-- Superscript / subscript glyph maps -----------------------------------------
-------------------------------------------------------------------------------
local superscript_map = {
	["0"] = "⁰",
	["1"] = "¹",
	["2"] = "²",
	["3"] = "³",
	["4"] = "⁴",
	["5"] = "⁵",
	["6"] = "⁶",
	["7"] = "⁷",
	["8"] = "⁸",
	["9"] = "⁹",
	["-"] = "⁻",
	["+"] = "⁺",
	["("] = "⁽",
	[")"] = "⁾",
	["a"] = "ᵃ",
	["b"] = "ᵇ",
	["c"] = "ᶜ",
	["d"] = "ᵈ",
	["e"] = "ᵉ",
	["f"] = "ᶠ",
	["g"] = "ᵍ",
	["h"] = "ʰ",
	["i"] = "ⁱ",
	["j"] = "ʲ",
	["k"] = "ᵏ",
	["l"] = "ˡ",
	["m"] = "ᵐ",
	["n"] = "ⁿ",
	["o"] = "ᵒ",
	["p"] = "ᵖ",
	["r"] = "ʳ",
	["s"] = "ˢ",
	["t"] = "ᵗ",
	["u"] = "ᵘ",
	["v"] = "ᵛ",
	["w"] = "ʷ",
	["x"] = "ˣ",
	["y"] = "ʸ",
	["z"] = "ᶻ",
}
local subscript_map = {
	["0"] = "₀",
	["1"] = "₁",
	["2"] = "₂",
	["3"] = "₃",
	["4"] = "₄",
	["5"] = "₅",
	["6"] = "₆",
	["7"] = "₇",
	["8"] = "₈",
	["9"] = "₉",
	["-"] = "₋",
	["+"] = "₊",
	["("] = "₍",
	[")"] = "₎",
	["a"] = "ₐ",
	["e"] = "ₑ",
	["h"] = "ₕ",
	["i"] = "ᵢ",
	["j"] = "ⱼ",
	["k"] = "ₖ",
	["l"] = "ₗ",
	["m"] = "ₘ",
	["n"] = "ₙ",
	["o"] = "ₒ",
	["p"] = "ₚ",
	["r"] = "ᵣ",
	["s"] = "ₛ",
	["t"] = "ₜ",
	["u"] = "ᵤ",
	["v"] = "ᵥ",
	["x"] = "ₓ",
}

local function to_super(txt)
	return txt:gsub(".", function(c)
		return superscript_map[c] or "^" .. c
	end)
end
local function to_sub(txt)
	return txt:gsub(".", function(c)
		return subscript_map[c] or "_" .. c
	end)
end

-------------------------------------------------------------------------------
-- Helpers --------------------------------------------------------------------
-------------------------------------------------------------------------------
local function process_entities(text)
	for pat, rep in pairs(html_entities) do
		text = text:gsub(pat, rep)
	end
	return text:gsub("<sup>(.-)</sup>", function(s)
		return to_super(s)
	end):gsub("<sub>(.-)</sub>", function(s)
		return to_sub(s)
	end)
end

local function process_code_blocks(text)
	local blocks, id = {}, 0
	local out = text:gsub("<code>(.-)</code>", function(c)
		id = id + 1
		local ph = ("___CODE_PLACEHOLDER_%d___"):format(id)
		blocks[ph] = c
		return ph
	end)
	return out, blocks
end
local function restore_code_blocks(t, blocks)
	for ph, code in pairs(blocks) do
		t = t:gsub(ph, code)
	end
	return t
end

local function process_html_tags(text)
	local t, blocks = process_code_blocks(text)

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
			for it in c:gmatch("<li>(.-)</li>") do
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

	return restore_code_blocks(t, blocks)
end

local function process_leetcode_patterns(text)
	local t = text:gsub("\n\n\n+", "\n\n")
	local cols = vim.o.columns or 80
	local w = math.floor(cols * split_ratio)
	local main_s = string.rep("-", math.floor(w * main_sep_ratio))
	local ex_s = string.rep("-", math.floor(w * example_sep_ratio))

	local out = "Description\n" .. main_s .. "\n\n"
	local title = t:match("^%s*(.-)%s*\n")
	if title then
		out = out .. title .. "\n\n"
		t = t:gsub("^%s*.-\n", "", 1)
	end
	out = out .. t

	out = out:gsub("Example (%d+):", function(n)
		return "\nExample " .. n .. ":\n" .. ex_s
	end)
		:gsub("Input:", "Input:  ")
		:gsub("Output:", "Output: ")
		:gsub("Explanation:", "Explanation: ")
		:gsub("Constraints:", "\nConstraints:\n" .. main_s)
		:gsub("(• Only one valid answer exists%.\n\n)Follow%-up:", "%1" .. main_s .. "\n\nFollow-up:")
		:gsub("\n%s*%*%s+", "\n• ")
		:gsub("\n\n%s*•", "\n• ")
		:gsub("\nFollow%-up:%s*\n%-+", "\nFollow-up:")
		:gsub("\n\n\n+", "\n\n")

	return out
end

-------------------------------------------------------------------------------
-- Hard‑wrap helpers ----------------------------------------------------------
-------------------------------------------------------------------------------
local function should_wrap(line)
	return not (
		line:match("^%s*•")
		or line:match("^%s*%d+%.")
		or line:match("^%s*Example %d+:")
		or line:match("^%s*Input:")
		or line:match("^%s*Output:")
		or line:match("^%s*Explanation:")
		or line:match("^%s*Constraints:")
		or line:match("^%-+$")
		or line:match("^%s*$")
	)
end

local function wrap_paragraph(line, width)
	local out, remain = {}, line
	while #remain > width do
		local cut = remain:sub(1, width):match(".*()%s+") or width
		if cut < width * 0.3 then
			cut = width
		end
		local segment = remain:sub(1, cut):gsub("%s+$", "") -- FIX: capture result
		table.insert(out, segment)
		remain = remain:sub(cut + 1):gsub("^%s+", "")
	end
	table.insert(out, remain)
	return table.concat(out, "\n")
end

local function apply_custom_wrap(text)
	local cols = vim.o.columns or 80
	local width = math.max(20, math.floor(cols * wrap_ratio) - 2)
	local wrapped = {}
	for line in text:gmatch("([^\n]*)\n?") do
		if should_wrap(line) and #line > width then
			line = wrap_paragraph(line, width)
		end
		table.insert(wrapped, line)
	end
	return table.concat(wrapped, "\n")
end

-------------------------------------------------------------------------------
-- Public API -----------------------------------------------------------------
-------------------------------------------------------------------------------
function M.format_problem_text(html)
	if type(html) ~= "string" or html == "" then
		return ""
	end
	local t = process_entities(html)
	t = process_html_tags(t)
	t = process_leetcode_patterns(t)
	if wrap_enabled then
		t = apply_custom_wrap(t)
	end
	t = t:gsub("\n+$", "\n") -- exactly one trailing newline
	return t
end

function M.setup_highlighting()
	vim.cmd([[
    syntax match ProblemTitle       /^Description$/
    syntax match ProblemSection     /^Constraints:$/
    syntax region ProblemConstraints start=/^Constraints:$/ end=/^\s*$/ keepend
    syntax match ProblemConstraintNum /\d\+/ containedin=ProblemConstraints
    syntax match ProblemFollowup    /^Follow-up:$/
    syntax match ProblemExample     /^Example \d\+:$/
    syntax match ProblemBullet      /^• .*$/
    syntax match ProblemInput       /^Input: .*$/
    syntax match ProblemOutput      /^Output: .*$/
    syntax region ProblemExplanation start=/^Explanation:/ end=/^\s*$/ keepend
    syntax match ProblemMath        /[<>=]=\|[<>=]\|O(n[²³⁴⁵⁶⁷⁸⁹])/
    syntax match ProblemNumber      /\<\d\+\>/
    syntax match ProblemSuperscript /[⁰¹²³⁴⁵⁶⁷⁸⁹⁻⁺⁽⁾ⁿˣʸ]/
    syntax match ProblemVariable    /nums\|\<n\>\|target\|Node\.val/

    setlocal conceallevel=2 concealcursor=nc
    setlocal nowrap

    highlight ProblemTitle         guifg=#ff7a6c gui=bold
    highlight ProblemSection       guifg=#d8a657 gui=bold
    highlight ProblemConstraints   guifg=#89b482
    highlight ProblemConstraintNum guifg=#d8a657 gui=bold
    highlight ProblemFollowup      guifg=#d8a657 gui=bold
    highlight ProblemExample       guifg=#a9b665 gui=bold
    highlight ProblemBullet        guifg=#d3869b
    highlight ProblemInput         guifg=#e78a4e
    highlight ProblemOutput        guifg=#ea6962
    highlight ProblemExplanation   guifg=#89b482
    highlight ProblemMath          guifg=#d3869b
    highlight ProblemNumber        guifg=#d8a657 gui=bold
    highlight ProblemSuperscript   guifg=#d8a657
    highlight ProblemVariable      guifg=#7daea3
  ]])
end

return M
