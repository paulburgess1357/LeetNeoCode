-- Command registration module for nvim-leetcode
local M = {}
local notify = require("nvim-leetcode.util.notify")

-- Setup all commands
function M.setup(leetcode)
	-- Define command functions
	_G.leetcode_commands = _G.leetcode_commands or {}

	-- LC Pull → full pull & cache
	_G.leetcode_commands.pull = function()
		leetcode.pull.pull_problems()
	end

	-- LC <number> → open starter code from cache
	_G.leetcode_commands.problem = function(number)
		leetcode.problem.open_problem(number)
	end

	-- Register the LC command using the Lua API
	vim.api.nvim_create_user_command("LC", function(opts)
		-- Show notification
		local win, buf = notify.command_notification("Running Leetcode Command...")

		-- Process the command
		vim.schedule(function()
			local args = opts.args
			local arg_parts = {}
			for part in string.gmatch(args, "%S+") do
				table.insert(arg_parts, part)
			end

			if arg_parts[1] == "Pull" then
				_G.leetcode_commands.pull()
			elseif tonumber(arg_parts[1]) ~= nil then
				_G.leetcode_commands.problem(arg_parts[1])
			else
				vim.notify("Unknown LC command: " .. args, vim.log.levels.WARN)
			end
		end)
	end, {
		desc = "LeetCode command for various operations",
		nargs = "+",
		complete = function(argLead, cmdLine)
			local parts = vim.split(vim.fn.trim(cmdLine), "%s+")
			if #parts <= 1 or (parts[1] == "LC" and #parts == 2 and argLead ~= "") then
				return { "Pull" }
			end
			return {}
		end,
	})
end

return M
