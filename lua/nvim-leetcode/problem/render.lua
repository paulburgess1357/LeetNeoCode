-- UI rendering for problem view
local vim = vim
local C = require("nvim-leetcode.config")
local format = require("nvim-leetcode.format")

local M = {}

-- Open problem description buffer
function M.open_description_buffer(problem_data, num, title, slug)
	vim.cmd("enew")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")

	-- Format problem text
	local formatted = format.format_problem_text(problem_data.content)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(formatted, "\n", { plain = true }))

	-- Buffer options
	vim.api.nvim_buf_set_option(buf, "filetype", "text")
	vim.api.nvim_buf_set_option(buf, "spell", false)

	-- Apply syntax highlighting
	format.setup_highlighting()

	-- Name the buffer
	local opened_count = _G.leetcode_opened[slug] or 1
	local buf_name = string.format("LC%d %s %d", num, title, opened_count)
	if vim.fn.bufnr(buf_name) == -1 then
		vim.api.nvim_buf_set_name(buf, buf_name)
	end

	-- Render test image at the very bottom (Kitty graphics protocol)
	local img_path = vim.fn.expand("~/.cache/nvim-leetcode/images/addtwonumber1.jpg")
	if vim.fn.filereadable(img_path) == 1 then
		local win = vim.api.nvim_get_current_win()
		local img = require("image").from_file(img_path, {
			window = win,
			buffer = buf,
			with_virtual_padding = true,
			inline = false,
		})
		img:render()
	end

	return buf
end

-- Open solution buffer in a split
function M.open_solution_buffer(fpath)
	vim.cmd("vsplit " .. vim.fn.fnameescape(fpath))
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_option(buf, "filetype", C.default_language)

	-- Set fold method to marker
	vim.cmd("setlocal foldmethod=marker")

	-- Ensure folds are closed
	vim.defer_fn(function()
		vim.cmd("normal! zM")
	end, 100)

	return buf
end

-- Setup the split layout
function M.setup_split_layout()
	local split_frac = C.description_split or 0.5
	local total_cols = vim.o.columns
	local desc_cols = math.floor(total_cols * split_frac)
	local sol_win = vim.api.nvim_get_current_win()
	local wins = vim.api.nvim_tabpage_list_wins(0)
	local desc_win = (wins[1] == sol_win) and wins[2] or wins[1]
	vim.api.nvim_win_set_width(desc_win, desc_cols)
end

-- Open the full problem view
function M.open_problem_view(problem_data, snippets, fpath, num, title, slug)
	-- Open in a new tab
	vim.cmd("tabnew")

	-- Open description if available
	if problem_data.content ~= "" then
		M.open_description_buffer(problem_data, num, title, slug)
	end

	-- Open solution if available
	if snippets and fpath then
		M.open_solution_buffer(fpath)
		M.setup_split_layout()
	end
end

return M
