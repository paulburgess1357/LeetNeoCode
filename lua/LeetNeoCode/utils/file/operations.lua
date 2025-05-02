-- File operations utility module
local M = {}

-- Create a directory if it doesn't exist
function M.ensure_directory(dir_path)
  if vim.fn.isdirectory(dir_path) == 0 then
    vim.fn.mkdir(dir_path, "p")
    return true
  end
  return false
end

-- Create a symlink or copy a file
function M.create_symlink_or_copy(src, dst)
  -- Check if source file exists
  if vim.fn.filereadable(src) == 1 then
    -- Remove existing file if it exists
    if vim.fn.filereadable(dst) == 1 then
      vim.fn.delete(dst)
    end

    -- Create an absolute symlink using direct shell command
    local escaped_src = vim.fn.shellescape(src)
    local escaped_dst = vim.fn.shellescape(dst)
    local cmd = string.format("ln -sf %s %s", escaped_src, escaped_dst)
    local success, err, code = os.execute(cmd)

    if not success then
      vim.notify("Failed to create symlink: " .. (err or "Unknown error"), vim.log.levels.WARN)

      -- Fallback to direct copy
      local content = vim.fn.readfile(src)
      local write_ok = pcall(vim.fn.writefile, content, dst)

      if not write_ok then
        vim.notify("Failed to copy file: " .. dst, vim.log.levels.ERROR)
        return false
      end
    end
    return true
  else
    vim.notify("Source file not found: " .. src, vim.log.levels.WARN)
    return false
  end
end

-- Read file contents
function M.read_file_contents(path)
  local file = io.open(path, "r")
  if file then
    local content = file:read("*all")
    file:close()
    return content
  end
  return nil
end

-- Write to file
function M.write_to_file(path, content)
  local file = io.open(path, "w")
  if file then
    file:write(content)
    file:close()
    return true
  end
  return false
end

return M
