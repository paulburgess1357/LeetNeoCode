-- Format module: LeetCode-specific patterns processing
local M = {}

local C = require("nvim-leetcode.config")

-- Process LeetCode problem text patterns
function M.process_patterns(text)
	local split_ratio = C.description_split or 0.35
	local main_sep_ratio, example_sep_ratio = 0.50, 0.25

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

return M
