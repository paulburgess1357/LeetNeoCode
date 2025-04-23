-- Notification utilities for nvim-leetcode
local M = {}
local C = require("nvim-leetcode.config")

-- Create a floating notification window
function M.floating_notification(message, timeout)
	timeout = timeout or 1000 -- default to 1 second

	-- Create window dimensions
	local width = #message + 4
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
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { message })

	-- Apply highlighting
	local ns_id = vim.api.nvim_create_namespace("leetcode_notification")
	vim.api.nvim_buf_add_highlight(buf, ns_id, "MoreMsg", 0, 0, -1)

	-- Show the floating window
	local win = vim.api.nvim_open_win(buf, false, win_opts)

	-- Close the window after specified timeout
	vim.defer_fn(function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end, timeout)

	return win, buf
end

-- Show notification for command execution
function M.command_notification(message)
	return M.floating_notification("🧩 " .. message, 1000)
end

return M
