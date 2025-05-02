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
  elseif tonumber(arg_parts[1]) ~= nil then
    return leetcode.problem.open_problem(arg_parts[1])
  else
    vim.notify("Unknown LC command: " .. args, vim.log.levels.WARN)
  end
end

-- Tab completion for LC command
function M.complete_command(argLead, cmdLine)
  local parts = vim.split(vim.fn.trim(cmdLine), "%s+")
  if #parts <= 1 or (parts[1] == "LC" and #parts == 2 and argLead ~= "") then
    return { "Pull" }
  end
  return {}
end

return M
