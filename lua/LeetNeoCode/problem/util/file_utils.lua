-- File operations helper for problem setup
local vim = vim
local C = require "LeetNeoCode.config"
local languages = require "LeetNeoCode.problem.helper.languages"

local M = {}

-- Create a dependency symlink or copy as fallback
function M.create_dependency_link(src, dst)
  -- Check if source file exists
  if vim.fn.filereadable(src) == 1 then
    -- Remove existing file if it exists
    if vim.fn.filereadable(dst) == 1 then
      vim.fn.delete(dst)
    end

    -- Create an absolute symlink using direct shell command
    local escaped_src = vim.fn.shellescape(src)
    local escaped_dst = vim.fn.shellescape(dst)
    local cmd = string.format("ln -sf %s %s", escaped_src, escaped_dst)
    local success, err, code = os.execute(cmd)

    if not success then
      vim.notify("Failed to create symlink: " .. (err or "Unknown error"), vim.log.levels.WARN)

      -- Fallback to direct copy
      local content = vim.fn.readfile(src)
      local write_ok = pcall(vim.fn.writefile, content, dst)

      if not write_ok then
        vim.notify("Failed to copy dependency. File dependencies may be missing.", vim.log.levels.ERROR)
      else
        vim.notify("Copied dependency instead of symlink", vim.log.levels.INFO)
      end
    end
  else
    vim.notify("Source file not found: " .. src, vim.log.levels.WARN)
  end
end

-- Write solution file with appropriate headers and metadata
function M.write_solution_file(fpath, snippets, problem_data, fold_start, fold_end)
  local f = io.open(fpath, "w")
  if not f then
    return false
  end

  -- Get language key
  local lang = languages.language_map[C.default_language]
  local header = languages.headers[lang] or ""

  -- Write the language-specific header
  f:write(header)
  f:write(snippets)
  f:write "\n\n"

  -- Get comment style for current language
  local comment_style = languages.comment_styles[C.default_language]
  if not comment_style then
    -- Fallback to C-style comments
    comment_style = languages.comment_styles.cpp
  end

  -- Add metadata comment with fold markers
  f:write "\n"
  f:write(comment_style.start .. fold_start .. "\n")

  -- Add problem metadata to comment with appropriate prefix
  if problem_data.title and problem_data.difficulty and problem_data.questionId then
    f:write(
      comment_style.line_prefix .. "Problem: LC#" .. problem_data.questionId .. " " .. problem_data.title .. "\n"
    )
    f:write(comment_style.line_prefix .. "Difficulty: " .. problem_data.difficulty .. "\n")
  end

  -- Add LeetCode tags to comment
  if problem_data.topicTags then
    local tag_names = {}
    for _, tag in ipairs(problem_data.topicTags) do
      table.insert(tag_names, tag.name)
    end
    f:write(comment_style.line_prefix .. "LC Tags: " .. table.concat(tag_names, ", ") .. "\n")
  end

  -- Add user tags section to comment
  f:write(comment_style.line_prefix .. "User Tags:\n")

  -- End the comment block
  f:write(comment_style.end_prefix .. fold_end .. comment_style.close)

  f:close()
  return true
end

-- Find the highest numbered solution file and return next version
function M.get_next_solution_version(prob_dir)
  local max_index = 0
  for _, path in ipairs(vim.fn.globpath(prob_dir, "Solution_*.*", false, true)) do
    local name = vim.fn.fnamemodify(path, ":t")
    local idx = tonumber(name:match "^Solution_(%d+)") or 0
    if idx > max_index then
      max_index = idx
    end
  end
  return max_index + 1
end

-- Create directory with proper handling
function M.ensure_directory(dir_path)
  if vim.fn.isdirectory(dir_path) == 0 then
    vim.fn.mkdir(dir_path, "p")
    return true
  end
  return false
end

return M
