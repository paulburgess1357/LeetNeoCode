-- UI rendering for problem view
local vim = vim
local C = require("nvim-leetcode.config")
local format = require("nvim-leetcode.format")
local images = require("nvim-leetcode.images")

local M = {}

-- Open problem description buffer
function M.open_description_buffer(problem_data, num, title, slug)
	vim.cmd("enew")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")

	-- Get image cache directory
	local img_cache_dir = images.get_image_cache_dir(num, title, slug)

	-- Download images and get their paths
	local image_files = images.download_all_images(problem_data.content, img_cache_dir)

	-- Replace image tags with placeholders
	local content_with_placeholders, placeholders = images.prepare_content_with_image_placeholders(problem_data.content)

	-- Format problem text
	local formatted = format.format_problem_text(content_with_placeholders)
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

	-- Find and render images at their placeholder positions
	local win = vim.api.nvim_get_current_win()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	for i, line in ipairs(lines) do
		for placeholder_idx, placeholder in ipairs(placeholders) do
			if line:find(placeholder, 1, true) then
				-- If we have an image for this placeholder
				if image_files[placeholder_idx] then
					-- Split the line at the placeholder
					local parts = vim.split(line, placeholder, { plain = true })

					-- Update the current line to be just the content before the placeholder
					if parts[1] ~= "" then
						vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { parts[1] })
					end

					-- Render the image
					local image_line = i
					if parts[1] ~= "" then
						-- If there was content before the placeholder, add a line for the image
						vim.api.nvim_buf_set_lines(buf, i, i, false, { "" })
						image_line = i
						i = i + 1
					end

					images.render_image(buf, win, image_files[placeholder_idx].path, image_line - 1)

					-- Add content after the placeholder as a new line if it's not empty
					if parts[2] and parts[2] ~= "" then
						vim.api.nvim_buf_set_lines(buf, i, i, false, { parts[2] })
						i = i + 1
					end

					-- Refresh lines after modifications
					lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
					break
				end
			end
		end
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
