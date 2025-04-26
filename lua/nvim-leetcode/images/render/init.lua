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

	-- Debug output
	-- print("Debug - Image rendering with settings:")
	-- print("  image_max_width:", C.image_max_width)
	-- print("  image_max_height:", C.image_max_height)
	-- print("  image_max_width_pct:", C.image_max_width_pct)
	-- print("  image_max_height_pct:", C.image_max_height_pct)

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

	-- Calculate image dimensions
	local default_max_width = math.floor(vim.o.columns * 0.35)
	local max_width = nil
	local max_height = nil

	-- Get window dimensions for percentage calculations
	local win_width = vim.api.nvim_win_get_width(win)
	local win_height = vim.api.nvim_win_get_height(win)

	-- Calculate dimensions based on percentages or fixed values
	if C.image_max_width_pct and C.image_max_width_pct > 0 then
		max_width = math.floor(win_width * (C.image_max_width_pct / 100))
		-- print("  Using percentage width:", max_width, "columns")
	else
		max_width = C.image_max_width or default_max_width
		-- print("  Using fixed width:", max_width, "columns")
	end

	if C.image_max_height_pct and C.image_max_height_pct > 0 then
		max_height = math.floor(win_height * (C.image_max_height_pct / 100))
		-- print("  Using percentage height:", max_height, "rows")
	else
		max_height = C.image_max_height or 20
		-- print("  Using fixed height:", max_height, "rows")
	end

	-- Use image.nvim to render from URL
	local img_lib = require("image")

	-- Clear any existing images at this position
	img_lib.clear({ buffer = buf, window = win })

	-- Fetch and render the image with proper type-compatible geometry
	img_lib.from_url(image_url, {
		window = win,
		buffer = buf,
		with_virtual_padding = true,
		x = 0,
		y = line_num,
		max_width_window_percentage = C.image_max_width_pct,
		max_height_window_percentage = C.image_max_height_pct,
	}, function(img)
		if img then
			-- Render with proper geometry properties according to type definitions
			img:render({
				width = max_width,
				height = max_height,
			})
			-- print("  Image rendered successfully with size:", max_width, "x", max_height)
		else
			vim.api.nvim_buf_set_lines(buf, line_num, line_num + 1, false, {
				"[Image: Failed to load from URL]",
			})
			print("  Failed to load image from URL")
		end
	end)
end

return M
