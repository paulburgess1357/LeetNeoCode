-- Description display utilities
local vim = vim
local format = require "LeetNeoCode.format"
local images = require "LeetNeoCode.images"

local M = {}

-- Store rendered image info in a global table to avoid duplicates
_G.leetcode_rendered_images = _G.leetcode_rendered_images or {}

-- Helper function to find lines with example headers and separators
local function find_example_sections(lines)
  local sections = {}
  for i, line in ipairs(lines) do
    if line:match "^Example %d+:$" and i < #lines and lines[i + 1]:match "^%-+$" then
      table.insert(sections, { header_line = i, separator_line = i + 1 })
    end
  end
  return sections
end

-- Open problem description buffer
function M.open_description_buffer(problem_data, num, title, slug)
  vim.cmd "enew"
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")

  -- 1) Extract image URLs from the content
  local image_data = images.prepare_image_urls(problem_data.content)

  -- 2) Format text only (no placeholders)
  local formatted = format.format_problem_text(problem_data.content)
  local lines = vim.split(formatted, "\n", { plain = true })

  -- 3) Find example sections
  local example_sections = find_example_sections(lines)

  -- 4) Set up the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "filetype", "text")
  vim.api.nvim_buf_set_option(buf, "spell", false)
  format.setup_highlighting()

  -- Name the buffer
  local opened_count = _G.leetcode_opened[slug] or 1
  local buf_name = string.format("LC%d %s %d", num, title, opened_count)
  if vim.fn.bufnr(buf_name) == -1 then
    vim.api.nvim_buf_set_name(buf, buf_name)
  end

  -- 5) Insert images after example separators
  local rendered = {}
  local win = vim.api.nvim_get_current_win()
  local line_adjustments = 0

  -- Create a unique key for this buffer
  local buffer_key = buf_name

  -- Initialize the rendered images record for this buffer
  _G.leetcode_rendered_images[buffer_key] = {}

  -- Calculate how many images we need to place
  local images_per_example = math.min(#image_data, #example_sections)

  for i = 1, images_per_example do
    local img = image_data[i]
    local section = example_sections[i]

    if img and section then
      -- Calculate the actual line number after previous adjustments
      local separator_line = section.separator_line + line_adjustments

      -- Insert a blank line right after the separator for the image
      vim.api.nvim_buf_set_lines(buf, separator_line, separator_line, false, { "" })
      line_adjustments = line_adjustments + 1

      -- Remember this position for rendering
      table.insert(rendered, {
        row = separator_line,
        url = img.url,
      })

      -- Keep track that we've rendered this image
      _G.leetcode_rendered_images[buffer_key][separator_line] = true

      -- Render the image directly from URL
      images.render_image(buf, win, img.url, separator_line)
    end
  end

  -- 6) Set up autocommand for window focus
  M.setup_rerender_autocmd(buf, rendered, buffer_key)

  return buf
end

-- Setup autocommand for re-rendering images on window focus
function M.setup_rerender_autocmd(buf, rendered, buffer_key)
  local C = require "LeetNeoCode.config"
  local group = "LeetCodeImages_" .. buf
  vim.api.nvim_create_augroup(group, { clear = true })

  vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    group = group,
    buffer = buf,
    callback = function()
      local w = vim.api.nvim_get_current_win()
      -- Only re-render if not already rendered in this session
      if #rendered > 0 then
        vim.defer_fn(function()
          -- clear any cached images for this buffer so they re-render
          for key, _ in pairs(_G.leetcode_image_cache or {}) do
            if key:match("^" .. buf .. "%-") then
              _G.leetcode_image_cache[key] = nil
            end
          end
          for _, entry in ipairs(rendered) do
            if entry.url and _G.leetcode_rendered_images[buffer_key] then
              -- Check if we need to re-render
              local line_content = vim.api.nvim_buf_get_lines(buf, entry.row, entry.row + 1, false)[1]
              if line_content == "" then -- Only render into empty lines
                images.render_image(buf, w, entry.url, entry.row)
              end
            end
          end
        end, C.image_render_delay or 100)
      end
    end,
  })
end

return M
