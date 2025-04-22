-- Configuration for nvim‑leetcode
local M = {
	---------------------------------------------------------------------------
	-- Core settings
	---------------------------------------------------------------------------
	default_language = "cpp",

	-- XDG‑compliant paths -----------------------------------------------------
	cache_dir = vim.fn.expand("~/.cache/nvim-leetcode"),
	cache_subdir = "meta",
	cache_file = "leetcode_cache.json",
	cache_expiry_days = 14,
	solutions_subdir = "solutions",
	images_subdir = "images",

	API_URL = "https://leetcode.com/api/problems/all/",

	-- Notification timing -----------------------------------------------------
	notify_wait_timeout = 50, -- ms to keep floating notifier visible
	notify_wait_interval = 10, -- ms polling interval inside vim.wait

	-- Window layout -----------------------------------------------------------
	description_split = 0.35, -- fraction of tab width for description

	---------------------------------------------------------------------------
	-- ❶  Custom hard‑wrap options
	---------------------------------------------------------------------------
	enable_custom_wrap = true, -- set false ⇒ no hard wrapping at all
	custom_wrap_offset = 0.02, -- wrap width uses (description_split – offset)
	-- e.g. 0.35 – 0.10  = 0.25

	---------------------------------------------------------------------------
	-- Feature toggles
	---------------------------------------------------------------------------
	include_problem_metadata = true, -- Include problem metadata
	include_leetcode_tags = true, -- Include LC tags
	include_user_tags = true, -- “User Tags:” stub
	metadata_at_bottom = true, -- Put metadata at file end
	metadata_comment_style = "multi", -- multiline /*…*/

	---------------------------------------------------------------------------
	-- Image handling
	---------------------------------------------------------------------------
	enable_images = true,
	use_direct_urls = true,
	image_render_delay = 100, -- ms
	image_max_width = nil, -- nil → auto
	image_max_height = 20,
	image_right_after_separator = true,
	image_preserve_aspect_ratio = true,
	image_auto_render_on_win_focus = true,
}

-- ---------------------------------------------------------------------------
-- Helper: find dependencies directory
-- ---------------------------------------------------------------------------
function M.get_dependencies_dir()
	local source_path = debug.getinfo(1, "S").source:sub(2)
	local plugin_dir = vim.fn.fnamemodify(source_path, ":h")
	return plugin_dir .. "/dependencies"
end

-- ---------------------------------------------------------------------------
-- Ensure cache directories exist
-- ---------------------------------------------------------------------------
function M.ensure_cache_dirs()
	-- main dir
	if vim.fn.isdirectory(M.cache_dir) == 0 then
		vim.fn.mkdir(M.cache_dir, "p")
	end
	-- metadata
	local meta_dir = M.cache_dir .. "/" .. M.cache_subdir
	if vim.fn.isdirectory(meta_dir) == 0 then
		vim.fn.mkdir(meta_dir, "p")
	end
	-- solutions
	local sol_dir = M.cache_dir .. "/" .. M.solutions_subdir
	if vim.fn.isdirectory(sol_dir) == 0 then
		vim.fn.mkdir(sol_dir, "p")
	end
	-- images (only if we cache locally)
	if not M.use_direct_urls then
		local img_dir = M.cache_dir .. "/" .. M.images_subdir
		if vim.fn.isdirectory(img_dir) == 0 then
			vim.fn.mkdir(img_dir, "p")
		end
	end
end

return M
