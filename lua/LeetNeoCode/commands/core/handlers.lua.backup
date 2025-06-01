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
    -- LC Recent List → Show recent solutions notification
    local recent_utils = require "LeetNeoCode.utils.recent_solutions"
    return recent_utils.show_recent_solutions_notification()
  elseif arg_parts[1] == "RecentStore" then
    -- LC RecentStore (backwards compatibility) → Update recent solutions
    local recent_utils = require "LeetNeoCode.utils.recent_solutions"
    return recent_utils.update_recent_solutions()
  elseif arg_parts[1] == "RecentList" then
    -- LC RecentList (backwards compatibility) → Show recent solutions notification
    local recent_utils = require "LeetNeoCode.utils.recent_solutions"
    return recent_utils.show_recent_solutions_notification()
  elseif arg_parts[1] == "Keywords" then
    -- LC Keywords "keywords" → Search for keywords
    local keyword_string = args:match("Keywords%s+(.+)$")
    if keyword_string then
      -- Remove quotes if present
      keyword_string = keyword_string:gsub('^"(.+)"$', "%1"):gsub("^'(.+)'$", "%1")
      local keyword_utils = require "LeetNeoCode.utils.keyword_search"
      return keyword_utils.search_by_keywords(keyword_string)
    else
      vim.notify('Usage: LC Keywords "keyword1, keyword2, ..."', vim.log.levels.WARN)
    end
  elseif arg_parts[1] == "Dismiss" then
    -- LC Dismiss → Dismiss all active notifications
    local notify_utils = require "LeetNeoCode.utils.ui.notify"
    return notify_utils.dismiss_all_notifications()
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
    return { "Pull", "Copy", "Recent", "RecentStore", "RecentList", "Dismiss", "Keywords" }
  end

  -- If we typed "LC Recent " and are completing the second argument
  if parts[1] == "LC" and parts[2] == "Recent" and #parts == 3 then
    return { "Store", "List" }
  end

  return {}
end

return M
