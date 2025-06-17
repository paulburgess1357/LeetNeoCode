-- Random solutions management utilities
local M = {}
local C = require "LeetNeoCode.config"

-- Get the random solutions directory path
function M.get_random_dir()
  return C.cache_dir .. "/" .. C.solutions_random_subdir
end

-- Get the main solutions directory path
function M.get_solutions_dir()
  return C.cache_dir .. "/" .. C.solutions_subdir
end

-- Ensure random solutions directory exists
function M.ensure_random_dir()
  local random_dir = M.get_random_dir()
  if vim.fn.isdirectory(random_dir) == 0 then
    vim.fn.mkdir(random_dir, "p")
    vim.notify("Created random solutions directory: " .. random_dir, vim.log.levels.INFO)
  end
  return random_dir
end

-- Clear the random solutions directory
function M.clear_random_dir()
  local random_dir = M.get_random_dir()
  if vim.fn.isdirectory(random_dir) == 1 then
    -- Remove all contents (symlinks and any files)
    local items = vim.fn.glob(random_dir .. "/*", false, true)
    for _, item in ipairs(items) do
      vim.fn.delete(item, "rf") -- recursive force delete
    end
    vim.notify("Cleared random solutions directory", vim.log.levels.INFO)
  end
end

-- Get all solution directories
function M.get_all_solution_dirs()
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

  return dirs
end

-- Shuffle array using Fisher-Yates algorithm
function M.shuffle_array(array)
  local result = vim.deepcopy(array)
  for i = #result, 2, -1 do
    local j = math.random(i)
    result[i], result[j] = result[j], result[i]
  end
  return result
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

-- Update the random solutions directory with N random folders (using symlinks)
function M.update_random_solutions()
  local count = C.random_solutions_count or 10

  vim.notify("Updating random solutions with symlinks (" .. count .. " random)...", vim.log.levels.INFO)

  -- Ensure random directory exists and clear it
  M.ensure_random_dir()
  M.clear_random_dir()

  -- Get all solution directories
  local all_dirs = M.get_all_solution_dirs()

  if #all_dirs == 0 then
    vim.notify("No solution directories to link", vim.log.levels.WARN)
    return false
  end

  -- Shuffle the directories and take the first N
  local shuffled_dirs = M.shuffle_array(all_dirs)
  local selected_count = math.min(count, #shuffled_dirs)

  -- Create symlinks to the N random directories
  local random_dir = M.get_random_dir()
  local linked_count = 0

  for i = 1, selected_count do
    local src_dir = shuffled_dirs[i]
    local dir_name = vim.fn.fnamemodify(src_dir, ":t") -- get just the directory name
    local dst_path = random_dir .. "/" .. dir_name

    if M.create_symlink(src_dir, dst_path) then
      linked_count = linked_count + 1
    else
      break -- Stop on first failure
    end
  end

  if linked_count > 0 then
    vim.notify(
      string.format("Successfully created %d symlink%s to random solution%s in %s",
        linked_count,
        linked_count == 1 and "" or "s",
        linked_count == 1 and "" or "s",
        random_dir
      ),
      vim.log.levels.INFO
    )
    return true
  else
    vim.notify("Failed to create any symlinks", vim.log.levels.ERROR)
    return false
  end
end

return M
