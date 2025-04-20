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
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "🧩 Running Leetcode Command..." })

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

	-- Set up syntax highlighting for the metadata comment
	vim.cmd([[
		" Highlight groups for problem metadata and comments
		highlight default link LeetCodeMetadata Identifier
		highlight default link LeetCodeTag Keyword
		highlight default link LeetCodeUserTag String

		" Syntax highlighting for metadata lines in the comment
		syntax match LeetCodeMetadataLine /^\* Problem:.*$/ contained
		syntax match LeetCodeDifficultyLine /^\* Difficulty:.*$/ contained
		syntax match LeetCodeTagsLine /^\* LC Tags:.*$/ contained
		syntax match LeetCodeUserTagsLine /^\* User Tags:.*$/ contained

		highlight LeetCodeMetadataLine guifg=#d8a657 gui=bold
		highlight LeetCodeDifficultyLine guifg=#a9b665 gui=bold
		highlight LeetCodeTagsLine guifg=#7daea3
		highlight LeetCodeUserTagsLine guifg=#e78a4e

		" Autocommands for LeetCode solution files
		augroup LeetCodeSolutions
			autocmd!
			" Set fold method for CPP files in LeetCode solutions directory
			autocmd BufReadPost,BufNewFile */nvim-leetcode/solutions/**/*.cpp setlocal foldmethod=marker
			" Close all folds when opening a solution file
			autocmd BufReadPost,BufNewFile */nvim-leetcode/solutions/**/*.cpp normal! zM
			" Hide fold markers to make them less visually distracting
			autocmd BufReadPost,BufNewFile */nvim-leetcode/solutions/**/*.cpp syntax match Comment /{\{3}/ conceal
			autocmd BufReadPost,BufNewFile */nvim-leetcode/solutions/**/*.cpp syntax match Comment /}\{3}/ conceal
			autocmd BufReadPost,BufNewFile */nvim-leetcode/solutions/**/*.cpp setlocal conceallevel=2
		augroup END
	]])
end

return M
