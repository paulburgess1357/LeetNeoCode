-- Clipboard handling utilities
local M = {}

-- Helper to emit OSC-52 over stdout for remote clipboard support
function M.set_clipboard(text)
  local b64 = vim.fn.system({ "base64" }, text):gsub("\n", "")
  local osc = string.format("\027]52;c;%s\007", b64)
  vim.api.nvim_out_write(osc)
end

-- Copy text to clipboard with visual feedback
function M.copy_with_feedback(text, flash_opts)
  -- Copy to clipboard registers
  vim.fn.setreg('"', text)
  vim.fn.setreg("+", text)

  -- Use OSC-52 for remote terminal clipboard support
  M.set_clipboard(text)

  -- Flash highlight if options provided
  if flash_opts and flash_opts.highlight_ns and flash_opts.highlight_group then
    if flash_opts.s_line and flash_opts.e_line then
      M.flash_region(
        flash_opts.s_line,
        flash_opts.s_col or 0,
        flash_opts.e_line,
        flash_opts.e_col or -1,
        flash_opts.highlight_ns,
        flash_opts.highlight_group,
        flash_opts.duration or 200
      )
    end
  end

  -- Show notification if requested
  if flash_opts and flash_opts.notify_message then
    vim.notify(flash_opts.notify_message, flash_opts.notify_level or vim.log.levels.INFO,
      { timeout = flash_opts.notify_timeout or 500 })
  end

  -- Clear command line if requested
  if flash_opts and flash_opts.clear_cmdline then
    vim.api.nvim_feedkeys(":<C-u>", "nx", false)
  end

  return true
end

-- Flash highlight a region
function M.flash_region(s_line, s_col, e_line, e_col, highlight_ns, highlight_group, duration)
  for ln = s_line - 1, e_line - 1 do
    local start_col = (ln == s_line - 1) and s_col or 0
    local end_col = (ln == e_line - 1) and (e_col + 1) or -1
    vim.api.nvim_buf_add_highlight(0, highlight_ns, highlight_group, ln, start_col, end_col)
  end

  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(0, highlight_ns, 0, -1)
  end, duration or 200)
end

return M
