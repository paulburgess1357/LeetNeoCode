local M = {}
local C = require("LeetNeoCode.config")

function M.setup()
	if not C.custom_copy then
		return
	end

	vim.api.nvim_create_augroup("LeetCodeCustomCopy", { clear = true })

	-- This will run whenever a solution file is loaded
	local solutions_path = C.cache_dir .. "/" .. C.solutions_subdir
	local file_pattern = vim.fn.escape(solutions_path, "\\") .. "/**/*.{cpp,py,java,js,go,rs,swift,cs}"

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = "LeetCodeCustomCopy",
		pattern = file_pattern,
		callback = function()
			-- Override the yank operator for this buffer
			vim.api.nvim_buf_set_keymap(
				0,
				"n",
				"y",
				"<cmd>lua require('LeetNeoCode.util.custom_copy').custom_yank()<CR>",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_buf_set_keymap(
				0,
				"v",
				"y",
				"<cmd>lua require('LeetNeoCode.util.custom_copy').custom_yank()<CR>",
				{ noremap = true, silent = true }
			)
		end,
	})
end

function M.custom_yank()
	-- Get the current mode
	local mode = vim.api.nvim_get_mode().mode

	-- If in normal mode with a motion, we need to handle this specially
	if mode == "n" then
		-- Set an opfunc and trigger it with g@
		vim.o.operatorfunc = "v:lua.require'LeetNeoCode.util.custom_copy'.yank_operator"
		vim.api.nvim_feedkeys("g@", "n", false)
		return
	end

	-- Get the text from the visual selection
	local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
	local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))

	-- Get all lines in the selection
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	-- Adjust the first and last line to respect the columns
	if #lines > 0 then
		if #lines == 1 then
			lines[1] = lines[1]:sub(start_col + 1, end_col + 1)
		else
			lines[1] = lines[1]:sub(start_col + 1)
			lines[#lines] = lines[#lines]:sub(1, end_col + 1)
		end
	end

	-- Process the lines to remove includes and metadata
	local fold_start = C.fold_marker_start or "▼"
	local fold_end = C.fold_marker_end or "▲"

	local filtered_lines = {}
	local skip_mode = false
	local metadata_found = false

	for i, line in ipairs(lines) do
		-- Skip the include line at the top (language specific)
		if
			i == 1
			and (
				line:find("^#include")
				or line:find("^import")
				or line:find("^from")
				or line:find("^package")
				or line:find("^mod ")
				or line:find("^using ")
			)
		then
		-- Skip this line
		-- Skip metadata section
		elseif line:find(fold_start, 1, true) then
			skip_mode = true
			metadata_found = true
		elseif line:find(fold_end, 1, true) then
			skip_mode = false
		elseif not skip_mode then
			table.insert(filtered_lines, line)
		end
	end

	-- If we're skipping and haven't found metadata, check if we have a header comment
	if not metadata_found then
		local buffer_text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
		local has_header = buffer_text:match("^#include")
			or buffer_text:match("^import")
			or buffer_text:match("^from")
			or buffer_text:match("^package")
			or buffer_text:match("^mod ")
			or buffer_text:match("^using ")

		if has_header and #filtered_lines > 0 and filtered_lines[1] == "" then
			table.remove(filtered_lines, 1) -- Remove the blank line after the header
		end
	end

	-- Copy the filtered text to the clipboard
	local filtered_text = table.concat(filtered_lines, "\n")
	vim.fn.setreg('"', filtered_text)
	vim.fn.setreg("+", filtered_text)

	-- Show a brief notification that smart copy was used
	vim.notify("🧩 LeetCode Smart Copy", vim.log.levels.DEBUG, {
		timeout = 800,
	})
	-- Flash the selection to indicate success
	vim.api.nvim_feedkeys(":<C-u>", "nx", false) -- Clear the command line
end

-- This function is used for the operator-pending mode
function M.yank_operator(motion_type)
	local mark_begin, mark_end
	if motion_type == "char" then
		mark_begin, mark_end = "'[", "']"
	elseif motion_type == "line" then
		mark_begin, mark_end = "'[", "']"
	elseif motion_type == "block" then
		mark_begin, mark_end = "`[", "`]"
	else
		return
	end

	-- Set visual marks based on operator marks
	vim.api.nvim_command("normal! " .. mark_begin .. "v" .. mark_end)
	M.custom_yank()
end

return M
