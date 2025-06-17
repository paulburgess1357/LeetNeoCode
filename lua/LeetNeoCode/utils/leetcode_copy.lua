-- Advanced copy utilities specifically for LeetCode solutions
local M = {}
local clipboard = require "LeetNeoCode.utils.clipboard"

-- highlight namespace and group for flash
local HIGHLIGHT_NS = vim.api.nvim_create_namespace "LeetNeoCodeCopyFlash"
local HIGHLIGHT_GROUP = "LeetNeoCodeCopyFlashGroup"

-- Setup highlight group
function M.setup_highlights(config)
  -- Define the highlight group based on config
  vim.api.nvim_set_hl(0, HIGHLIGHT_GROUP, config.smart_copy_color and { bg = config.smart_copy_color } or {})
end

-- Process the content of code before copying (remove headers, metadata, etc.)
function M.process_content(lines, config)
  if #lines == 0 then
    return {}
  end

  -- Get fold markers
  local start_marker = config.fold_marker_start or "▼"
  local end_marker = config.fold_marker_end or "▲"

  local out, skipping, saw_fold = {}, false, false

  -- If copying a small section, just return it directly
  if #lines <= 3 then
    return lines
  end

  -- For larger selections, apply filtering
  -- Check if the selection contains headers/imports
  local has_header = false
  for i, line in ipairs(lines) do
    if
      i == 1
      and (
        line:match "^#include"
        or line:match "^import"
        or line:match "^from"
        or line:match "^package"
        or line:match "^mod "
        or line:match "^using "
      )
    then
      has_header = true
      break
    end
  end

  -- If no header detected and not copying the whole buffer, don't filter
  if not has_header and #lines < 20 then
    return lines
  end

  -- Apply filtering for full buffer or sections with headers
  for i, line in ipairs(lines) do
    if
      i == 1
      and (
        line:match "^#include"
        or line:match "^import"
        or line:match "^from"
        or line:match "^package"
        or line:match "^mod "
        or line:match "^using "
      )
    then
      -- Skip top header
    elseif line:find(start_marker, 1, true) then
      skipping, saw_fold = true, true
    elseif line:find(end_marker, 1, true) then
      skipping = false
    elseif not skipping then
      table.insert(out, line)
    end
  end

  -- If no folds but header existed, drop leading blank
  if has_header and not saw_fold then
    if #out > 0 and out[1] == "" then
      table.remove(out, 1)
    end
  end

  return out
end

-- Core function: copy region with LeetCode-specific processing
function M.copy_region(s_line, s_col, e_line, e_col, config)
  local lines = vim.api.nvim_buf_get_lines(0, s_line - 1, e_line, false)

  -- Trim selection bounds
  if #lines > 0 then
    if #lines == 1 then
      lines[1] = lines[1]:sub(s_col + 1, e_col + 1)
    else
      lines[1] = lines[1]:sub(s_col + 1)
      lines[#lines] = lines[#lines]:sub(1, e_col + 1)
    end
  end

  -- Process content (remove headers, metadata)
  local processed = M.process_content(lines, config)
  local txt = table.concat(processed, "\n")

  -- Copy to clipboard with visual feedback
  clipboard.copy_with_feedback(txt, {
    s_line = s_line,
    s_col = s_col,
    e_line = e_line,
    e_col = e_col,
    highlight_ns = HIGHLIGHT_NS,
    highlight_group = HIGHLIGHT_GROUP,
    notify_message = "🧩 LeetCode Smart Copy ✓",
    notify_level = vim.log.levels.DEBUG,
    notify_timeout = 500,
    clear_cmdline = true,
  })
end

-- Called on visual-mode <y>
function M.custom_yank(config)
  local s_line, s_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
  local e_line, e_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))
  M.copy_region(s_line, s_col, e_line, e_col, config)
end

-- operatorfunc handler for normal-mode y{motion}
function M.yank_operator(config)
  local start = vim.api.nvim_buf_get_mark(0, "[")
  local finish = vim.api.nvim_buf_get_mark(0, "]")
  M.copy_region(start[1], start[2], finish[1], finish[2], config)
end

