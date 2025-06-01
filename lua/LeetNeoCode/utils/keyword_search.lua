-- Keyword search utilities for LeetCode solutions
local M = {}
local C = require "LeetNeoCode.config"

-- Get the keyword search directory path
function M.get_keyword_dir()
  return C.cache_dir .. "/" .. "solutions_keywords"
end

-- Get the main solutions directory path
function M.get_solutions_dir()
  return C.cache_dir .. "/" .. C.solutions_subdir
end

-- Ensure keyword search directory exists
function M.ensure_keyword_dir()
  local keyword_dir = M.get_keyword_dir()
  if vim.fn.isdirectory(keyword_dir) == 0 then
    vim.fn.mkdir(keyword_dir, "p")
    vim.notify("Created keyword search directory: " .. keyword_dir, vim.log.levels.INFO)
  end
  return keyword_dir
end

-- Clear the keyword search directory
function M.clear_keyword_dir()
  local keyword_dir = M.get_keyword_dir()
  if vim.fn.isdirectory(keyword_dir) == 1 then
    -- Remove all contents (symlinks and any files)
    local items = vim.fn.glob(keyword_dir .. "/*", false, true)
    for _, item in ipairs(items) do
      vim.fn.delete(item, "rf") -- recursive force delete
    end
  end
end

-- Parse comma-delimited keywords from input string
function M.parse_keywords(input)
  if not input or input == "" then
    return {}
  end

  local keywords = {}
  for keyword in input:gmatch("([^,]+)") do
    local trimmed = keyword:match("^%s*(.-)%s*$") -- trim whitespace
    if trimmed and trimmed ~= "" then
      table.insert(keywords, trimmed:lower()) -- convert to lowercase
    end
  end

  return keywords
end

-- Search for keywords in a file (case-insensitive)
function M.search_file_for_keywords(file_path, keywords)
  local file = io.open(file_path, "r")
  if not file then
    return false
  end

  local content = file:read("*all"):lower() -- convert file content to lowercase
  file:close()

  -- Check if any keyword is found in the file
  for _, keyword in ipairs(keywords) do
    if content:find(keyword, 1, true) then -- plain text search, case-insensitive
      return true
    end
  end

  return false
end

-- Search a solution directory for keywords
function M.search_directory_for_keywords(dir_path, keywords)
  -- Get all files in the directory (not subdirectories)
  local files = vim.fn.glob(dir_path .. "/*", false, true)

  for _, file_path in ipairs(files) do
    -- Only search regular files, not directories
    if vim.fn.isdirectory(file_path) == 0 then
      -- Skip hidden files (files starting with .)
      local filename = vim.fn.fnamemodify(file_path, ":t")
      if not filename:match("^%.") then
        if M.search_file_for_keywords(file_path, keywords) then
          return true -- Found at least one keyword, stop searching this directory
        end
      end
    end
  end

  return false
end

-- Get all solution directories (zero-padded format)
function M.get_all_solution_dirs()
  local solutions_dir = M.get_solutions_dir()

  if vim.fn.isdirectory(solutions_dir) == 0 then
    vim.notify("No solutions directory found", vim.log.levels.WARN)
    return {}
  end

  -- Find all LC directories with zero-padded format
  local pattern = solutions_dir .. "/LC[0-9][0-9][0-9][0-9][0-9]_*"
  local dirs = vim.fn.glob(pattern, false, true)

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

-- Main function to search for keywords and create symlinks
function M.search_by_keywords(keyword_string)
  if not keyword_string or keyword_string == "" then
    vim.notify("No keywords provided", vim.log.levels.WARN)
    return false
  end

  -- Parse keywords
  local keywords = M.parse_keywords(keyword_string)
  if #keywords == 0 then
    vim.notify("No valid keywords found", vim.log.levels.WARN)
    return false
  end

  vim.notify("Searching for keywords: " .. table.concat(keywords, ", "), vim.log.levels.INFO)

  -- Ensure keyword directory exists and clear it
  M.ensure_keyword_dir()
  M.clear_keyword_dir()

  -- Get all solution directories
  local solution_dirs = M.get_all_solution_dirs()
  if #solution_dirs == 0 then
    vim.notify("No solution directories found", vim.log.levels.WARN)
    return false
  end

  -- Search each directory for keywords
  local keyword_dir = M.get_keyword_dir()
  local matched_count = 0

  for _, src_dir in ipairs(solution_dirs) do
    if M.search_directory_for_keywords(src_dir, keywords) then
      local dir_name = vim.fn.fnamemodify(src_dir, ":t") -- get just the directory name
      local dst_path = keyword_dir .. "/" .. dir_name

      if M.create_symlink(src_dir, dst_path) then
        matched_count = matched_count + 1
      else
        vim.notify("Failed to create symlink for: " .. dir_name, vim.log.levels.ERROR)
      end
    end
  end

  if matched_count > 0 then
    vim.notify(
      string.format("Found %d solution%s matching keywords in %s",
        matched_count,
        matched_count == 1 and "" or "s",
        keyword_dir
      ),
      vim.log.levels.INFO
    )
    return true
  else
    vim.notify("No solutions found matching the specified keywords", vim.log.levels.WARN)
    return false
  end
end

return M
