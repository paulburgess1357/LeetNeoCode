-- Main entry point for LeetNeoCode plugin
local M = {}

-- Store references to submodules
M.config = require "LeetNeoCode.config"
M.pull = require "LeetNeoCode.pull"
M.problem = require "LeetNeoCode.problem"
M.format = require "LeetNeoCode.format"
M.images = require "LeetNeoCode.images"
M.utils = require "LeetNeoCode.utils"

-- Keep old reference for backward compatibility
M.util = {
  paths = M.utils.path,
}
M.commands = require "LeetNeoCode.commands"

-- Track whether image.nvim is properly setup
M.image_setup_done = false

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

  -- Configure image.nvim if enabled
  if M.config.enable_images and M.config.render_image ~= false then
    local can_display = M.images.is_terminal_supported()

    -- Try to setup image.nvim with our settings
    local ok, img = pcall(require, "image")
    if ok then
      -- Configure image.nvim with our settings
      pcall(function()
        img.setup {
          backend = "kitty",
          processor = "magick_cli",
          max_width = M.config.image_max_width,
          max_height = M.config.image_max_height,
          max_width_window_percentage = M.config.image_max_width_pct,
          max_height_window_percentage = M.config.image_max_height_pct,
          window_overlap_clear_enabled = false,
          editor_only_render_when_focused = false,
          tmux_show_only_in_active_window = false,
        }
        M.image_setup_done = true
      end)

      if M.config.notify_on_image_support and M.image_setup_done then
        vim.notify("Configured image.nvim for leetcode", vim.log.levels.INFO)
      end
    end

    -- Terminal support notification
    if M.config.notify_on_image_support then
      if can_display then
        vim.notify("Your terminal supports inline images!", vim.log.levels.INFO)
      else
        vim.notify("⚠️ Your terminal does NOT support inline images; using text placeholders.", vim.log.levels.WARN)
      end
    end
  end

  -- Register commands
  M.commands.setup(M)

  -- Set up syntax highlighting for the metadata comment
  M.format.syntax.setup_solution_highlighting()
  M.format.syntax.setup_fold_settings()

  if M.config.smart_copy then
    M.utils.leetcode_copy.setup(M.config)
  end
end

return M
