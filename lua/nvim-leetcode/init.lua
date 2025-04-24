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
  notify = require("nvim-leetcode.util.notify"),
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

  -- ▶ terminal support for inline images
  local can_display = M.images.is_terminal_supported()
  if M.config.enable_images and M.config.notify_on_image_support then
    if can_display then
      vim.notify("✅ Your terminal supports inline images!", vim.log.levels.INFO)
    else
      vim.notify(
        "⚠️ Your terminal does NOT support inline images; using text placeholders.",
        vim.log.levels.WARN
      )
    end
  end

  -- Register commands
  M.commands.setup(M)

  -- Set up syntax highlighting for the metadata comment
  M.format.syntax.setup_solution_highlighting()
  M.format.syntax.setup_fold_settings()
end

return M
