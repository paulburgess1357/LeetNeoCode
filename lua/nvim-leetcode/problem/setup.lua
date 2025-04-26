-- Setup for problem directories and dependencies
local vim = vim
local C = require("nvim-leetcode.config")
local cache = require("nvim-leetcode.problem.cache")
local format = require("nvim-leetcode.format")
local pull = require("nvim-leetcode.pull")

local M = {}

-- Prepare solution directory for a problem
function M.prepare_solution_dir(num, title, slug)
  local safe_title = (title or slug):gsub("%W+", "_"):gsub("^_+", ""):gsub("_+$", "")
  local sol_base = cache.get_solution_dir()

  if vim.fn.isdirectory(sol_base) == 0 then
    vim.fn.mkdir(sol_base, "p")
  end

  local prob_dir = sol_base .. "/LC" .. num .. "_" .. safe_title
  if vim.fn.isdirectory(prob_dir) == 0 then
    vim.fn.mkdir(prob_dir, "p")
  end

  return prob_dir
end

-- Find the dependencies directory
function M.find_dependencies_dir()
  -- Find the plugin installation path
  local plugin_paths = {
    -- Check LazyVim path first
    vim.fn.expand("~/.local/share/nvim/lazy/nvim-leetcode/lua/nvim-leetcode/dependencies"),
    -- Check Packer path
    vim.fn.expand("~/.local/share/nvim/site/pack/packer/start/nvim-leetcode/lua/nvim-leetcode/dependencies"),
    -- Check local repo path
    vim.fn.expand("~/Repos/nvim-leetcode/lua/nvim-leetcode/dependencies"),
    -- Check built-in module path (fallback)
    C.get_dependencies_dir(),
  }

  for _, path in ipairs(plugin_paths) do
    if vim.fn.isdirectory(path) == 1 then
      return path
    end
  end

  vim.notify("Could not find dependencies directory. Symlinks may not work.", vim.log.levels.WARN)
  return C.get_dependencies_dir()
end

