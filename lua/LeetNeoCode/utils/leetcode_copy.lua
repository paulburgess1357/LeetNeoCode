-- Advanced copy utilities specifically for LeetCode solutions
local M = {}
local clipboard = require "LeetNeoCode.utils.clipboard"

-- highlight namespace and group for flash
local HIGHLIGHT_NS = vim.api.nvim_create_namespace "LeetNeoCodeCopyFlash"
local HIGHLIGHT_GROUP = "LeetNeoCodeCopyFlashGroup"

-- Setup highlight group
function M.setup_highlights(config)
  -- Define the highlight group based on config
  vim.api.nvim_set_hl(0, HIGHLIGHT_GROUP, config.custom_copy_color and { bg = config.custom_copy_color } or {})
end

-- Process the content of code before copying (remove headers, metadata, etc.)
function M.process_content(lines, config)
  if #lines == 0 then return {} end

  -- Get fold markers
  local start_marker = config.fold_marker_start or "▼"
  local end_marker = config.fold_marker_end or "▲"

  local out, skipping, saw_fold = {}, false, false

  for i, line in ipairs(lines) do
    if i == 1 and (
      line:match "^#include" or
      line:match "^import" or
      line:match "^from" or
      line:match "^package" or
      line:match "^mod " or
      line:match "^using "
    ) then
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
  if not saw_fold then
    local buf0 = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    if buf0:match "^#include" or
       buf0:match "^import" or
       buf0:match "^from" or
       buf0:match "^package" or
       buf0:match "^mod " or
       buf0:match "^using " then
      if out[1] == "" then
        table.remove(out, 1)
      end
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
    clear_cmdline = true
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

-- Setup the custom yank behavior for LeetCode solution files
function M.setup(config)
  if not config.custom_copy then
    return
  end

  -- Setup highlight group
  M.setup_highlights(config)

  -- Define the buffer pattern for LeetCode solutions
  local sol = config.cache_dir .. "/" .. config.solutions_subdir
  local pattern = vim.fn.escape(sol, "\\") .. "/**/*.{cpp,py,java,js,go,rs,swift,cs}"

  -- Create the autocommand group
  vim.api.nvim_create_augroup("LeetCodeCustomCopy", { clear = true })

  -- Setup autocommands for solution files
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = "LeetCodeCustomCopy",
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
    end,
  })
end

return M
