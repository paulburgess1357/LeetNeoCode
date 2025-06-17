# LeetNeoCode

A comprehensive Neovim plugin for LeetCode problem solving with advanced features including inline images, smart copy functionality, and extensive customization options.

## ✨ Features

- **📚 Problem Management**: Fetch and organize LeetCode problems with metadata
- **🖼️ Inline Images**: Display problem diagrams directly in Neovim (with image.nvim support)
- **🧩 Smart Copy**: Intelligent copying that excludes headers and metadata
- **📁 Solution Organization**: Automatic file organization with dependency management
- **🔍 Advanced Search**: Search solutions by keywords, recent activity, or random selection
- **🎨 Syntax Highlighting**: Custom highlighting for problem descriptions and code
- **📋 Fold Management**: Organized code folding with metadata sections
- **🔧 Multi-Language Support**: Support for 8+ programming languages

## 📋 Requirements

- Neovim 0.8+
- `curl` for API requests
- Optional: [image.nvim](https://github.com/3rd/image.nvim) for inline image support
- Optional: Kitty terminal or other image-capable terminal

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "your-username/LeetNeoCode",
  dependencies = {
    "3rd/image.nvim", -- Optional: for inline images
  },
  config = function()
    require("LeetNeoCode").setup({
      -- Configuration options
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "your-username/LeetNeoCode",
  requires = {
    "3rd/image.nvim", -- Optional
  },
  config = function()
    require("LeetNeoCode").setup()
  end
}
```

## ⚙️ Configuration

### Basic Setup

```lua
require("LeetNeoCode").setup({
  default_language = "cpp",
  code_only = false,
  enable_images = true,
  smart_copy = true,
})
```

### Advanced Configuration

```lua
require("LeetNeoCode").setup({
  -- Core Settings
  default_language = "cpp", -- cpp, python, java, javascript, go, rust, swift, csharp
  code_only = false, -- When true, only show code without description

  -- Storage Paths
  cache_dir = vim.fn.stdpath("cache") .. "/LeetNeoCode",
  cache_expiry_days = 14,
  recent_solutions_count = 10,
  random_solutions_count = 10,

  -- UI Layout
  description_split = 0.35, -- Fraction of tab width for description
  enable_custom_wrap = true,
  custom_wrap_offset = 0.02,

  -- Image Settings
  enable_images = true,
  render_image = true,
  use_direct_urls = true,
  image_max_height = 20,
  image_max_width_pct = 40,
  image_max_height_pct = 30,
  notify_on_image_support = true,

  -- Smart Copy
  smart_copy = true,
  smart_copy_color = "#34C759",

  -- Folding
  fold_marker_start = "▼",
  fold_marker_end = "▲",

  -- Colors (customize syntax highlighting)
  colors = {
    problem_title = "#ff7a6c",
    problem_section = "#d8a657",
    problem_example = "#a9b665",
    metadata_line = "#d8a657",
    difficulty_line = "#a9b665",
  },
})
```

## 🚀 Commands

### Core Commands

| Command        | Description                              |
| -------------- | ---------------------------------------- |
| `:LC Pull`     | Fetch and cache all LeetCode problems    |
| `:LC <number>` | Open problem by number (e.g., `:LC 1`)   |
| `:LC Copy`     | Copy current buffer with smart filtering |

### Solution Management

| Command            | Description                        |
| ------------------ | ---------------------------------- |
| `:LC Recent`       | Open most recent solution file     |
| `:LC Recent Store` | Update recent solutions directory  |
| `:LC Recent List`  | Show recent solutions notification |
| `:LC Random Store` | Update random solutions directory  |

### Search & Discovery

| Command                             | Description                  |
| ----------------------------------- | ---------------------------- |
| `:LC Keywords "keyword1, keyword2"` | Search solutions by keywords |

### Fold Management

| Command           | Description                       |
| ----------------- | --------------------------------- |
| `:LC Fold Open`   | Open all folds in current buffer  |
| `:LC Fold Close`  | Close all folds in current buffer |
| `:LC Fold Toggle` | Toggle fold under cursor          |

### Utility Commands

| Command       | Description                      |
| ------------- | -------------------------------- |
| `:LC Dismiss` | Dismiss all active notifications |

> **Note**: No-space versions of commands (e.g., `:LCPull`, `:LCCopy`, `:LCRecent`) are also available for convenience.

## 📖 Usage Examples

### Opening Problems

```vim
" Fetch all problems (do this first)
:LC Pull

" Open Two Sum problem
:LC 1

" Open Add Two Numbers problem
:LC 2
```

### Managing Solutions

```vim
" Open your most recent solution
:LC Recent

" Update recent solutions directory with 10 most recent
:LC Recent Store

" Show list of recent solutions
:LC Recent List

" Search for solutions containing specific keywords
:LC Keywords "binary search, tree"
```

### Working with Code

The plugin automatically sets up:

- **Language-specific templates** with imports and boilerplate
- **Dependency files** (headers, configs) via symlinks
- **Fold markers** for organizing code sections
- **Smart copy functionality** (if enabled)

## 🗂️ File Organization

The plugin organizes files in a structured format:

```
~/.cache/nvim/LeetNeoCode/
├── meta/
│   └── leetcode_cache.json        # Problem metadata
├── solutions/
│   ├── LC00001_Two_Sum/           # Zero-padded problem dirs
│   │   ├── Solution_1.cpp
│   │   ├── lc_includes.h          # Language dependencies
│   │   └── .clangd
│   └── LC00002_Add_Two_Numbers/
├── solutions_recent/              # Symlinks to recent solutions
├── solutions_random/              # Symlinks to random solutions
├── solutions_keywords/            # Keyword search results
└── images/                        # Cached problem images
```

## 🎨 Customization

### Language Support

Supported languages with full dependency management:

- **C++** (`.cpp`) - includes, clang configs
- **Python** (`.py`) - imports, pyproject.toml
- **Java** (`.java`) - imports, checkstyle
- **JavaScript** (`.js`) - configs, tsconfig
- **Go** (`.go`) - imports, golangci
- **Rust** (`.rs`) - mods, rustfmt
- **Swift** (`.swift`) - imports, swiftlint
- **C#** (`.cs`) - using statements, editorconfig

### Custom Key Mappings

```lua
-- Example custom mappings
vim.keymap.set('n', '<leader>lp', ':LC Pull<CR>', { desc = 'Pull LeetCode problems' })
vim.keymap.set('n', '<leader>lr', ':LC Recent<CR>', { desc = 'Open recent solution' })
vim.keymap.set('n', '<leader>lc', ':LC Copy<CR>', { desc = 'Smart copy solution' })
```

### Smart Copy Features

When `smart_copy = true`, the plugin:

- Automatically removes language headers/imports
- Excludes metadata comments from copied content
- Provides visual feedback with highlighting
- Works with all yank operations (`y`, `yy`, `Y`)
- Supports both visual and normal mode copying

## 🖼️ Image Support

### Terminal Compatibility

The plugin automatically detects image-capable terminals:

- **Kitty** - Full support
- **iTerm2** - Experimental support
- Others - Text placeholders

### Image Configuration

```lua
{
  enable_images = true,
  image_max_height = 20,
  image_max_width_pct = 40,
  image_max_height_pct = 30,
  use_direct_urls = true, -- Skip local caching
}
```

## 🔧 Advanced Features

### Recent Solutions Management

```vim
" Update recent solutions (creates symlinks)
:LC Recent Store

" View recent solutions list
:LC Recent List

" Open most recent solution directly
:LC Recent
```

### Keyword Search

```vim
" Search for solutions containing specific terms
:LC Keywords "dynamic programming, memoization"

" Results appear as symlinks in solutions_keywords/
```

### Fold Management

The plugin sets up automatic folding:

- Metadata sections are foldable
- Custom fold markers (`▼` and `▲` by default)
- Automatic fold setup for solution files
- Commands for bulk fold operations

## 🐛 Troubleshooting

### Common Issues

1. **No problems found**: Run `:LC Pull` first to fetch problem data
2. **Images not displaying**: Check terminal compatibility and image.nvim setup
3. **Dependencies missing**: Ensure symlinks are working in your environment
4. **Cache issues**: Delete `~/.cache/nvim/LeetNeoCode/` and re-run `:LC Pull`

### Debug Commands

```vim
" Check configuration
:lua print(vim.inspect(require("LeetNeoCode").config))

" Verify cache location
:echo stdpath('cache') . '/LeetNeoCode'

" Test image support
:lua print(require("LeetNeoCode").images.is_terminal_supported())
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- LeetCode for providing the platform and API
- [image.nvim](https://github.com/3rd/image.nvim) for image rendering capabilities
- The Neovim community for inspiration and support
