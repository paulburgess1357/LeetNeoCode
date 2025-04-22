-- Image handling module for nvim‑leetcode
local vim = vim
local C = require("nvim-leetcode.config")

local M = {}

-- Get image cache directory path for a specific problem
function M.get_image_cache_dir(num, title, slug)
	local safe_title = (title or slug):gsub("%W+", "_"):gsub("^_+", ""):gsub("_+$", "")
	local sol_base = C.cache_dir
	local img_dir = sol_base .. "/images/LC" .. num .. "_" .. safe_title

	-- Create the directory if it doesn't exist
	if vim.fn.isdirectory(sol_base .. "/images") == 0 then
		vim.fn.mkdir(sol_base .. "/images", "p")
	end
	if vim.fn.isdirectory(img_dir) == 0 then
		vim.fn.mkdir(img_dir, "p")
	end

	return img_dir
end

-- Check if image.nvim is available
function M.can_display_images()
	return pcall(require, "image")
end

-- Check if terminal supports images (Kitty)
function M.is_terminal_supported()
	return os.getenv("KITTY_WINDOW_ID") ~= nil
end

-- Extract image URLs from HTML content
function M.extract_image_urls(html_content)
	if not html_content or html_content == "" then
		return {}
	end
	local urls = {}
	-- Improved regex to better capture image tags
	for url in html_content:gmatch('<img[^>]-src="([^"]-)"') do
		if url:sub(1, 4) ~= "http" then
			url = "https://leetcode.com" .. url
		end
		table.insert(urls, url)
	end
	return urls
end

-- Download an image from URL to the cache directory
function M.download_image(url, cache_dir, index)
	local filename = "image_" .. index .. ".png"
	local filepath = cache_dir .. "/" .. filename
	if vim.fn.filereadable(filepath) == 1 then
		return filepath
	end

	local cmd = { "curl", "-s", "-o", filepath, url }
	vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 or vim.fn.filereadable(filepath) ~= 1 then
		vim.notify("Failed to download image: " .. url, vim.log.levels.WARN)
		return nil
	end
	return filepath
end

-- Download all images from a problem description
function M.download_all_images(html_content, cache_dir)
	local urls = M.extract_image_urls(html_content)
	local filepaths = {}
	for i, url in ipairs(urls) do
		local path = M.download_image(url, cache_dir, i)
		if path then
			table.insert(filepaths, { index = i, path = path })
		end
	end
	return filepaths
end

-- Render an image in the buffer with improved placement consistency
function M.render_image(buf, win, filepath, line_num)
	-- Cache to track image renders to prevent duplicates
	_G.leetcode_image_cache = _G.leetcode_image_cache or {}
	local cache_key = buf .. "-" .. line_num

	-- Check if we already rendered this image
	if _G.leetcode_image_cache[cache_key] then
		return
	end

	-- Mark as rendered to prevent duplicates
	_G.leetcode_image_cache[cache_key] = true

	if not M.can_display_images() then
		vim.api.nvim_buf_set_lines(buf, line_num, line_num + 1, false, {
			"[Image: Unable to display - image.nvim not available]",
		})
		return
	end

	if not M.is_terminal_supported() then
		vim.api.nvim_buf_set_lines(buf, line_num, line_num + 1, false, {
			"[Image: Unable to display - terminal doesn't support images]",
		})
		return
	end

	if vim.fn.filereadable(filepath) ~= 1 then
		vim.api.nvim_buf_set_lines(buf, line_num, line_num + 1, false, {
			"[Image: Unable to load from " .. filepath .. "]",
		})
		return
	end

	-- Ensure the target line is empty before rendering
	vim.api.nvim_buf_set_lines(buf, line_num, line_num + 1, false, { "" })

	-- Calculate image dimensions based on window size
	local default_max_width = math.floor(vim.o.columns * 0.35) -- match your split ratio
	local max_width = C.image_max_width or default_max_width
	local max_height = C.image_max_height or 20

	-- Now use image.nvim to render at the exact position
	local img_lib = require("image")

	-- First, clear any existing images at this position
	img_lib.clear({ buffer = buf, window = win })

	-- Create a new image
	local img = img_lib.from_file(filepath, {
		window = win,
		buffer = buf,
		with_virtual_padding = true,
		-- geometry: x = column, y = row (0-based)
		x = 0,
		y = line_num,
	})

	-- Render with proper sizing
	img:render({
		max_width = max_width,
		max_height = max_height,
		preserve_aspect_ratio = C.image_preserve_aspect_ratio or true,
	})
end

return M
