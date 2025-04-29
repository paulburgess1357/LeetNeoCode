-- lua/LeetNeoCode/util/custom_copy.lua
local M = {}
local C = require("LeetNeoCode.config")

-- highlight namespace and group for flash
local HIGHLIGHT_NS = vim.api.nvim_create_namespace("LeetNeoCodeCopyFlash")
local HIGHLIGHT_GROUP = "LeetNeoCodeCopyFlashGroup"

-- define the highlight group based on config (custom_copy_color)
vim.api.nvim_set_hl(0, HIGHLIGHT_GROUP, C.custom_copy_color and { bg = C.custom_copy_color } or {})

-- Helper to emit OSC-52 over stdout
local function set_clipboard(text)
	local b64 = vim.fn.system({ "base64" }, text):gsub("\n", "")
	local osc = string.format("\027]52;c;%s\007", b64)
	vim.api.nvim_out_write(osc)
end

-- Core: grab lines, trim cols, filter, then copy
function M.copy_region(s_line, s_col, e_line, e_col)
	local lines = vim.api.nvim_buf_get_lines(0, s_line - 1, e_line, false)

	if #lines > 0 then
		if #lines == 1 then
			lines[1] = lines[1]:sub(s_col + 1, e_col + 1)
		else
			lines[1] = lines[1]:sub(s_col + 1)
			lines[#lines] = lines[#lines]:sub(1, e_col + 1)
		end
	end

	-- strip includes/imports and folded metadata
	local start_marker = C.fold_marker_start or "▼"
	local end_marker = C.fold_marker_end or "▲"
	local out, skipping, saw_fold = {}, false, false

	for i, line in ipairs(lines) do
		if
			i == 1
			and (
				line:match("^#include")
				or line:match("^import")
				or line:match("^from")
				or line:match("^package")
				or line:match("^mod ")
				or line:match("^using ")
			)
		then
		-- skip top header
		elseif line:find(start_marker, 1, true) then
			skipping, saw_fold = true, true
		elseif line:find(end_marker, 1, true) then
			skipping = false
		elseif not skipping then
			table.insert(out, line)
		end
	end

	-- if no folds but header existed, drop leading blank
	if not saw_fold then
		local buf0 = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
		if
			buf0:match("^#include")
			or buf0:match("^import")
			or buf0:match("^from")
			or buf0:match("^package")
			or buf0:match("^mod ")
			or buf0:match("^using ")
		then
			if out[1] == "" then
				table.remove(out, 1)
			end
		end
	end

	local txt = table.concat(out, "\n")

	-- set registers + OSC-52
	vim.fn.setreg('"', txt)
	vim.fn.setreg("+", txt)
	set_clipboard(txt)

	-- flash highlight
	M.flash_region(s_line, s_col, e_line, e_col)

	vim.notify("🧩 LeetCode Smart Copy ✓", vim.log.levels.DEBUG, { timeout = 500 })
	-- clear any leftover command
	vim.api.nvim_feedkeys(":<C-u>", "nx", false)
end

-- Called on visual-mode <y>
function M.custom_yank()
	local s_line, s_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
	local e_line, e_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))
	M.copy_region(s_line, s_col, e_line, e_col)
end

-- operatorfunc handler for normal-mode y{motion}
function M.yank_operator(motion_type)
	local start = vim.api.nvim_buf_get_mark(0, "[")
	local finish = vim.api.nvim_buf_get_mark(0, "]")
	M.copy_region(start[1], start[2], finish[1], finish[2])
end

-- flash highlight of yanked region
function M.flash_region(s_line, s_col, e_line, e_col)
	for ln = s_line - 1, e_line - 1 do
		local start_col = (ln == s_line - 1) and s_col or 0
		local end_col = (ln == e_line - 1) and (e_col + 1) or -1
		vim.api.nvim_buf_add_highlight(0, HIGHLIGHT_NS, HIGHLIGHT_GROUP, ln, start_col, end_col)
	end
	vim.defer_fn(function()
		vim.api.nvim_buf_clear_namespace(0, HIGHLIGHT_NS, 0, -1)
	end, 200)
end

-- Setup: override “y” only in your problem buffers
function M.setup()
	if not C.custom_copy then
		return
	end

	vim.api.nvim_create_augroup("LeetCodeCustomCopy", { clear = true })

	local sol = C.cache_dir .. "/" .. C.solutions_subdir
	local pattern = vim.fn.escape(sol, "\\") .. "/**/*.{cpp,py,java,js,go,rs,swift,cs}"

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = "LeetCodeCustomCopy",
		pattern = pattern,
		callback = function()
			vim.api.nvim_buf_set_keymap(
				0,
				"n",
				"y",
				"<cmd>set operatorfunc=v:lua.require'LeetNeoCode.util.custom_copy'.yank_operator<CR>g@",
				{ noremap = true, silent = true }
			)
			vim.api.nvim_buf_set_keymap(
				0,
				"x",
				"y",
				"<cmd>lua require('LeetNeoCode.util.custom_copy').custom_yank()<CR>",
				{ noremap = true, silent = true }
			)
		end,
	})
end

return M
