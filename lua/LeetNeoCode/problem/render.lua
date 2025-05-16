-- Problem rendering module (main interface)
local vim = vim
local description = require "LeetNeoCode.problem.view.description"
local buffer = require "LeetNeoCode.problem.view.buffer"

local M = {}

-- Export submodule functions
M.open_description_buffer = description.open_description_buffer
M.open_solution_buffer = buffer.open_solution_buffer
M.setup_split_layout = buffer.setup_split_layout

-- Master open function that coordinates the view setup
function M.open_problem_view(problem_data, snippets, fpath, num, title, slug, code_only)
  -- Create a new tab
  vim.cmd "tabnew"

  if not code_only then
    -- Only open description buffer if not in code_only mode
    if problem_data and problem_data.content and problem_data.content ~= "" then
      M.open_description_buffer(problem_data, num, title, slug)
    end
  end

  -- Open the solution buffer if we have the code
  if snippets and fpath then
    if code_only then
      -- In code_only mode, directly edit the file in the current window
      -- (don't create a new split)
      vim.cmd("edit " .. vim.fn.fnameescape(fpath))
      local buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_option(buf, "filetype", require("LeetNeoCode.config").default_language)
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
    else
      -- Standard mode: create split for code+description
      M.open_solution_buffer(fpath)
      M.setup_split_layout()
    end
  end
end

return M
