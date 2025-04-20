-- Configuration for nvim-leetcode
local M = {
	default_language = "cpp",

	-- XDG-compliant paths
	cache_dir = vim.fn.expand("~/.cache/nvim-leetcode"),
	cache_subdir = "meta",
	cache_file = "leetcode_cache.json",
	cache_expiry_days = 14,
	solutions_subdir = "solutions",

	API_URL = "https://leetcode.com/api/problems/all/",

	-- How long (in ms) to wait after redraw for notifications to appear
	notify_wait_timeout = 50,

	-- How often (in ms) vim.wait should poll before giving up
	notify_wait_interval = 10,

	description_split = 0.35,

	-- Features configuration
	include_problem_metadata = true, -- Include problem metadata
	include_leetcode_tags = true, -- Include LeetCode tags
	include_user_tags = true, -- Include user tags section
	metadata_at_bottom = true, -- Put metadata at the bottom of the file
	metadata_comment_style = "multi", -- Use multiline comment style
}

-- Find path to the dependencies directory
function M.get_dependencies_dir()
	-- Get the directory where this plugin's lua files are installed
	local source_path = debug.getinfo(1, "S").source:sub(2)
	local plugin_dir = vim.fn.fnamemodify(source_path, ":h")
	return plugin_dir .. "/dependencies"
end

-- Ensure cache directories exist
function M.ensure_cache_dirs()
	-- Create main cache directory
	if vim.fn.isdirectory(M.cache_dir) == 0 then
		vim.fn.mkdir(M.cache_dir, "p")
	end

	-- Create metadata cache subdir
	local meta_dir = M.cache_dir .. "/" .. M.cache_subdir
	if vim.fn.isdirectory(meta_dir) == 0 then
		vim.fn.mkdir(meta_dir, "p")
	end

	-- Create solutions subdir
	local sol_dir = M.cache_dir .. "/" .. M.solutions_subdir
	if vim.fn.isdirectory(sol_dir) == 0 then
		vim.fn.mkdir(sol_dir, "p")
	end
end

return M
