-- Stats module (main interface for LeetCode user statistics)
local M = {}

-- Import submodules
M.api = require "LeetNeoCode.stats.api.fetcher"
M.display = require "LeetNeoCode.stats.display.formatter"
M.core = require "LeetNeoCode.stats.core.processor"

-- Main function to fetch and display user stats
function M.fetch_user_stats(username)
  if not username or username == "" then
    vim.notify("❌ Please provide a username: LC Stats <username>", vim.log.levels.WARN)
    return false
  end

  vim.notify("🔍 Fetching stats for " .. username .. "...", vim.log.levels.INFO)

  -- Fetch user data from LeetCode API
  local user_data, err = M.api.fetch_user_data(username)
  if not user_data then
    vim.notify("❌ Failed to fetch stats for " .. username .. ": " .. (err or "Unknown error"), vim.log.levels.ERROR)
    return false
  end

  -- Process the raw data into displayable stats
  local success, processed_stats = pcall(M.core.process_user_data, user_data)
  if not success then
    vim.notify("❌ Error processing stats data: " .. tostring(processed_stats), vim.log.levels.ERROR)
    return false
  end

  -- Display the stats in a beautiful notification
  local display_success, display_error = pcall(M.display.show_stats_notification, username, processed_stats)
  if not display_success then
    vim.notify("❌ Error displaying stats: " .. tostring(display_error), vim.log.levels.ERROR)
    return false
  end

  return true
end

return M
