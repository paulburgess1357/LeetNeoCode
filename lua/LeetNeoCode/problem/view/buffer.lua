-- Buffer utilities for problem view
local vim = vim
local C = require "LeetNeoCode.config"

local M = {}

-- Open solution buffer in a split
function M.open_solution_buffer(fpath)
  vim.cmd("vsplit " .. vim.fn.fnameescape(fpath))
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_option(buf, "filetype", C.default_language)
  vim.cmd "setlocal foldmethod=marker"

  -- Set nofoldenable temporarily to prevent flicker
  vim.cmd "setlocal nofoldenable"

  -- Defer folding with slightly longer delay
  vim.defer_fn(function()
    -- Clear any cached images for this buffer so they re-render
    for key, _ in pairs(_G.leetcode_image_cache or {}) do
      if key:match("^" .. buf .. "%-") then
        _G.leetcode_image_cache[key] = nil
      end
    end

    -- Enable folding and close all folds
    vim.cmd "setlocal foldenable"
    vim.cmd "normal! zM"
  end, 10) -- 10ms delay

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
