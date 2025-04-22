-- lua/nvim‑leetcode/format/html.lua
-- Problem text formatter module
local M = {}

-- Load shared configuration
local C = require("nvim-leetcode.config")

-- ────────────────────────────────────────────────────────────────────────────
-- Layout & wrapping parameters
-- ────────────────────────────────────────────────────────────────────────────
local split_ratio = C.description_split or 0.35 -- for separators
local wrap_enabled = C.enable_custom_wrap ~= false -- default true
local wrap_ratio = (C.description_split or 0.35) - (C.custom_wrap_offset or 0.10)

if wrap_ratio < 0.05 then
	wrap_ratio = 0.05
end -- sane lower bound

local main_sep_ratio = 0.50
local example_sep_ratio = 0.25

-- ────────────────────────────────────────────────────────────────────────────
-- HTML entities and sub/superscripts
-- ────────────────────────────────────────────────────────────────────────────
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
	["x"] = "ₓ",
}

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
}

-- ────────────────────────────────────────────────────────────────────────────
-- Helper functions
-- ────────────────────────────────────────────────────────────────────────────
local function process_entities(text)
	for pat, rep in pairs(html_entities) do
		text = text:gsub(pat, rep)
	end
	return text:gsub("<sup>(%d+)</sup>", function(ds)
		return ds:gsub(".", function(d)
			return superscript_map[d] or "^" .. d
		end)
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

	t = t:gsub("<br%s*/?>", "\n")
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

	t = t:gsub("<img[^>]-/>", ""):gsub("<[^>]+>", "") -- drop images & any tag
	t = restore_code_blocks(t, blocks)

	return t:gsub("<sub>(.-)</sub>", function(c)
		return c:gsub(".", function(ch)
			return subscript_map[ch:lower()] or ch
		end)
	end)
end

local function process_leetcode_patterns(text)
	local t = text:gsub("\n\n\n+", "\n\n")
	local cols = vim.o.columns or 80
	local w = math.floor(cols * split_ratio)
	local main_w, ex_w = math.floor(w * main_sep_ratio), math.floor(w * example_sep_ratio)
	local main_s, ex_s = string.rep("-", main_w), string.rep("-", ex_w)

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
		:gsub("•%s*(%-?%d+)%s*<=%s*nums%.length%s*<=%s*(%-?%d+)", "• %1 <= nums.length <= %2")
		:gsub("•%s*(%-?%d+)%s*<=%s*nums%[i%]%s*<=%s*(%-?%d+)", "• %1 <= nums[i] <= %2")
		:gsub("O%(n<sup>(%d+)</sup>%)", function(ds)
			return "O(n" .. ds:gsub(".", function(d)
				return superscript_map[d] or "^" .. d
			end) .. ")"
		end)
		:gsub("\nFollow%-up:%s*\n%-+", "\nFollow-up:")
		:gsub("\n\n\n+", "\n\n")
	return out
end

-- ────────────────────────────────────────────────────────────────────────────
-- Custom hard‑wrap helpers
-- ────────────────────────────────────────────────────────────────────────────
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
		local cut = remain:sub(1, width):match(".*()%s+") -- last space ≤ width
		if not cut or cut < width * 0.3 then
			cut = width
		end
		local segment = remain:sub(1, cut):gsub("%s+$", "")
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

-- ────────────────────────────────────────────────────────────────────────────
-- Public API
-- ────────────────────────────────────────────────────────────────────────────
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
    syntax match ProblemSuperscript /[⁰¹²³⁴⁵⁶⁷⁸⁹]/
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
