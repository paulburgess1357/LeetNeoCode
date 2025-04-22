-- lua/nvim‑leetcode/problem/render.lua

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

	-- 1) Download & placeholderize
	local img_cache_dir = images.get_image_cache_dir(num, title, slug)
	local image_files = images.download_all_images(problem_data.content, img_cache_dir)
	local content_ph, placeholders = images.prepare_content_with_image_placeholders(problem_data.content)

	-- 2) Format & populate buffer
	local formatted = format.format_problem_text(content_ph)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(formatted, "\n", { plain = true }))

	vim.api.nvim_buf_set_option(buf, "filetype", "text")
	vim.api.nvim_buf_set_option(buf, "spell", false)
	format.setup_highlighting()

	-- Name the buffer
	local opened_count = _G.leetcode_opened[slug] or 1
	local buf_name = string.format("LC%d %s %d", num, title, opened_count)
	if vim.fn.bufnr(buf_name) == -1 then
		vim.api.nvim_buf_set_name(buf, buf_name)
	end

	-- 3) Find each placeholder, replace it with image or message
	local rendered = {}
	local win = vim.api.nvim_get_current_win()

	-- Create a mapping of placeholder text to its index in image_files
	local placeholder_to_index = {}
	for i, ph_data in ipairs(placeholders) do
		placeholder_to_index[ph_data.placeholder] = i
	end

	-- Process all lines in the buffer for placeholders
	local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local line_adjustments = 0 -- Track line number adjustments

	for ln = 1, #all_lines do
		local adjusted_ln = ln + line_adjustments
		local line = all_lines[ln]

		-- Find placeholder in this line
		for placeholder, idx in pairs(placeholder_to_index) do
			local s, e = line:find(placeholder, 1, true)
			if s then
				-- Get the image file for this placeholder if it exists
				local img = image_files[idx]

				-- Split line at placeholder
				local before = line:sub(1, s - 1)
				local after = line:sub(e + 1)

				-- Create replacement lines
				local new_lines = {}
				if before ~= "" then
					table.insert(new_lines, before)
				end

				-- Add a blank line for the image
				local img_line_idx = #new_lines + 1
				table.insert(new_lines, "")

				if after ~= "" then
					table.insert(new_lines, after)
				end

				-- Only one placeholder per line, so we can replace and move on
				if #new_lines > 0 then
					-- Replace the current line with our new lines
					vim.api.nvim_buf_set_lines(buf, adjusted_ln - 1, adjusted_ln, false, new_lines)

					-- Update line adjustments for any subsequent placeholders
					line_adjustments = line_adjustments + (#new_lines - 1)

					-- Calculate the exact row for rendering the image
					local render_row = (adjusted_ln - 1) + (img_line_idx - 1)

					-- Store rendering info and render the image immediately
					if img and img.path then
						table.insert(rendered, { row = render_row, path = img.path })
						images.render_image(buf, win, img.path, render_row)
					else
						-- No image file available, just show placeholder text
						local message = "[Image: Unable to display - terminal doesn't support images]"
						vim.api.nvim_buf_set_lines(buf, render_row, render_row + 1, false, { message })
					end

					break -- Done with this line
				end
			end
		end
	end

	-- 4) Autocmd group to re‑draw images on scroll/enter/resize
	local group = "LeetCodeImages_" .. buf
	vim.api.nvim_create_augroup(group, { clear = true })
	vim.api.nvim_create_autocmd({ "BufWinEnter", "WinScrolled", "VimResized" }, {
		group = group,
		buffer = buf,
		callback = function()
			local w = vim.api.nvim_get_current_win()
			for _, entry in ipairs(rendered) do
				if entry.path then
					images.render_image(buf, w, entry.path, entry.row)
				end
			end
		end,
	})

	return buf
end

-- Open solution buffer in a split
function M.open_solution_buffer(fpath)
	vim.cmd("vsplit " .. vim.fn.fnameescape(fpath))
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_option(buf, "filetype", C.default_language)
	vim.cmd("setlocal foldmethod=marker")
	vim.defer_fn(function()
		vim.cmd("normal! zM")
	end, 100)
	return buf
end

-- Adjust split layout
function M.setup_split_layout()
	local frac = C.description_split or 0.5
	local total = vim.o.columns
	local desc_w = math.floor(total * frac)
	local cur_win = vim.api.nvim_get_current_win()
	local wins = vim.api.nvim_tabpage_list_wins(0)
	local desc_win = (wins[1] == cur_win) and wins[2] or wins[1]
	vim.api.nvim_win_set_width(desc_win, desc_w)
end

-- Master open function
function M.open_problem_view(problem_data, snippets, fpath, num, title, slug)
	vim.cmd("tabnew")
	if problem_data.content ~= "" then
		M.open_description_buffer(problem_data, num, title, slug)
	end
	if snippets and fpath then
		M.open_solution_buffer(fpath)
		M.setup_split_layout()
	end
end

return M
