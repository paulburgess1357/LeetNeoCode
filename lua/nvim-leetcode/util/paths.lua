-- Utility module for path operations
local M = {}

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
