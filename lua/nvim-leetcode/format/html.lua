-- Main HTML formatting module for nvim-leetcode
local M = {}

-- Import submodules
local html_processor = require("nvim-leetcode.format.processor.html")
local leetcode_processor = require("nvim-leetcode.format.processor.leetcode")
local wrap_util = require("nvim-leetcode.format.wrap")
local C = require("nvim-leetcode.config")

-- Main function to format problem text
function M.format_problem_text(html)
	if type(html) ~= "string" or html == "" then
		return ""
	end

	-- Step 1: Process HTML entities and special tags
	local t = html_processor.process_entities(html)

	-- Step 2: Process HTML tags
	t = html_processor.process_tags(t)

	-- Step 3: Process LeetCode-specific patterns
	t = leetcode_processor.process_patterns(t)

	-- Step 4: Apply custom wrapping if enabled
	if C.enable_custom_wrap ~= false then
		t = wrap_util.apply_custom_wrap(t)
	end

	-- Ensure exactly one trailing newline
	t = t:gsub("\n+$", "\n")

	return t
end

-- Setup syntax highlighting for problem description
function M.setup_highlighting()
	-- Get configuration values with defaults
	local start_marker = vim.fn.escape(C.code_block_start or "⌊", "/")
	local end_marker = vim.fn.escape(C.code_block_end or "⌋", "/")
	local color = C.code_block_color or (C.colors and C.colors.problem_code_block) or "#e6c07a"
	local style = C.code_block_style or "italic"
	local colors = C.colors or {}

	-- Create the highlighting command
	local highlighting_cmd = string.format(
		[[
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

    " Highlight code blocks with configurable markers and style
    syntax region ProblemCodeBlock start=/%s/ end=/%s/ keepend
    highlight ProblemCodeBlock guifg=%s gui=%s

    setlocal conceallevel=2 concealcursor=nc
    setlocal nowrap
  ]],
		start_marker,
		end_marker,
		color,
		style
	)

	-- Add highlighting commands with configurable colors
	highlighting_cmd = highlighting_cmd
		.. string.format(
			[[

    highlight ProblemTitle         guifg=%s gui=bold
    highlight ProblemSection       guifg=%s gui=bold
    highlight ProblemConstraints   guifg=%s
    highlight ProblemConstraintNum guifg=%s gui=bold
    highlight ProblemFollowup      guifg=%s gui=bold
    highlight ProblemExample       guifg=%s gui=bold
    highlight ProblemBullet        guifg=%s
    highlight ProblemInput         guifg=%s
    highlight ProblemOutput        guifg=%s
    highlight ProblemExplanation   guifg=%s
    highlight ProblemMath          guifg=%s
    highlight ProblemNumber        guifg=%s gui=bold
    highlight ProblemSuperscript   guifg=%s
    highlight ProblemVariable      guifg=%s
  ]],
			colors.problem_title or "#ff7a6c",
			colors.problem_section or "#d8a657",
			colors.problem_constraints or "#89b482",
			colors.problem_constraint_num or "#d8a657",
			colors.problem_followup or "#d8a657",
			colors.problem_example or "#a9b665",
			colors.problem_bullet or "#d3869b",
			colors.problem_input or "#e78a4e",
			colors.problem_output or "#ea6962",
			colors.problem_explanation or "#89b482",
			colors.problem_math or "#d3869b",
			colors.problem_number or "#d8a657",
			colors.problem_superscript or "#d8a657",
			colors.problem_variable or "#7daea3"
		)

	vim.cmd(highlighting_cmd)
end

return M
