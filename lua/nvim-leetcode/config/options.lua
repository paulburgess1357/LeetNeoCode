-- Configuration options for nvim-leetcode
local M = {
	---------------------------------------------------------------------------
	-- Core settings
	---------------------------------------------------------------------------
	default_language = "cpp",

	-- XDG-compliant paths -----------------------------------------------------
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
	-- Custom hard-wrap options
	---------------------------------------------------------------------------
	enable_custom_wrap = true, -- set false ⇒ no hard wrapping at all
	custom_wrap_offset = 0.02, -- wrap width uses (description_split – offset)
	-- e.g. 0.35 – 0.10  = 0.25

	---------------------------------------------------------------------------
	-- Feature toggles
	---------------------------------------------------------------------------
	include_problem_metadata = true, -- Include problem metadata
	include_leetcode_tags = true, -- Include LC tags
	include_user_tags = true, -- "User Tags:" stub
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

	---------------------------------------------------------------------------
	-- Code block highlighting
	---------------------------------------------------------------------------
	code_block_start = "{", -- Start marker for code blocks
	code_block_end = "}", -- End marker for code blocks
	code_block_color = "#e6c07a", -- Color for code blocks
	code_block_style = "italic", -- Style for code blocks (normal, bold, italic)
}

return M