-- Setup dependencies (symlinks or copies)
function M.setup_dependencies(prob_dir)
  local dep_dir = M.find_dependencies_dir()

  local language = C.default_language or "cpp"

  -- Map file extensions to their language
  local language_map = {
    ["cpp"] = "cpp",
    ["java"] = "java",
    ["py"] = "python",
    ["js"] = "javascript",
    ["go"] = "go",
    ["rs"] = "rust",
    ["swift"] = "swift",
    ["cs"] = "csharp"
  }

  -- Language-specific dependency files
  local dependencies = {
  local dependencies = {
    cpp = {
      { src = "lc_includes.h", dst = "lc_includes.h" },
      { src = ".clangd", dst = ".clangd" },
      { src = ".clang-format", dst = ".clang-format" },
      { src = ".clang-tidy", dst = ".clang-tidy" }
    },
    python = {
      { src = "lc_includes.py", dst = "lc_includes.py" },
      { src = "pyproject.toml", dst = "pyproject.toml" }
    },
    java = {
      { src = "LCIncludes.java", dst = "LCIncludes.java" },
      { src = "checkstyle.xml", dst = "checkstyle.xml" }
    },
    javascript = {
      { src = "lc_includes.js", dst = "lc_includes.js" },
      { src = ".eslintrc.js", dst = ".eslintrc.js" },
      { src = "tsconfig.json", dst = "tsconfig.json" }
    },
    go = {
      { src = "lc_includes.go", dst = "lc_includes.go" },
      { src = ".golangci.yml", dst = ".golangci.yml" }
    },
    rust = {
      { src = "lc_includes.rs", dst = "lc_includes.rs" },
      { src = ".rustfmt.toml", dst = ".rustfmt.toml" }
    },
    swift = {
      { src = "LCIncludes.swift", dst = "LCIncludes.swift" },
      { src = ".swiftlint.yml", dst = ".swiftlint.yml" }
    },
    csharp = {
      { src = "LCIncludes.cs", dst = "LCIncludes.cs" },
      { src = ".editorconfig", dst = ".editorconfig" }
    }
  }

  -- Get language from file extension
  local lang = language_map[language] or "cpp"
  local deps = dependencies[lang] or dependencies["cpp"]

  for _, dep in ipairs(deps) do
    local src = dep_dir .. "/" .. dep.src
    local dst = prob_dir .. "/" .. dep.dst

      -- Create an absolute symlink using direct shell command
      local cmd = string.format("ln -sf '%s' '%s'", src, dst)
      local success, err, code = os.execute(cmd)

      if not success then
        vim.notify("Failed to create symlink: " .. (err or "Unknown error"), vim.log.levels.WARN)

        -- Fallback to direct copy
        local content = vim.fn.readfile(src)
        local write_ok = pcall(vim.fn.writefile, content, dst)

        if not write_ok then
          vim.notify(
            "Failed to copy " .. fname .. ". File dependencies may be missing.",
            vim.log.levels.ERROR
          )
        else
          vim.notify("Copied " .. fname .. " instead of symlink", vim.log.levels.INFO)
        end
      end
    else
      vim.notify("Source file not found: " .. src, vim.log.levels.WARN)
    end
  end
end

-- Fetch problem data (description and code)
function M.fetch_problem_data(slug)
  local problem_data = {}
  do
    local ok, result = pcall(pull.description.fetch_description, slug)
    problem_data = ok and type(result) == "table" and result or { content = "" }
    if problem_data.content == "" then
      vim.notify("Could not fetch description for problem", vim.log.levels.WARN)
    end
  end

  local snippets
  do
    local ok, res = pcall(pull.code.fetch_stub, slug)
    snippets = ok and res or nil
    if not snippets then
      vim.notify("Could not fetch code stub for problem", vim.log.levels.WARN)
    end
  end

  return problem_data, snippets
end

-- Determine next solution version and save file
-- Function replaced by update script
-- Save solution file with clean fold markers
function M.save_solution_file(prob_dir, snippets, problem_data)
  if not snippets then
    return nil, 0
  end

  -- Find next version number
  local max_index = 0
  for _, path in ipairs(vim.fn.globpath(prob_dir, "Solution_*." .. C.default_language, false, true)) do
    local name = vim.fn.fnamemodify(path, ":t")
    local idx = tonumber(name:match("^Solution_(%d+)")) or 0
    if idx > max_index then
      max_index = idx
    end
  end

  local version = max_index + 1
  local fname = string.format("Solution_%d.%s", version, C.default_language)
  local fpath = prob_dir .. "/" .. fname

  -- Save solution file
  local f = io.open(fpath, "w")
  if f then
    -- Write the solution template first
    -- Language-specific headers
    local headers = {
      cpp = '#include "lc_includes.h"\n\n',
      python = 'from lc_includes import *\n\n',
      java = 'import java.util.*;\n\n',
      javascript = '// No special imports needed for JavaScript\n\n',
      go = 'package main\n\nimport (\n\t"fmt"\n)\n\n',
      rust = 'mod lc_includes;\nuse lc_includes::*;\n\n',
      swift = 'import Foundation\n\n',
      csharp = 'using System;\nusing System.Collections.Generic;\n\n'
    }

    -- Map file extensions to their language
    local language_map = {
      ["cpp"] = "cpp",
      ["java"] = "java",
      ["py"] = "python",
      ["js"] = "javascript",
      ["go"] = "go",
      ["rs"] = "rust",
      ["swift"] = "swift",
      ["cs"] = "csharp"
    }

    local lang = language_map[C.default_language] or "cpp"
    local header = headers[lang] or ""

    -- Write the language-specific header
    f:write(header)
    f:write(snippets)
    f:write("\n\n")

    -- Use safe fallbacks for fold markers
    local fold_start = C.fold_marker_start or "BEGIN_METADATA"
    local fold_end = C.fold_marker_end or "END_METADATA"

    -- Add metadata comment with fold markers
    f:write("\n")
    f:write("/* " .. fold_start)

    -- Add problem metadata to comment
    if problem_data.title and problem_data.difficulty and problem_data.questionId then
      f:write("\n" .. format.format_metadata(problem_data))
      f:write("\n" .. format.format_difficulty(problem_data))
    end

    -- Add LeetCode tags to comment
    if problem_data.topicTags then
      f:write("\n" .. format.format_tags(problem_data.topicTags))
    end

    -- Add user tags section to comment
    f:write("\n" .. format.create_user_tags_section())

    f:write("\n" .. fold_end .. " */")

    f:close()
  end

  return fpath, version
end

return M
