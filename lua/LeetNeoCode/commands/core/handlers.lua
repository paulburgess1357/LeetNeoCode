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
  elseif arg_parts[1] == "Random" and arg_parts[2] == "Store" then
    -- LC Random Store → Update random solutions
    local random_utils = require "LeetNeoCode.utils.random_solutions"
    return random_utils.update_random_solutions()
  elseif arg_parts[1] == "RandomStore" then
    -- LC RandomStore (backwards compatibility) → Update random solutions
    local random_utils = require "LeetNeoCode.utils.random_solutions"
    return random_utils.update_random_solutions()
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
  elseif arg_parts[1] == "FoldClose" then
    -- LC FoldClose → Close all folds in current buffer
    vim.cmd "normal! zM"
    vim.notify("Closed all folds", vim.log.levels.INFO)
    return
  elseif arg_parts[1] == "FoldOpen" then
    -- LC FoldOpen → Open all folds in current buffer
    vim.cmd "normal! zR"
    vim.notify("Opened all folds", vim.log.levels.INFO)
    return
  elseif arg_parts[1] == "FoldToggle" then
    -- LC FoldToggle → Toggle fold under cursor
    vim.cmd "normal! za"
    vim.notify("Toggled fold", vim.log.levels.INFO)
    return
  elseif arg_parts[1] == "Fold" and arg_parts[2] == "Close" then
    -- LC Fold Close → Close all folds in current buffer (spaced version)
    vim.cmd "normal! zM"
    vim.notify("Closed all folds", vim.log.levels.INFO)
    return
  elseif arg_parts[1] == "Fold" and arg_parts[2] == "Open" then
    -- LC Fold Open → Open all folds in current buffer (spaced version)
    vim.cmd "normal! zR"
    vim.notify("Opened all folds", vim.log.levels.INFO)
    return
  elseif arg_parts[1] == "Fold" and arg_parts[2] == "Toggle" then
    -- LC Fold Toggle → Toggle fold under cursor (spaced version)
    vim.cmd "normal! za"
    vim.notify("Toggled fold", vim.log.levels.INFO)
    return
  elseif tonumber(arg_parts[1]) ~= nil then
    return leetcode.problem.open_problem(arg_parts[1])
  else
    vim.notify("Unknown LC command: " .. args, vim.log.levels.WARN)
  end
end

-- Update the tab completion function to include the new commands
function M.complete_command(argLead, cmdLine)
  local parts = vim.split(vim.fn.trim(cmdLine), "%s+")

  -- If we're completing the first argument after LC
  if #parts <= 1 or (parts[1] == "LC" and #parts == 2 and argLead ~= "") then
    return { "Pull", "Copy", "Recent", "RecentStore", "RecentList", "Random", "RandomStore", "Dismiss", "Keywords", "FoldClose", "FoldOpen", "FoldToggle", "Fold" }
  end

  -- If we typed "LC Recent " and are completing the second argument
  if parts[1] == "LC" and parts[2] == "Recent" and #parts == 3 then
    return { "Store", "List" }
  end

  -- If we typed "LC Random " and are completing the second argument
  if parts[1] == "LC" and parts[2] == "Random" and #parts == 3 then
    return { "Store" }
  end

  -- If we typed "LC Fold " and are completing the second argument
  if parts[1] == "LC" and parts[2] == "Fold" and #parts == 3 then
    return { "Close", "Open", "Toggle" }
  end

  return {}
end

return M
