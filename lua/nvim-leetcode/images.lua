-- Image handling module for nvim-leetcode
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
	local has_image = pcall(require, "image")
	return has_image
end

-- Check if terminal supports images (Kitty)
function M.is_terminal_supported()
	-- Check for Kitty terminal
	local is_kitty = os.getenv("KITTY_WINDOW_ID") ~= nil

	-- You can add other terminal checks here (e.g., iTerm2)

	return is_kitty
end

-- Extract image URLs from HTML content
function M.extract_image_urls(html_content)
	if not html_content or html_content == "" then
		return {}
	end

	local urls = {}
	for url in html_content:gmatch('<img.-src="(.-)"') do
		-- Convert relative URLs to absolute URLs if necessary
		if url:sub(1, 4) ~= "http" then
			url = "https://leetcode.com" .. url
		end
		table.insert(urls, url)
	end

	return urls
end

-- Download an image from URL to the cache directory
function M.download_image(url, cache_dir, index)
	-- Generate a filename based on the URL
	local filename = "image_" .. index .. ".png"
	local filepath = cache_dir .. "/" .. filename

	-- Skip download if file already exists
	if vim.fn.filereadable(filepath) == 1 then
		return filepath
	end

	-- Download the image using curl
	local cmd = {
		"curl",
		"-s",
		"-o",
		filepath,
		url,
	}

	vim.fn.system(cmd)

	-- Check if download was successful
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
		local filepath = M.download_image(url, cache_dir, i)
		if filepath then
			table.insert(filepaths, {
				index = i,
				path = filepath,
			})
		end
	end

	return filepaths
end

-- Replace image tags in HTML with placeholders for rendering
function M.prepare_content_with_image_placeholders(html_content)
	if not html_content or html_content == "" then
		return html_content, {}
	end

	local placeholders = {}
	local count = 0

	local content = html_content:gsub('<img.-src=".-".-/>', function()
		count = count + 1
		local placeholder = "___IMAGE_PLACEHOLDER_" .. count .. "___"
		table.insert(placeholders, placeholder)
		return placeholder
	end)

	return content, placeholders
end

-- Render an image in the buffer
function M.render_image(buf, win, filepath, line_num)
	if not M.can_display_images() then
		-- Insert text placeholder if image.nvim is not available
		vim.api.nvim_buf_set_lines(
			buf,
			line_num,
			line_num,
			false,
			{ "[Image: Unable to display - image.nvim not available]" }
		)
		return
	end

	if not M.is_terminal_supported() then
		-- Insert text placeholder if terminal doesn't support images
		vim.api.nvim_buf_set_lines(
			buf,
			line_num,
			line_num,
			false,
			{ "[Image: Unable to display - terminal doesn't support images]" }
		)
		return
	end

	if vim.fn.filereadable(filepath) ~= 1 then
		-- Insert text placeholder if image file doesn't exist
		vim.api.nvim_buf_set_lines(
			buf,
			line_num,
			line_num,
			false,
			{ "[Image: Unable to load from " .. filepath .. "]" }
		)
		return
	end

	-- Insert a blank line for the image
	vim.api.nvim_buf_set_lines(buf, line_num, line_num, false, { "" })

	-- Use image.nvim to render the image
	local img = require("image").from_file(filepath, {
		window = win,
		buffer = buf,
		with_virtual_padding = true,
		inline = false,
	})

	img:render()
end

return M
