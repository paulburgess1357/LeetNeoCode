-- Syntax highlighting setup module
local M = {}
local C = require "LeetNeoCode.config"

-- Setup highlighting for problem description
function M.setup_highlighting()
  -- Get configuration values with defaults
  local start_marker = vim.fn.escape(C.code_block_start or "⌊", "/")
  local end_marker = vim.fn.escape(C.code_block_end or "⌋", "/")
  local color = C.code_block_color or (C.colors and C.colors.problem_code_block) or "#e6c07a"
  local style = C.code_block_style or "italic"
  local colors = C.colors or {}

  -- Create the highlighting command
  local highlighting_cmd = string.format(
    [[
    syntax match ProblemTitle       /^Description$/
    syntax match ProblemSection     /^Constraints:$/
    syntax region ProblemConstraints start=/^Constraints:$/ end=/^\s*$/ keepend
    syntax match ProblemConstraintNum /\d\+/ containedin=ProblemConstraints
    syntax match ProblemFollowup    /^Follow-up:$/
    syntax match ProblemExample     /^Example \d\+:$/
    syntax match ProblemBullet      /^• .*$/
    syntax match ProblemInput       /^Input: .*$/
    syntax match ProblemOutput      /^Output: .*$/
    syntax region ProblemExplanation start=/^Explanation:/ end=/^\s*$/ keepend
    syntax match ProblemMath        /[<>=]=\|[<>=]\|O(n[²³⁴⁵⁶⁷⁸⁹])/
    syntax match ProblemNumber      /\<\d\+\>/
    syntax match ProblemSuperscript /[⁰¹²³⁴⁵⁶⁷⁸⁹⁻⁺⁽⁾ⁿˣʸ]/
    syntax match ProblemVariable    /nums\|\<n\>\|target\|Node\.val/

    " Highlight code blocks with configurable markers and style
    syntax region ProblemCodeBlock start=/%s/ end=/%s/ keepend
    highlight ProblemCodeBlock guifg=%s gui=%s

    setlocal conceallevel=2 concealcursor=nc
    setlocal nowrap
  ]],
    start_marker,
    end_marker,
    color,
    style
  )

  -- Add highlighting commands with configurable colors
  highlighting_cmd = highlighting_cmd
    .. string.format(
      [[

    highlight ProblemTitle         guifg=%s gui=bold
    highlight ProblemSection       guifg=%s gui=bold
    highlight ProblemConstraints   guifg=%s
    highlight ProblemConstraintNum guifg=%s gui=bold
    highlight ProblemFollowup      guifg=%s gui=bold
    highlight ProblemExample       guifg=%s gui=bold
    highlight ProblemBullet        guifg=%s
    highlight ProblemInput         guifg=%s
    highlight ProblemOutput        guifg=%s
    highlight ProblemExplanation   guifg=%s
    highlight ProblemMath          guifg=%s
    highlight ProblemNumber        guifg=%s gui=bold
    highlight ProblemSuperscript   guifg=%s
    highlight ProblemVariable      guifg=%s
  ]],
      colors.problem_title or "#ff7a6c",
      colors.problem_section or "#d8a657",
      colors.problem_constraints or "#89b482",
      colors.problem_constraint_num or "#d8a657",
      colors.problem_followup or "#d8a657",
      colors.problem_example or "#a9b665",
      colors.problem_bullet or "#d3869b",
      colors.problem_input or "#e78a4e",
      colors.problem_output or "#ea6962",
      colors.problem_explanation or "#89b482",
      colors.problem_math or "#d3869b",
      colors.problem_number or "#d8a657",
      colors.problem_superscript or "#d8a657",
      colors.problem_variable or "#7daea3"
    )

  vim.cmd(highlighting_cmd)
end

-- Setup highlighting for solution files
function M.setup_solution_highlighting()
  local colors = C.colors or {}

  vim.cmd [[
    " Highlight groups for problem metadata and comments
    highlight default link LeetCodeMetadata Identifier
    highlight default link LeetCodeTag Keyword
    highlight default link LeetCodeUserTag String

    " Syntax highlighting for metadata lines in the comment
    syntax match LeetCodeMetadataLine /^\* Problem:.*$/ contained
    syntax match LeetCodeDifficultyLine /^\* Difficulty:.*$/ contained
    syntax match LeetCodeTagsLine /^\* LC Tags:.*$/ contained
    syntax match LeetCodeUserTagsLine /^\* User Tags:.*$/ contained
  ]]

  -- Set highlighting colors with fallbacks to defaults
  vim.cmd(string.format("highlight LeetCodeMetadataLine guifg=%s gui=bold", colors.metadata_line or "#d8a657"))
  vim.cmd(string.format("highlight LeetCodeDifficultyLine guifg=%s gui=bold", colors.difficulty_line or "#a9b665"))
  vim.cmd(string.format("highlight LeetCodeTagsLine guifg=%s", colors.tags_line or "#7daea3"))
  vim.cmd(string.format("highlight LeetCodeUserTagsLine guifg=%s", colors.user_tags_line or "#e78a4e"))
end

-- Setup fold markers for solution files with zero-padded folder format
function M.setup_fold_settings()
  -- Use configured fold markers or fallbacks
  local fold_start = C.fold_marker_start or "▼"
  local fold_end = C.fold_marker_end or "▲"

  -- Get supported languages extensions
  local language_extensions = {
    "cpp", "py", "java", "js", "ts", "go", "rs", "swift", "cs",
    "rb", "kt", "php", "dart", "scala", "c", "m", "erl", "ex", "clj", "hs",
  }

  -- Create patterns for zero-padded solution file format (LC00123_)
  local solutions_path = C.cache_dir .. "/" .. C.solutions_subdir
  local escaped_path = vim.fn.escape(solutions_path, "\\")

  local file_pattern = escaped_path .. "/**/LC[0-9][0-9][0-9][0-9][0-9]_*.{" .. table.concat(language_extensions, ",") .. "}"

  vim.cmd([[
    " Autocommands for LeetCode solution files
    augroup LeetCodeSolutions
      autocmd!
      " Set fold method and markers for all solution files
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ setlocal foldmethod=marker
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ setlocal foldmarker=]] .. fold_start .. [[,]] .. fold_end .. [[
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ setlocal foldenable
      " Close all folds when opening a solution file - using a more reliable approach
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ normal! zM
      " Hide fold markers to make them less visually distracting
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ syntax match Comment /]] .. fold_start .. [[/ conceal
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ syntax match Comment /]] .. fold_end .. [[/ conceal
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ setlocal conceallevel=2
      " Make sure folds can be manipulated
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ setlocal foldopen=all
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ setlocal foldclose=all
      " Set a normal-mode mapping to toggle folds
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ nnoremap <buffer> <leader>f za
    augroup END
  ]])
end

return M
