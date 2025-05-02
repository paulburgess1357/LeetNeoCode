-- Command registration functionality
local M = {}
local notify = require "LeetNeoCode.utils.ui.notify"

-- Register a command in the global space
function M.register_command(name, callback, opts)
  vim.api.nvim_create_user_command(name, callback, opts or {})
end

-- Create command notification window
function M.command_notification(message)
  local win, buf = notify.command_notification(message)
  return win, buf
end

return M
