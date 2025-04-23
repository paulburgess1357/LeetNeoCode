-- Main entry point for nvim-leetcode plugin
local M = {}

-- Store references to submodules
M.config = require("nvim-leetcode.config")
M.pull = require("nvim-leetcode.pull")
M.problem = require("nvim-leetcode.problem")
M.format = require("nvim-leetcode.format")
M.images = require("nvim-leetcode.images")
M.util = {
  paths = require("nvim-leetcode.util.paths"),
  notify = require("nvim-leetcode.util.notify")
}
M.commands = require("nvim-leetcode.commands")

-- Setup function with user config
function M.setup(user_config)
  -- Merge user config with defaults
  if user_config then
    for k, v in pairs(user_config) do
      M.config[k] = v
    end
  end

  -- Initialize cache directories
  M.config.ensure_cache_dirs()

  -- Check for image.nvim dependency
  local has_image = pcall(require, "image")
  if not has_image and M.config.enable_images then
    vim.notify(
      "image.nvim not found but enable_images is true. Images will be displayed as text placeholders.",
      vim.log.levels.WARN
    )
  end

  -- Register commands
  M.commands.setup(M)

  -- Set up syntax highlighting for the metadata comment
  M.format.syntax.setup_solution_highlighting()
  M.format.syntax.setup_fold_settings()
end

return M