-- Yank the current line
function M.yank_line(config)
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]

  -- Process the lines (filter it through our handler)
  local processed = M.process_content({ line }, config)
  local txt = table.concat(processed, "\n")

  -- Copy to clipboard with visual feedback
  clipboard.copy_with_feedback(txt, {
    s_line = line_num,
    e_line = line_num,
    highlight_ns = HIGHLIGHT_NS,
    highlight_group = HIGHLIGHT_GROUP,
    notify_message = "🧩 LeetCode Smart Copy ✓",
    notify_level = vim.log.levels.DEBUG,
    notify_timeout = 500,
    clear_cmdline = true,
  })
end

-- Yank from cursor to end of line (Y)
function M.yank_to_end(config)
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
  local text = line:sub(col + 1)

  -- Process the text (filter it through our handler)
  local processed = M.process_content({ text }, config)
  local txt = table.concat(processed, "\n")

  -- Copy to clipboard with visual feedback
  clipboard.copy_with_feedback(txt, {
    s_line = line_num,
    s_col = col,
    e_line = line_num,
    e_col = #line,
    highlight_ns = HIGHLIGHT_NS,
    highlight_group = HIGHLIGHT_GROUP,
    notify_message = "🧩 LeetCode Smart Copy ✓",
    notify_level = vim.log.levels.DEBUG,
    notify_timeout = 500,
    clear_cmdline = true,
  })
end

-- Copy the contents of the current buffer with LeetCode-specific processing
function M.copy_current_buffer(config)
  -- Get current buffer
  local buf = vim.api.nvim_get_current_buf()

  -- Get all lines from the buffer
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  -- Process content (remove headers, metadata)
  local processed = M.process_content(lines, config)
  local txt = table.concat(processed, "\n")

  -- Get the total line count for highlighting the full buffer
  local line_count = vim.api.nvim_buf_line_count(buf)

  -- Copy to clipboard with visual feedback
  return clipboard.copy_with_feedback(txt, {
    s_line = 1,
    s_col = 0,
    e_line = line_count,
    e_col = #(vim.api.nvim_buf_get_lines(buf, line_count - 1, line_count, false)[1] or ""),
    highlight_ns = HIGHLIGHT_NS,
    highlight_group = HIGHLIGHT_GROUP,
    notify_message = "🧩 LeetCode Smart Copy ✓",
    notify_level = vim.log.levels.INFO,
    notify_timeout = 1000,
  })
end

-- Setup the custom yank behavior for LeetCode solution files
function M.setup(config)
  -- Setup highlight group (always, not just when smart_copy is true)
  M.setup_highlights(config)

  -- Always register the LC Copy command
  vim.api.nvim_create_user_command("LCCopy", function()
    M.copy_current_buffer(config)
  end, {})

  -- Only override yank operations if smart_copy is true
  if config.smart_copy then
    -- Define the buffer pattern for LeetCode solutions (zero-padded format only)
    local sol = config.cache_dir .. "/" .. config.solutions_subdir
    local pattern = vim.fn.escape(sol, "\\") .. "/**/LC[0-9][0-9][0-9][0-9][0-9]_*.{cpp,py,java,js,go,rs,swift,cs}"

    -- Create the autocommand group
    vim.api.nvim_create_augroup("LeetCodeSmartCopy", { clear = true })

    -- Setup autocommands for solution files
    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
      group = "LeetCodeSmartCopy",
      pattern = pattern,
      callback = function()
        -- Normal mode: y{motion}
        vim.api.nvim_buf_set_keymap(
          0,
          "n",
          "y",
          "<cmd>set operatorfunc=v:lua.require'LeetNeoCode.utils.leetcode_copy'.yank_operator<CR>g@",
          { noremap = true, silent = true }
        )

        -- Visual mode: y
        vim.api.nvim_buf_set_keymap(
          0,
          "x",
          "y",
          "<cmd>lua require('LeetNeoCode.utils.leetcode_copy').custom_yank(require('LeetNeoCode.config'))<CR>",
          { noremap = true, silent = true }
        )

        -- Normal mode: yy (yank line)
        vim.api.nvim_buf_set_keymap(
          0,
          "n",
          "yy",
          "<cmd>lua require('LeetNeoCode.utils.leetcode_copy').yank_line(require('LeetNeoCode.config'))<CR>",
          { noremap = true, silent = true }
        )

        -- Add other common yank mappings
        vim.api.nvim_buf_set_keymap(
          0,
          "n",
          "Y",
          "<cmd>lua require('LeetNeoCode.utils.leetcode_copy').yank_to_end(require('LeetNeoCode.config'))<CR>",
          { noremap = true, silent = true }
        )
      end,
    })
  end
end

return M
