-- Syntax highlighting for problem view
local M = {}

-- Setup highlighting for the problem description
function M.setup_description_highlighting()
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

-- Setup highlighting for solution files
function M.setup_solution_highlighting()
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

    highlight LeetCodeMetadataLine guifg=#d8a657 gui=bold
    highlight LeetCodeDifficultyLine guifg=#a9b665 gui=bold
    highlight LeetCodeTagsLine guifg=#7daea3
    highlight LeetCodeUserTagsLine guifg=#e78a4e
  ]])
end

-- Setup fold markers for solution files
function M.setup_fold_settings()
	vim.cmd([[
    " Autocommands for LeetCode solution files
    augroup LeetCodeSolutions
      autocmd!
      " Set fold method for CPP files in LeetCode solutions directory
      autocmd BufReadPost,BufNewFile */nvim-leetcode/solutions/**/*.cpp setlocal foldmethod=marker
      " Close all folds when opening a solution file
      autocmd BufReadPost,BufNewFile */nvim-leetcode/solutions/**/*.cpp normal! zM
      " Hide fold markers to make them less visually distracting
      autocmd BufReadPost,BufNewFile */nvim-leetcode/solutions/**/*.cpp syntax match Comment /{\{3}/ conceal
      autocmd BufReadPost,BufNewFile */nvim-leetcode/solutions/**/*.cpp syntax match Comment /}\{3}/ conceal
      autocmd BufReadPost,BufNewFile */nvim-leetcode/solutions/**/*.cpp setlocal conceallevel=2
    augroup END
  ]])
end

return M
