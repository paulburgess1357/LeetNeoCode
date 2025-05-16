-- Command handler implementations
local M = {}

-- Execute a Leetcode command with the given leetcode module
function M.execute_command(leetcode, args)
  local arg_parts = {}
  for part in string.gmatch(args, "%S+") do
    table.insert(arg_parts, part)
  end

  if arg_parts[1] == "Pull" then
    return leetcode.pull.pull_problems()
  elseif arg_parts[1] == "Copy" then
    return require("LeetNeoCode.utils.leetcode_copy").copy_current_buffer(leetcode.config)
  elseif arg_parts[1] == "Recent" then
    -- Find and open the most recent solution file
    local file_utils = require "LeetNeoCode.utils.file.operations"
    local recent_file, err = file_utils.find_most_recent_solution(leetcode.config)

    if not recent_file then
      vim.notify("No recent solution found: " .. (err or "Unknown error"), vim.log.levels.WARN)
      return
    end

    -- Simply open the file directly in a new tab
    vim.cmd("tabnew " .. vim.fn.fnameescape(recent_file))

    vim.notify("Opened most recent solution: " .. vim.fn.fnamemodify(recent_file, ":t"), vim.log.levels.INFO)
    return
  elseif tonumber(arg_parts[1]) ~= nil then
    return leetcode.problem.open_problem(arg_parts[1])
  else
    vim.notify("Unknown LC command: " .. args, vim.log.levels.WARN)
  end
end

-- Update the tab completion function to include the new command
function M.complete_command(argLead, cmdLine)
  local parts = vim.split(vim.fn.trim(cmdLine), "%s+")
  if #parts <= 1 or (parts[1] == "LC" and #parts == 2 and argLead ~= "") then
    return { "Pull", "Copy", "Recent" } -- Add "Recent" to completion options
  end
  return {}
end

return M
