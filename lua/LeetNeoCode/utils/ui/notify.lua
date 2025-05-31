-- UI notification utilities
local M = {}

-- Store references to active notifications for dismissal
_G.leetcode_active_notifications = _G.leetcode_active_notifications or {}

-- Create a floating notification window
function M.floating_notification(message, timeout)
  timeout = timeout or 1000 -- default to 1 second

  -- Create window dimensions
  local width = #message + 4
  local height = 1
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  }

  -- Create buffer and set content
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { message })

  -- Apply highlighting
  local ns_id = vim.api.nvim_create_namespace "leetcode_notification"
  vim.api.nvim_buf_add_highlight(buf, ns_id, "MoreMsg", 0, 0, -1)

  -- Show the floating window
  local win = vim.api.nvim_open_win(buf, false, win_opts)

  -- Close the window after specified timeout
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end, timeout)

  return win, buf
end

-- Create a persistent notification that can be dismissed
function M.persistent_notification(lines, timeout, dismissible)
  timeout = timeout or 5000 -- default to 5 seconds
  dismissible = dismissible == nil and true or dismissible -- default to true

  -- Calculate dimensions based on content
  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(max_width, #line)
  end

  local width = math.min(max_width + 4, math.floor(vim.o.columns * 0.8))
  local height = #lines + (dismissible and 2 or 0) -- extra space for dismiss instruction

  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  }

  -- Create buffer and set content
  local buf = vim.api.nvim_create_buf(false, true)
  local content = vim.deepcopy(lines)

  if dismissible then
    table.insert(content, "")
    table.insert(content, "Press 'q' or <Esc> to dismiss")
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -- Apply highlighting
  local ns_id = vim.api.nvim_create_namespace "leetcode_persistent_notification"
  for i = 1, #lines do
    vim.api.nvim_buf_add_highlight(buf, ns_id, "Normal", i - 1, 0, -1)
  end

  if dismissible then
    vim.api.nvim_buf_add_highlight(buf, ns_id, "Comment", #content - 1, 0, -1)
  end

  -- Show the floating window
  local win = vim.api.nvim_open_win(buf, false, win_opts)

  -- Store reference for dismissal
  local notification_id = tostring(win)
  _G.leetcode_active_notifications[notification_id] = { win = win, buf = buf }

  -- Function to close the notification
  local function close_notification()
    if _G.leetcode_active_notifications[notification_id] then
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
      _G.leetcode_active_notifications[notification_id] = nil
    end
  end

  -- Set up key mappings for dismissal if dismissible
  if dismissible then
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
      noremap = true,
      silent = true,
      callback = close_notification
    })
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
      noremap = true,
      silent = true,
      callback = close_notification
    })

    -- Make the window focusable for key events
    vim.api.nvim_set_current_win(win)
  end

  -- Auto-close after timeout
  local timer = vim.defer_fn(close_notification, timeout)

  return win, buf, close_notification
end

-- Dismiss all active notifications
function M.dismiss_all_notifications()
  for id, notification in pairs(_G.leetcode_active_notifications) do
    if vim.api.nvim_win_is_valid(notification.win) then
      vim.api.nvim_win_close(notification.win, true)
    end
    if vim.api.nvim_buf_is_valid(notification.buf) then
      vim.api.nvim_buf_delete(notification.buf, { force = true })
    end
  end
  _G.leetcode_active_notifications = {}
  vim.notify("Dismissed all LeetCode notifications", vim.log.levels.INFO)
end

-- Show notification for command execution
function M.command_notification(message)
  return M.floating_notification("🧩 " .. message, 1000)
end

return M
