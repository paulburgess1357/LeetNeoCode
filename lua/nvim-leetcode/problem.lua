-- Problem handling module
local vim = vim

-- Shared modules
local C = require("nvim-leetcode.config")
local pull_meta = require("nvim-leetcode.pull")
local pull_code = require("nvim-leetcode.pull_code")
local pull_desc = require("nvim-leetcode.pull_description")
local formatter = require("nvim-leetcode.problem_formatter")

-- -----------------------------------------------------------------------------
-- Helpers for metadata cache & paths
-- -----------------------------------------------------------------------------
local function get_cache_path()
	return C.cache_dir .. "/" .. C.cache_subdir .. "/" .. C.cache_file
end

local function get_solution_dir()
	return C.cache_dir .. "/" .. C.solutions_subdir
end

local function cache_stale_or_missing(path)
	local stat = vim.loop.fs_stat(path)
	if not stat then
		return true
	end
	local mtime_secs = stat.mtime.sec or stat.mtime
	return (os.time() - mtime_secs) > (C.cache_expiry_days * 86400)
end

local function load_cache(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local raw = f:read("*a")
	f:close()
	local ok, data = pcall(vim.fn.json_decode, raw)
	return ok and data or nil
end

-- -----------------------------------------------------------------------------
-- Main: fetch & open a problem's description + code stub
-- -----------------------------------------------------------------------------
local M = {}
_G.leetcode_opened = _G.leetcode_opened or {}

function M.open_problem(number)
	local num = tonumber(number)
	if not num then
		vim.notify("Invalid problem number: " .. tostring(number), vim.log.levels.ERROR)
		return
	end

	-- 1) Refresh metadata if needed
	local cache_path = get_cache_path()
	if cache_stale_or_missing(cache_path) then
		vim.notify(
			("Metadata cache missing/older than %d days; pulling…"):format(C.cache_expiry_days),
			vim.log.levels.INFO
		)
		pull_meta.pull_problems()
	end

	-- 2) Load metadata
	local meta = load_cache(cache_path)
	if not meta or not meta.stat_status_pairs then
		vim.notify("Failed to load metadata cache", vim.log.levels.ERROR)
		return
	end

	-- 3) Resolve slug, title, check premium
	local slug, title, paid_only, found
	for _, pair in ipairs(meta.stat_status_pairs) do
		if pair.stat.frontend_question_id == num then
			slug = pair.stat.question__title_slug
			title = pair.stat.question__title
			paid_only = pair.paid_only
			found = true
			break
		end
	end
	if not found then
		vim.notify("Problem #" .. num .. " not found.", vim.log.levels.ERROR)
		return
	elseif paid_only then
		vim.notify(string.format("Problem #%d (%s) is premium", num, title), vim.log.levels.WARN)
		return
	end

	-- 4) Prepare solution directory
	local safe_title = (title or slug):gsub("%W+", "_"):gsub("^_+", ""):gsub("_+$", "")
	local sol_base = get_solution_dir()
	if vim.fn.isdirectory(sol_base) == 0 then
		vim.fn.mkdir(sol_base, "p")
	end

	local prob_dir = sol_base .. "/LC" .. num .. "_" .. safe_title
	if vim.fn.isdirectory(prob_dir) == 0 then
		vim.fn.mkdir(prob_dir, "p")
	end

	-- Get the absolute path to the dependencies directory
	local dep_dir
	do
		-- Find the plugin installation path
		local plugin_paths = {
			-- Check LazyVim path first
			vim.fn.expand("~/.local/share/nvim/lazy/nvim-leetcode/lua/nvim-leetcode/dependencies"),
			-- Check Packer path
			vim.fn.expand("~/.local/share/nvim/site/pack/packer/start/nvim-leetcode/lua/nvim-leetcode/dependencies"),
			-- Check built-in module path (fallback)
			C.get_dependencies_dir(),
		}

		for _, path in ipairs(plugin_paths) do
			if vim.fn.isdirectory(path) == 1 then
				dep_dir = path
				break
			end
		end

		if not dep_dir then
			vim.notify("Could not find dependencies directory. Symlinks may not work.", vim.log.levels.WARN)
			dep_dir = C.get_dependencies_dir()
		end
	end

	-- Symlink shared configs and header files with absolute paths
	do
		for _, fname in ipairs({
			"lc_includes.h",
			".clangd",
			".clang-format",
			".clang-tidy",
		}) do
			local src = dep_dir .. "/" .. fname
			local dst = prob_dir .. "/" .. fname

			-- Check if source file exists
			if vim.fn.filereadable(src) == 1 and vim.fn.filereadable(dst) == 0 then
				-- Create an absolute symlink
				vim.fn.system({ "ln", "-s", src, dst })

				-- Verify symlink was created successfully
				if vim.v.shell_error ~= 0 then
					vim.notify("Failed to create symlink for " .. fname, vim.log.levels.WARN)
				end
			end
		end
	end

	-- 5) Fetch description & stub
	local content_html = ""
	do
		local ok, result = pcall(pull_desc.fetch_description, slug)
		content_html = ok and type(result) == "string" and result or ""
		if content_html == "" then
			vim.notify("Could not fetch description for #" .. num, vim.log.levels.WARN)
		end
	end

	local snippets
	do
		local ok, res = pcall(pull_code.fetch_stub, slug)
		snippets = ok and res or nil
		if not snippets then
			vim.notify("Could not fetch code stub for #" .. num, vim.log.levels.WARN)
		end
	end

	-- 6) Determine next solution version
	local max_index = 0
	for _, path in ipairs(vim.fn.globpath(prob_dir, "Solution_*." .. C.default_language, false, true)) do
		local name = vim.fn.fnamemodify(path, ":t")
		local idx = tonumber(name:match("^Solution_(%d+)")) or 0
		if idx > max_index then
			max_index = idx
		end
	end
	local version = max_index + 1
	local fname = string.format("Solution_%d.%s", version, C.default_language)
	local fpath = prob_dir .. "/" .. fname

	-- 7) Save stub to file
	if snippets then
		local f = io.open(fpath, "w")
		if f then
			f:write('#include "lc_includes.h"\n\n')
			f:write(snippets)
			f:close()
		end
	end

	-- record open count
	_G.leetcode_opened[slug] = (_G.leetcode_opened[slug] or 0) + 1

	-- 8) Open tab + splits
	vim.cmd("tabnew")

	if content_html ~= "" then
		vim.cmd("enew")
		local buf = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
		vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

		-- Format problem text
		local formatted = formatter.format_problem_text(content_html)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(formatted, "\n", { plain = true }))

		-- Buffer options
		vim.api.nvim_buf_set_option(buf, "filetype", "text")
		vim.api.nvim_buf_set_option(buf, "spell", false)

		-- Apply syntax highlighting
		formatter.setup_highlighting()

		-- Name the buffer
		local buf_name = string.format("LC%d %s %d", num, title, _G.leetcode_opened[slug])
		if vim.fn.bufnr(buf_name) == -1 then
			vim.api.nvim_buf_set_name(buf, buf_name)
		end
	end

	-- Open the solution stub in a vertical split
	if snippets then
		vim.cmd("vsplit " .. vim.fn.fnameescape(fpath))
		vim.api.nvim_buf_set_option(0, "filetype", C.default_language)

		-- Resize description pane
		local split_frac = C.description_split or 0.5
		local total_cols = vim.o.columns
		local desc_cols = math.floor(total_cols * split_frac)
		local sol_win = vim.api.nvim_get_current_win()
		local wins = vim.api.nvim_tabpage_list_wins(0)
		local desc_win = (wins[1] == sol_win) and wins[2] or wins[1]
		vim.api.nvim_win_set_width(desc_win, desc_cols)
	end

	vim.notify(string.format("Loaded problem #%d: %s (v%d)", num, title, version), vim.log.levels.INFO)
end

M.problem = M.open_problem
return M
