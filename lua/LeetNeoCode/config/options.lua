-- Configuration options for LeetNeoCode
local M = {
  ---------------------------------------------------------------------------
  -- Core settings
  ---------------------------------------------------------------------------
  default_language = "cpp", -- valid values: cpp, python, java, javascript, go, rust, swift, csharp

  -- Storage paths ----------------------------------------------------------
  cache_dir = vim.fn.stdpath "cache" .. "/LeetNeoCode",
  cache_subdir = "meta",
  cache_file = "leetcode_cache.json",
  cache_expiry_days = 14,
  solutions_subdir = "solutions",
  images_subdir = "images",

  API_URL = "https://leetcode.com/api/problems/all/",

  -- Notification timing ----------------------------------------------------
  notify_wait_timeout = 50, -- ms to keep floating notifier visible
  notify_wait_interval = 10, -- ms polling interval inside vim.wait

  -- Window layout ----------------------------------------------------------
  description_split = 0.35, -- fraction of tab width for description

  ---------------------------------------------------------------------------
  -- Custom hard-wrap options
  ---------------------------------------------------------------------------
  enable_custom_wrap = true, -- set false ⇒ no hard wrapping at all
  custom_wrap_offset = 0.02, -- wrap width uses (description_split – offset)
  -- e.g. 0.35 – 0.10  = 0.25

  ---------------------------------------------------------------------------
  -- Color scheme
  ---------------------------------------------------------------------------
  -- All colors used in the plugin
  colors = {
    -- Problem description colors
    problem_title = "#ff7a6c",
    problem_section = "#d8a657",
    problem_constraints = "#89b482",
    problem_constraint_num = "#d8a657",
    problem_followup = "#d8a657",
    problem_example = "#a9b665",
    problem_bullet = "#d3869b",
    problem_input = "#d19a66",
    problem_output = "#98c379",
    problem_explanation = "#e5c07b",
    problem_math = "#d3869b",
    problem_number = "#d8a657",
    problem_superscript = "#d8a657",
    problem_variable = "#7daea3",
    problem_code_block = "#e6c07a",

    -- Metadata colors
    metadata_line = "#d8a657",
    difficulty_line = "#a9b665",
    tags_line = "#7daea3",
    user_tags_line = "#e78a4e",
  },

  ---------------------------------------------------------------------------
  -- Metadata options
  ---------------------------------------------------------------------------
  include_problem_metadata = true, -- Include problem metadata
  include_leetcode_tags = true, -- Include LC tags
  include_user_tags = true, -- "User Tags:" stub
  metadata_at_bottom = true, -- Put metadata at file end
  metadata_comment_style = "multi", -- multiline /*…*/

  ---------------------------------------------------------------------------
  -- Image handling
  ---------------------------------------------------------------------------
  enable_images = true,
  -- Terminals to check for inline-image support
  -- each entry: { var = ENV_VAR_NAME, [match = SUBSTRING] }
  image_terminals = {
    { var = "TERM", match = "kitty" }, -- TERM contains "kitty"
    { var = "KITTY_WINDOW_ID" }, -- presence suffices
  },

  -- Image configuration ----------------------------------------------------
  notify_on_image_support = true,
  use_direct_urls = true,
  image_render_delay = 100, -- ms
  image_max_width = nil, -- nil → auto
  image_max_height = 20,
  -- Image sizing options (percentage of window)
  image_max_width_pct = 40, -- 40% of window width (0 to disable)
  image_max_height_pct = 30, -- 30% of window height (0 to disable)
  image_right_after_separator = true,
  image_preserve_aspect_ratio = true,

  -- Folding options -------------------------------------------------------
  fold_marker_start = "▼",
  fold_marker_end = "▲",
  image_auto_render_on_win_focus = true,

  ---------------------------------------------------------------------------
  -- Code block highlighting
  ---------------------------------------------------------------------------
  code_block_start = "{", -- Start marker for code blocks
  code_block_end = "}", -- End marker for code blocks
  code_block_color = "#e6c07a", -- Color for code blocks
  code_block_style = "italic", -- Style for code blocks (normal, bold, italic)

  ---------------------------------------------------------------------------
  -- Misc
  ---------------------------------------------------------------------------
  smart_copy = false, -- When true, excludes includes and metadata when copying
  smart_copy_color = "#34C759",
}

return M
