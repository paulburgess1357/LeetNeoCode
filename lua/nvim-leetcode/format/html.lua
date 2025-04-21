-- Problem text formatter module
local M = {}

-- Pull in the shared LeetCode config
local C = require("nvim-leetcode.config")

-- Separator sizing
local split_ratio = C.description_split or 0.35
local main_sep_ratio = 0.50
local example_sep_ratio = 0.25

-- HTML entities
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

-- Subscripts and superscripts
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

-- Entities + <sup>
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

-- Protect inline <code>…</code> and image placeholders
local function process_code_blocks(text)
	local blocks, id = {}, 0
	local out = text:gsub("<code>(.-)</code>", function(c)
		id = id + 1
		local ph = ("___CODE_PLACEHOLDER_%d___"):format(id)
		blocks[ph] = c -- raw code, no backticks
		return ph
	end)

	-- Also protect any image placeholders
	for placeholder in out:gmatch("___IMAGE_PLACEHOLDER_%d+___") do
		blocks[placeholder] = placeholder
	end

	return out, blocks
end

local function restore_code_blocks(text, blocks)
	for ph, code in pairs(blocks) do
		text = text:gsub(ph, code)
	end
	return text
end

-- Strip HTML + multi-digit <sup> + <sub> while preserving image placeholders
local function process_html_tags(text)
	local t, blocks = process_code_blocks(text)
	-- multi-digit sup
	t = t:gsub("<sup>(%d+)</sup>", function(ds)
		return ds:gsub(".", function(d)
			return superscript_map[d] or "^" .. d
		end)
	end)
	-- tags
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
			local o, i = "\n", 1
			for it in c:gmatch("<li>(.-)</li>") do
				o = o .. i .. ". " .. it .. "\n"
				i = i + 1
			end
			return o
		end)
		:gsub("<h%d>(.-)</h%d>", "\n%1\n")
		:gsub("<p>(.-)</p>", "%1\n\n")
		:gsub("<code>(.-)</code>", "%1")
		:gsub("<img.-/>", function(match)
			-- Keep image placeholders intact
			for placeholder in match:gmatch("___IMAGE_PLACEHOLDER_%d+___") do
				return placeholder
			end
			-- If no placeholder is found, just remove the tag
			return ""
		end)
		:gsub("<[^>]+>", "")
	t = restore_code_blocks(t, blocks)
	-- subscript
	return t:gsub("<sub>(.-)</sub>", function(c)
		return c:gsub(".", function(ch)
			return subscript_map[ch:lower()] or ch
		end)
	end)
end

-- LeetCode patterns + separators
local function process_leetcode_patterns(text)
	local t = text:gsub("\n\n\n+", "\n\n")
	local cols = vim.o.columns or 80
	local w = math.floor(cols * split_ratio)
	local main_w = math.floor(w * main_sep_ratio)
	local ex_w = math.floor(w * example_sep_ratio)
	local main_s = string.rep("-", main_w)
	local ex_s = string.rep("-", ex_w)

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
	out = out:gsub("Input:", "Input:  "):gsub("Output:", "Output: "):gsub("Explanation:", "Explanation: ")
	out = out:gsub("Constraints:", "\nConstraints:\n" .. main_s)
	out = out:gsub("(• Only one valid answer exists%.\n\n)Follow%-up:", "%1" .. main_s .. "\n\nFollow-up:")
	out = out:gsub("\n%s*%*%s+", "\n• ")
		:gsub("\n\n%s*•", "\n• ")
		:gsub("•%s*(%-?%d+)%s*<=%s*nums%.length%s*<=%s*(%-?%d+)", "• %1 <= nums.length <= %2")
		:gsub("•%s*(%-?%d+)%s*<=%s*nums%[i%]%s*<=%s*(%-?%d+)", "• %1 <= nums[i] <= %2")
	out = out:gsub("O%(n<sup>(%d+)</sup>%)", function(ds)
		return "O(n" .. ds:gsub(".", function(d)
			return superscript_map[d] or "^" .. d
		end) .. ")"
	end)
	out = out:gsub("\nFollow%-up:%s*\n%-+", "\nFollow-up:"):gsub("\n\n\n+", "\n\n")
	return out
end

function M.format_problem_text(html)
	if type(html) ~= "string" or html == "" then
		return ""
	end
	local t = process_entities(html)
	t = process_html_tags(t)
	return process_leetcode_patterns(t)
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
    syntax match ProblemImagePlaceholder /___IMAGE_PLACEHOLDER_\d\+___/

    setlocal conceallevel=2 concealcursor=nc
    setlocal wrap

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
    highlight ProblemImagePlaceholder guifg=#504945
  ]])
end

return M
