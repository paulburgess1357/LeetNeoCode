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
  elseif arg_parts[1] == "Recent" and not arg_parts[2] then
    -- LC Recent (no second argument) → Find and open the most recent solution file
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
  elseif arg_parts[1] == "Recent" and arg_parts[2] == "Store" then
    -- LC Recent Store → Update recent solutions
    local recent_utils = require "LeetNeoCode.utils.recent_solutions"
    return recent_utils.update_recent_solutions()
  elseif arg_parts[1] == "Recent" and arg_parts[2] == "List" then
    -- LC Recent List → List recent solutions info
    local recent_utils = require "LeetNeoCode.utils.recent_solutions"
    local info = recent_utils.get_recent_solutions_info()

    if #info == 0 then
      vim.notify("No recent solutions found", vim.log.levels.WARN)
      return
    end

    -- Display the information
    local lines = { "Recent Solutions (most recent first):", string.rep("-", 50) }
    for _, item in ipairs(info) do
      table.insert(lines, string.format(
        "%2d. LC%s - %s (%s)",
        item.rank,
        item.problem_num,
        item.title,
        item.modified_time
      ))
    end

    -- Create a new buffer to display the information
    vim.cmd("tabnew")
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_name(buf, "Recent Solutions")

    return
  elseif arg_parts[1] == "RecentStore" then
    -- LC RecentStore (backwards compatibility) → Update recent solutions
    local recent_utils = require "LeetNeoCode.utils.recent_solutions"
    return recent_utils.update_recent_solutions()
  elseif arg_parts[1] == "RecentList" then
    -- LC RecentList (backwards compatibility) → List recent solutions info
    local recent_utils = require "LeetNeoCode.utils.recent_solutions"
    local info = recent_utils.get_recent_solutions_info()

    if #info == 0 then
      vim.notify("No recent solutions found", vim.log.levels.WARN)
      return
    end

    -- Display the information
    local lines = { "Recent Solutions (most recent first):", string.rep("-", 50) }
    for _, item in ipairs(info) do
      table.insert(lines, string.format(
        "%2d. LC%s - %s (%s)",
        item.rank,
        item.problem_num,
        item.title,
        item.modified_time
      ))
    end

    -- Create a new buffer to display the information
    vim.cmd("tabnew")
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_name(buf, "Recent Solutions")

    return
  elseif tonumber(arg_parts[1]) ~= nil then
    return leetcode.problem.open_problem(arg_parts[1])
  else
    vim.notify("Unknown LC command: " .. args, vim.log.levels.WARN)
  end
end

-- Update the tab completion function to include the new commands with better completion
function M.complete_command(argLead, cmdLine)
  local parts = vim.split(vim.fn.trim(cmdLine), "%s+")

  -- If we're completing the first argument after LC
  if #parts <= 1 or (parts[1] == "LC" and #parts == 2 and argLead ~= "") then
    return { "Pull", "Copy", "Recent", "RecentStore", "RecentList" }
  end

  -- If we typed "LC Recent " and are completing the second argument
  if parts[1] == "LC" and parts[2] == "Recent" and #parts == 3 then
    return { "Store", "List" }
  end

  return {}
end

return M
