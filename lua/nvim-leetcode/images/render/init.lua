-- Image rendering module
local M = {}
local C = require("nvim-leetcode.config")

-- Check if image.nvim is available
function M.can_display_images()
	return pcall(require, "image")
end

-- Check if terminal supports images (Kitty)
function M.is_terminal_supported()
	for _, check in ipairs(C.image_terminals or {}) do
		local v = os.getenv(check.var)
		if v then
			if not check.match or v:find(check.match, 1, true) then
				return true
			end
		end
	end
	return false
end

-- Render an image in the buffer directly from URL
function M.render_image(buf, win, image_url, line_num)
	-- only render if this 'win' is the left-most window in the current tab
	local wins = vim.api.nvim_tabpage_list_wins(0)
	if wins[1] ~= win then
		return
	end

	-- Cache to track image renders to prevent duplicates
	_G.leetcode_image_cache = _G.leetcode_image_cache or {}
	local cache_key = buf .. "-" .. line_num

	-- Check if we already rendered this image
	if _G.leetcode_image_cache[cache_key] then
		return
	end

	-- Mark as rendered to prevent duplicates
	_G.leetcode_image_cache[cache_key] = true

	-- Fallback if image.nvim is not installed
	if not M.can_display_images() then
		vim.api.nvim_buf_set_lines(buf, line_num, line_num + 1, false, {
			"[Image: Unable to display - image.nvim not available]",
		})
		return
	end

	-- Fallback if terminal does not support inline images
	if not M.is_terminal_supported() then
		vim.api.nvim_buf_set_lines(buf, line_num, line_num + 1, false, {
			"[Image: Unable to display - terminal doesn't support images]",
		})
		return
	end

	-- Ensure the target line is empty before rendering
	vim.api.nvim_buf_set_lines(buf, line_num, line_num + 1, false, { "" })

	-- Calculate image dimensions based on window size
	local default_max_width = math.floor(vim.o.columns * 0.35)
	local max_width = C.image_max_width or default_max_width
	local max_height = C.image_max_height or 20

	-- Use image.nvim to render from URL
	local img_lib = require("image")

	-- Clear any existing images at this position
	img_lib.clear({ buffer = buf, window = win })

	-- Fetch and render the image
	img_lib.from_url(image_url, {
		window = win,
		buffer = buf,
		with_virtual_padding = true,
		x = 0,
		y = line_num,
	}, function(img)
		if img then
			img:render({
				max_width = max_width,
				max_height = max_height,
				preserve_aspect_ratio = C.image_preserve_aspect_ratio or true,
			})
		else
			vim.api.nvim_buf_set_lines(buf, line_num, line_num + 1, false, {
				"[Image: Failed to load from URL]",
			})
		end
	end)
end

return M
