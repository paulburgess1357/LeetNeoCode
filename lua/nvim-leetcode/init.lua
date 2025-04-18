-- Main entry point for nvim-leetcode plugin
local M = {}

-- Store references to submodules
M.config = require("nvim-leetcode.config")
M.pull = require("nvim-leetcode.pull")
M.problem = require("nvim-leetcode.problem")

-- Leetcode commands storage
_G.leetcode_commands = _G.leetcode_commands or {}

-- Setup function with user config
function M.setup(user_config)
	-- Merge user config with defaults
	if user_config then
		for k, v in pairs(user_config) do
			M.config[k] = v
		end
	end

	-- Initialize cache directories
	M.config.ensure_cache_dirs()

	-- Define commands table
	_G.leetcode_commands = {
		-- LC Pull → full pull & cache
		pull = function()
			M.pull.pull_problems()
		end,

		-- LC <number> → open starter code from cache
		problem = function(number)
			M.problem.open_problem(number)
		end,
	}

	-- Register the LC command using the Lua API
	vim.api.nvim_create_user_command("LC", function(opts)
		-- Create an instant floating window notification
		local width = 30
		local height = 1
		local win_opts = {
			relative = "editor",
			width = width,
			height = height,
			col = math.floor((vim.o.columns - width) / 2),
			row = math.floor((vim.o.lines - height) / 2),
			style = "minimal",
			border = "rounded",
		}

		-- Create buffer and set content
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "🧩 Starting Leetcode..." })

		-- Apply highlight
		local ns_id = vim.api.nvim_create_namespace("leetcode_notification")
		vim.api.nvim_buf_add_highlight(buf, ns_id, "MoreMsg", 0, 0, -1)

		-- Show the floating window
		local win = vim.api.nvim_open_win(buf, false, win_opts)

		-- Process the command and close the window after a short delay
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

			-- Close the notification window after a short delay
			vim.defer_fn(function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
				if vim.api.nvim_buf_is_valid(buf) then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
			end, 1000) -- Close after 1 second
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
