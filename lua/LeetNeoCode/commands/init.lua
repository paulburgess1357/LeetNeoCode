-- Command registration module for LeetNeoCode
local M = {}
local register = require "LeetNeoCode.commands.core.register"
local handlers = require "LeetNeoCode.commands.core.handlers"

-- Setup all commands
function M.setup(leetcode)
  -- Define command functions
  _G.leetcode_commands = _G.leetcode_commands or {}

  -- LC Pull → full pull & cache
  _G.leetcode_commands.pull = function()
    leetcode.pull.pull_problems()
  end

  -- LC <number> → open starter code from cache
  _G.leetcode_commands.problem = function(number)
    leetcode.problem.open_problem(number)
  end

  -- Register the LC command using the Lua API
  register.register_command("LC", function(opts)
    -- Show notification
    local win, buf = register.command_notification "Running Leetcode Command..."

    -- Process the command
    vim.schedule(function()
      handlers.execute_command(leetcode, opts.args)
    end)
  end, {
    desc = "LeetCode command for various operations",
    nargs = "+",
    complete = handlers.complete_command,
  })

  -- Add no-space versions of commands
  register.register_command("LCPull", function()
    -- Show notification
    local win, buf = register.command_notification "Running Leetcode Pull..."

    -- Call directly
    vim.schedule(function()
      leetcode.pull.pull_problems()
    end)
  end, {
    desc = "Pull LeetCode problems (no space version)",
  })

  register.register_command("LCCopy", function()
    -- Show notification
    local win, buf = register.command_notification "Running Leetcode Copy..."

    -- Call directly
    vim.schedule(function()
      require("LeetNeoCode.utils.leetcode_copy").copy_current_buffer(leetcode.config)
    end)
  end, {
    desc = "Copy LeetCode solution (no space version)",
  })

  -- Add the LCRecent command
  register.register_command("LCRecent", function()
    -- Show notification
    local win, buf = register.command_notification "Finding Recent Solution..."

    -- Call directly
    vim.schedule(function()
      handlers.execute_command(leetcode, "Recent")
    end)
  end, {
    desc = "Open most recent LeetCode solution (no space version)",
  })

  -- Add the new LCRecentStore command
  register.register_command("LCRecentStore", function()
    local win, buf = register.command_notification "Updating Recent Solutions..."
    vim.schedule(function()
      require("LeetNeoCode.utils.recent_solutions").update_recent_solutions()
    end)
  end, {
    desc = "Update recent solutions directory with N most recent problems",
  })

  -- Add the new LCRecentList command
  register.register_command("LCRecentList", function()
    local win, buf = register.command_notification "Showing Recent Solutions..."
    vim.schedule(function()
      handlers.execute_command(leetcode, "RecentList")
    end)
  end, {
    desc = "Show recent solutions as notification",
  })

  -- Add the new LCKeyword command
  register.register_command("LCKeyword", function(opts)
    local win, buf = register.command_notification "Searching for Keywords..."
    vim.schedule(function()
      local keyword_string = opts.args
      if keyword_string and keyword_string ~= "" then
        -- Remove quotes if present
        keyword_string = keyword_string:gsub('^"(.+)"$', "%1"):gsub("^'(.+)'$", "%1")
        require("LeetNeoCode.utils.keyword_search").search_by_keywords(keyword_string)
      else
        vim.notify('Usage: LCKeyword "keyword1, keyword2, ..."', vim.log.levels.WARN)
      end
    end)
  end, {
    desc = "Search LeetCode solutions by keywords",
    nargs = "+",
  })

  -- Add the new LCDismiss command
  register.register_command("LCDismiss", function()
    local win, buf = register.command_notification "Dismissing Notifications..."
    vim.schedule(function()
      handlers.execute_command(leetcode, "Dismiss")
    end)
  end, {
    desc = "Dismiss all active LeetCode notifications",
  })
end

return M
