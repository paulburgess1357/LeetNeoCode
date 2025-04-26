-- Syntax highlighting for problem view
local M = {}

-- Setup highlighting for the problem description
function M.setup_description_highlighting()
  local C = require("nvim-leetcode.config")
  local colors = C.colors or {}

  vim.cmd([[
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
    syntax match ProblemSuperscript /[⁰¹²³⁴⁵⁶⁷⁸⁹]/
    syntax match ProblemVariable    /nums\|\<n\>\|target\|Node\.val/

    setlocal conceallevel=2 concealcursor=nc
    setlocal nowrap
  ]])

  -- Set highlighting colors with fallbacks to defaults
  vim.cmd(string.format("highlight ProblemTitle guifg=%s gui=bold", colors.problem_title or "#ff7a6c"))
  vim.cmd(string.format("highlight ProblemSection guifg=%s gui=bold", colors.problem_section or "#d8a657"))
  vim.cmd(string.format("highlight ProblemConstraints guifg=%s", colors.problem_constraints or "#89b482"))
  vim.cmd(
    string.format("highlight ProblemConstraintNum guifg=%s gui=bold", colors.problem_constraint_num or "#d8a657")
  )
  vim.cmd(string.format("highlight ProblemFollowup guifg=%s gui=bold", colors.problem_followup or "#d8a657"))
  vim.cmd(string.format("highlight ProblemExample guifg=%s gui=bold", colors.problem_example or "#a9b665"))
  vim.cmd(string.format("highlight ProblemBullet guifg=%s", colors.problem_bullet or "#d3869b"))
  vim.cmd(string.format("highlight ProblemInput guifg=%s", colors.problem_input or "#e78a4e"))
  vim.cmd(string.format("highlight ProblemOutput guifg=%s", colors.problem_output or "#ea6962"))
  vim.cmd(string.format("highlight ProblemExplanation guifg=%s", colors.problem_explanation or "#89b482"))
  vim.cmd(string.format("highlight ProblemMath guifg=%s", colors.problem_math or "#d3869b"))
  vim.cmd(string.format("highlight ProblemNumber guifg=%s gui=bold", colors.problem_number or "#d8a657"))
  vim.cmd(string.format("highlight ProblemSuperscript guifg=%s", colors.problem_superscript or "#d8a657"))
  vim.cmd(string.format("highlight ProblemVariable guifg=%s", colors.problem_variable or "#7daea3"))
end

-- Setup highlighting for solution files
function M.setup_solution_highlighting()
  local C = require("nvim-leetcode.config")
  local colors = C.colors or {}

  vim.cmd([[
    " Highlight groups for problem metadata and comments
    highlight default link LeetCodeMetadata Identifier
    highlight default link LeetCodeTag Keyword
    highlight default link LeetCodeUserTag String

    " Syntax highlighting for metadata lines in the comment
    syntax match LeetCodeMetadataLine /^\* Problem:.*$/ contained
    syntax match LeetCodeDifficultyLine /^\* Difficulty:.*$/ contained
    syntax match LeetCodeTagsLine /^\* LC Tags:.*$/ contained
    syntax match LeetCodeUserTagsLine /^\* User Tags:.*$/ contained
  ]])

  -- Set highlighting colors with fallbacks to defaults
  vim.cmd(string.format("highlight LeetCodeMetadataLine guifg=%s gui=bold", colors.metadata_line or "#d8a657"))
  vim.cmd(string.format("highlight LeetCodeDifficultyLine guifg=%s gui=bold", colors.difficulty_line or "#a9b665"))
  vim.cmd(string.format("highlight LeetCodeTagsLine guifg=%s", colors.tags_line or "#7daea3"))
  vim.cmd(string.format("highlight LeetCodeUserTagsLine guifg=%s", colors.user_tags_line or "#e78a4e"))
end

-- Setup fold markers for solution files
function M.setup_fold_settings()
  local C = require("nvim-leetcode.config")
  -- Use configured fold markers or fallbacks
  local fold_start = C.fold_marker_start or "▼"
  local fold_end = C.fold_marker_end or "▲"

  -- Get supported languages extensions
  local language_extensions = {
    "cpp",
    "py",
    "java",
    "js",
    "ts",
    "go",
    "rs",
    "swift",
    "cs",
    "rb",
    "kt",
    "php",
    "dart",
    "scala",
    "c",
    "m",
    "erl",
    "ex",
    "clj",
    "hs",
  }

  -- Create a pattern that matches all solution file types
  -- Use the configured solution directory path
  local solutions_path = C.cache_dir .. "/" .. C.solutions_subdir
  local file_pattern = vim.fn.escape(solutions_path, "\\") .. "/**/*.{"
  file_pattern = file_pattern .. table.concat(language_extensions, ",") .. "}"

  vim.cmd([[
    " Autocommands for LeetCode solution files
    augroup LeetCodeSolutions
      autocmd!
      " Set fold method and markers for all solution files
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ setlocal foldmethod=marker
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ setlocal foldmarker=]] .. fold_start .. [[,]] .. fold_end .. [[
      " Close all folds when opening a solution file
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ normal! zM
      " Hide fold markers to make them less visually distracting
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ syntax match Comment /]] .. fold_start .. [[/ conceal
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ syntax match Comment /]] .. fold_end .. [[/ conceal
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ setlocal conceallevel=2
      " Make sure foldenable is on and folds can be manipulated
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ setlocal foldenable
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ setlocal foldopen=all
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ setlocal foldclose=all
      " Set a normal-mode mapping to toggle folds
      autocmd BufReadPost,BufNewFile ]] .. file_pattern .. [[ nnoremap <buffer> <leader>f za
    augroup END
  ]])
end

return M
