-- Recent solutions management utilities
local M = {}
local C = require "LeetNeoCode.config"

-- Get the recent solutions directory path
function M.get_recent_dir()
  return C.cache_dir .. "/" .. C.solutions_recent_subdir
end

-- Get the main solutions directory path
function M.get_solutions_dir()
  return C.cache_dir .. "/" .. C.solutions_subdir
end

-- Ensure recent solutions directory exists
function M.ensure_recent_dir()
  local recent_dir = M.get_recent_dir()
  if vim.fn.isdirectory(recent_dir) == 0 then
    vim.fn.mkdir(recent_dir, "p")
    vim.notify("Created recent solutions directory: " .. recent_dir, vim.log.levels.INFO)
  end
  return recent_dir
end

-- Clear the recent solutions directory
function M.clear_recent_dir()
  local recent_dir = M.get_recent_dir()
  if vim.fn.isdirectory(recent_dir) == 1 then
    -- Remove all contents (symlinks and any files)
    local items = vim.fn.glob(recent_dir .. "/*", false, true)
    for _, item in ipairs(items) do
      vim.fn.delete(item, "rf") -- recursive force delete
    end
    vim.notify("Cleared recent solutions directory", vim.log.levels.INFO)
  end
end

-- Get all solution directories sorted by modification time (most recent first)
function M.get_recent_solution_dirs()
  local solutions_dir = M.get_solutions_dir()

  if vim.fn.isdirectory(solutions_dir) == 0 then
    vim.notify("No solutions directory found", vim.log.levels.WARN)
    return {}
  end

  -- Find all LC directories with zero-padded format
  local pattern = solutions_dir .. "/LC[0-9][0-9][0-9][0-9][0-9]_*"
  local dirs = vim.fn.glob(pattern, false, true)

  if #dirs == 0 then
    vim.notify("No solution directories found", vim.log.levels.WARN)
    return {}
  end

  -- Sort by modification time (most recent first)
  table.sort(dirs, function(a, b)
    local time_a = vim.fn.getftime(a)
    local time_b = vim.fn.getftime(b)
    return time_a > time_b
  end)

  return dirs
end

-- Create a symlink to a directory
function M.create_symlink(src, dst)
  -- Use absolute paths for reliable symlinks
  local abs_src = vim.fn.fnamemodify(src, ":p")
  local abs_dst = vim.fn.fnamemodify(dst, ":p")

  -- Remove existing symlink/file if it exists
  if vim.fn.filereadable(abs_dst) == 1 or vim.fn.isdirectory(abs_dst) == 1 then
    vim.fn.delete(abs_dst, "rf")
  end

  -- Create symlink using shell command
  local escaped_src = vim.fn.shellescape(abs_src)
  local escaped_dst = vim.fn.shellescape(abs_dst)
  local cmd = string.format("ln -sf %s %s", escaped_src, escaped_dst)
  local result = os.execute(cmd)

  if result ~= 0 then
    vim.notify("Failed to create symlink: " .. abs_src .. " -> " .. abs_dst, vim.log.levels.ERROR)
    return false
  end

  return true
end

-- Update the recent solutions directory with N most recent folders (using symlinks)
function M.update_recent_solutions()
  local count = C.recent_solutions_count or 10

  vim.notify("Updating recent solutions with symlinks (" .. count .. " most recent)...", vim.log.levels.INFO)

  -- Ensure recent directory exists and clear it
  M.ensure_recent_dir()
  M.clear_recent_dir()

  -- Get recent solution directories
  local recent_dirs = M.get_recent_solution_dirs()

  if #recent_dirs == 0 then
    vim.notify("No solution directories to link", vim.log.levels.WARN)
    return false
  end

  -- Create symlinks to the N most recent directories
  local recent_dir = M.get_recent_dir()
  local linked_count = 0

  for i = 1, math.min(count, #recent_dirs) do
    local src_dir = recent_dirs[i]
    local dir_name = vim.fn.fnamemodify(src_dir, ":t") -- get just the directory name
    local dst_path = recent_dir .. "/" .. dir_name

    if M.create_symlink(src_dir, dst_path) then
      linked_count = linked_count + 1
    else
      break -- Stop on first failure
    end
  end

  if linked_count > 0 then
    vim.notify(
      string.format("Successfully created %d symlink%s to recent solution%s in %s",
        linked_count,
        linked_count == 1 and "" or "s",
        linked_count == 1 and "" or "s",
        recent_dir
      ),
      vim.log.levels.INFO
    )
    return true
  else
    vim.notify("Failed to create any symlinks", vim.log.levels.ERROR)
    return false
  end
end

-- Get a list of recent solution info for display
function M.get_recent_solutions_info()
  local recent_dirs = M.get_recent_solution_dirs()
  local count = C.recent_solutions_count or 10
  local info = {}

  for i = 1, math.min(count, #recent_dirs) do
    local dir = recent_dirs[i]
    local dir_name = vim.fn.fnamemodify(dir, ":t")
    local mtime = vim.fn.getftime(dir)
    local time_str = os.date("%Y-%m-%d %H:%M:%S", mtime)

    -- Extract problem number and title from directory name
    local problem_num, title = dir_name:match("^LC(%d+)_(.+)$")
    if problem_num and title then
      title = title:gsub("_", " ") -- Convert underscores back to spaces
    end

    table.insert(info, {
      dir_name = dir_name,
      full_path = dir,
      problem_num = problem_num or "?",
      title = title or "Unknown",
      modified_time = time_str,
      rank = i
    })
  end

  return info
end

-- Display recent solutions as a notification
function M.show_recent_solutions_notification()
  local info = M.get_recent_solutions_info()

  if #info == 0 then
    vim.notify("No recent solutions found", vim.log.levels.WARN)
    return
  end

  -- Build notification lines
  local lines = { "Recent Solutions (most recent first):", string.rep("─", 50) }
  for _, item in ipairs(info) do
    table.insert(lines, string.format(
      "%2d. LC%s - %s (%s)",
      item.rank,
      item.problem_num,
      item.title,
      item.modified_time
    ))
  end

  -- Show persistent notification
  local notify = require "LeetNeoCode.utils.ui.notify"
  local timeout = C.recent_list_notification_timeout or 5000

  return notify.persistent_notification(lines, timeout, true)
end

return M
