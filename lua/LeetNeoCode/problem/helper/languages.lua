-- Language-specific helpers for problem setup
local M = {}

-- Map default_language slug → dependency key
M.language_map = {
  ["cpp"] = "cpp",
  ["python"] = "python",
  ["java"] = "java",
  ["javascript"] = "javascript",
  ["go"] = "go",
  ["rust"] = "rust",
  ["swift"] = "swift",
  ["csharp"] = "csharp",
}

-- Map default_language slug → file extension
M.extension_map = {
  cpp = "cpp",
  python = "py",
  java = "java",
  javascript = "js",
  typescript = "ts",
  go = "go",
  rust = "rs",
  swift = "swift",
  csharp = "cs",
  ruby = "rb",
  kotlin = "kt",
  php = "php",
  dart = "dart",
  scala = "scala",
  c = "c",
  objective_c = "m",
  erlang = "erl",
  elixir = "ex",
  clojure = "clj",
  haskell = "hs",
}

-- Language-specific dependency files
M.dependencies = {
  cpp = {
    { src = "lc_includes.h", dst = "lc_includes.h" },
    { src = ".clangd", dst = ".clangd" },
    { src = ".clang-format", dst = ".clang-format" },
    { src = ".clang-tidy", dst = ".clang-tidy" },
  },
  python = {
    { src = "lc_includes.py", dst = "lc_includes.py" },
    { src = "pyproject.toml", dst = "pyproject.toml" },
  },
  java = {
    { src = "LCIncludes.java", dst = "LCIncludes.java" },
    { src = "checkstyle.xml", dst = "checkstyle.xml" },
  },
  javascript = {
    { src = "lc_includes.js", dst = "lc_includes.js" },
    { src = ".eslintrc.js", dst = ".eslintrc.js" },
    { src = "tsconfig.json", dst = "tsconfig.json" },
  },
  go = {
    { src = "lc_includes.go", dst = "lc_includes.go" },
    { src = ".golangci.yml", dst = ".golangci.yml" },
  },
  rust = {
    { src = "lc_includes.rs", dst = "lc_includes.rs" },
    { src = ".rustfmt.toml", dst = ".rustfmt.toml" },
  },
  swift = {
    { src = "LCIncludes.swift", dst = "LCIncludes.swift" },
    { src = ".swiftlint.yml", dst = ".swiftlint.yml" },
  },
  csharp = {
    { src = "LCIncludes.cs", dst = "LCIncludes.cs" },
    { src = ".editorconfig", dst = ".editorconfig" },
  },
}

-- Language-specific file headers
M.headers = {
  cpp = '#include "lc_includes.h"\n\n',
  python = "from lc_includes import *\n\n",
  java = "import java.util.*;\n\n",
  javascript = "// No special imports needed for JavaScript\n\n",
  go = 'package main\n\nimport (\n\t"fmt"\n)\n\n',
  rust = "mod lc_includes;\nuse lc_includes::*;\n\n",
  swift = "import Foundation\n\n",
  csharp = "using System;\nusing System.Collections.Generic;\n\n",
}

-- Comment style based on language
M.comment_styles = {
  cpp = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  python = {
    start = "'''\n",
    line_prefix = "",
    end_prefix = "",
    close = "\n'''",
  },
  java = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  javascript = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  go = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  rust = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  swift = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  csharp = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  ruby = {
    start = "=begin ",
    line_prefix = "",
    end_prefix = "",
    close = " =end",
  },
  kotlin = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  php = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  dart = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  scala = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  c = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  objective_c = {
    start = "/* ",
    line_prefix = "* ",
    end_prefix = "",
    close = " */",
  },
  erlang = {
    start = "%% ",
    line_prefix = "%% ",
    end_prefix = "%%",
    close = "",
  },
  elixir = {
    start = "#",
    line_prefix = "# ",
    end_prefix = "#",
    close = "",
  },
  clojure = {
    start = ";; ",
    line_prefix = ";; ",
    end_prefix = ";;",
    close = "",
  },
  haskell = {
    start = "{- ",
    line_prefix = "",
    end_prefix = "",
    close = " -}",
  },
}

return M
