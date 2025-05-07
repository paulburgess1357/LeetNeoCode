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
end

return M
