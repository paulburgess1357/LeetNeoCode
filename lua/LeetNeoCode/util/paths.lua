-- Utility module for path operations
local M = {}

-- In util/paths.lua
function M.find_dependencies_dir()
  -- Get the path of the current running file
  local source_path = debug.getinfo(1, "S").source:sub(2)

  -- Move up to the plugin root
  local plugin_root = vim.fn.fnamemodify(source_path, ":h:h:h")

  -- Try standard locations first
  local candidates = {
    plugin_root .. "/lua/LeetNeoCode/dependencies",
    plugin_root .. "/dependencies",

    -- Common plugin manager paths
    vim.fn.stdpath("data") .. "/lazy/LeetNeoCode/lua/LeetNeoCode/dependencies",
    vim.fn.stdpath("data") .. "/lazy/LeetNeoCode/dependencies",
    vim.fn.stdpath("data") .. "/site/pack/packer/start/LeetNeoCode/lua/LeetNeoCode/dependencies",
    vim.fn.stdpath("data") .. "/site/pack/packer/start/LeetNeoCode/dependencies",

    -- Original fallbacks
    vim.fn.expand("~/.local/share/nvim/lazy/LeetNeoCode/lua/LeetNeoCode/dependencies"),
    vim.fn.expand("~/.local/share/nvim/site/pack/packer/start/LeetNeoCode/lua/LeetNeoCode/dependencies"),
    vim.fn.expand("~/Repos/LeetNeoCode/lua/LeetNeoCode/dependencies"),
  }

  -- Try each candidate
  for _, path in ipairs(candidates) do
    if vim.fn.isdirectory(path) == 1 then
      return path
    end
  end

  -- Simple fallback as last resort
  local simple_fallback = plugin_root .. "/dependencies"

  vim.notify("Could not find dependencies directory. Symlinks may not work.", vim.log.levels.WARN)
  return simple_fallback
end

-- Sanitize a title for use in filenames
function M.sanitize_title(title, slug)
  local safe_title = (title or slug):gsub("%W+", "_"):gsub("^_+", ""):gsub("_+$", "")
  return safe_title
end

-- Get a path relative to the plugin root
function M.get_plugin_path(...)
  local source_path = debug.getinfo(1, "S").source:sub(2)
  local plugin_dir = vim.fn.fnamemodify(source_path, ":h:h:h")

  local parts = { ... }
  if #parts == 0 then
    return plugin_dir
  end

  return plugin_dir .. "/" .. table.concat(parts, "/")
end

return M
