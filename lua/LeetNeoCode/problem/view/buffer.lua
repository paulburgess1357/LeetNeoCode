-- Buffer utilities for problem view
local vim = vim
local C = require "LeetNeoCode.config"

local M = {}

-- Open solution buffer in a split
function M.open_solution_buffer(fpath)
  vim.cmd("vsplit " .. vim.fn.fnameescape(fpath))
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_option(buf, "filetype", C.default_language)

  -- Set up folding immediately
  vim.cmd "setlocal foldmethod=marker"
  vim.cmd "setlocal foldenable"

  -- Set fold markers
  local fold_start = C.fold_marker_start or "▼"
  local fold_end = C.fold_marker_end or "▲"
  vim.cmd("setlocal foldmarker=" .. fold_start .. "," .. fold_end)

  -- Close all folds immediately
  vim.cmd "normal! zM"

  return buf
end

-- Adjust split layout
function M.setup_split_layout()
  local frac = C.description_split or 0.5
  local total = vim.o.columns
  local desc_w = math.floor(total * frac)
  local cur_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local desc_win = (wins[1] == cur_win) and wins[2] or wins[1]
  vim.api.nvim_win_set_width(desc_win, desc_w)
end

return M
