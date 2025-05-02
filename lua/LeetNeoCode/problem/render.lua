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
function M.open_problem_view(problem_data, snippets, fpath, num, title, slug)
  vim.cmd "tabnew"
  if problem_data.content ~= "" then
    M.open_description_buffer(problem_data, num, title, slug)
  end
  if snippets and fpath then
    M.open_solution_buffer(fpath)
    M.setup_split_layout()
  end
end

return M
