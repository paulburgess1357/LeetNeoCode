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

-- Replace <img> tags with placeholders, ensuring each image tag is uniquely identified
function M.prepare_content_with_image_placeholders(html_content)
	if not html_content or html_content == "" then
		return html_content, {}
	end
	local placeholders = {}
	local count = 0

	-- Improved regex to better match complete img tags
	local content = html_content:gsub("<img[^>]-/?>", function(img_tag)
		count = count + 1
		local ph = "___IMAGE_PLACEHOLDER_" .. count .. "___"
		table.insert(placeholders, { placeholder = ph, tag = img_tag })
		return ph
	end)

	return content, placeholders
end

-- Render an image in the buffer
function M.render_image(buf, win, filepath, line_num)
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

	-- reserve exactly one blank line at `line_num`
	vim.api.nvim_buf_set_lines(buf, line_num, line_num + 1, false, { "" })

	-- now hand off to image.nvim with an explicit x/y geometry
	local img = require("image").from_file(filepath, {
		window = win,
		buffer = buf,
		with_virtual_padding = true,
		-- geometry: x = column, y = row (0-based)
		x = 0,
		y = line_num,
	})

	img:render()
end

return M
