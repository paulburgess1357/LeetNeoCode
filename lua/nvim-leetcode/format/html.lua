-- Main HTML formatting module for nvim-leetcode
local M = {}

-- Import submodules
local html_processor = require("nvim-leetcode.format.processor.html")
local leetcode_processor = require("nvim-leetcode.format.processor.leetcode")
local wrap_util = require("nvim-leetcode.format.wrap")
local C = require("nvim-leetcode.config")

-- Main function to format problem text
function M.format_problem_text(html)
  if type(html) ~= "string" or html == "" then
    return ""
  end

  -- Step 1: Process HTML entities and special tags
  local t = html_processor.process_entities(html)

  -- Step 2: Process HTML tags
  t = html_processor.process_tags(t)

  -- Step 3: Process LeetCode-specific patterns
  t = leetcode_processor.process_patterns(t)

  -- Step 4: Apply custom wrapping if enabled
  if C.enable_custom_wrap ~= false then
    t = wrap_util.apply_custom_wrap(t)
  end

  -- Ensure exactly one trailing newline
  t = t:gsub("\n+$", "\n")

  return t
end

-- Setup syntax highlighting for problem description
function M.setup_highlighting()
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
    syntax match ProblemSuperscript /[⁰¹²³⁴⁵⁶⁷⁸⁹⁻⁺⁽⁾ⁿˣʸ]/
    syntax match ProblemVariable    /nums\|\<n\>\|target\|Node\.val/

    setlocal conceallevel=2 concealcursor=nc
    setlocal nowrap

    highlight ProblemTitle         guifg=#ff7a6c gui=bold
    highlight ProblemSection       guifg=#d8a657 gui=bold
    highlight ProblemConstraints   guifg=#89b482
    highlight ProblemConstraintNum guifg=#d8a657 gui=bold
    highlight ProblemFollowup      guifg=#d8a657 gui=bold
    highlight ProblemExample       guifg=#a9b665 gui=bold
    highlight ProblemBullet        guifg=#d3869b
    highlight ProblemInput         guifg=#e78a4e
    highlight ProblemOutput        guifg=#ea6962
    highlight ProblemExplanation   guifg=#89b482
    highlight ProblemMath          guifg=#d3869b
    highlight ProblemNumber        guifg=#d8a657 gui=bold
    highlight ProblemSuperscript   guifg=#d8a657
    highlight ProblemVariable      guifg=#7daea3
  ]])
end

return M
