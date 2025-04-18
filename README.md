# nvim-leetcode

A lightweight, distraction-free Neovim plugin for viewing and solving LeetCode problems in your favorite editor. This focused plugin provides clean problem descriptions with syntax highlighting and solution templates, letting you concentrate on algorithmic thinking without leaving your editor workflow.

**Note:** This plugin is designed for offline problem viewing and solution development only. It does not execute code against LeetCode test cases or support premium problems. For a more feature-rich alternative with test execution capabilities, consider [leetcode.nvim](https://github.com/kawre/leetcode.nvim).

TODO: Add screenshots with kitty terminal

## Features

- Fetch LeetCode problem metadata and cache it locally
- Open problem descriptions with syntax highlighting
- Automatically fetch problem-specific starter code
- Track multiple solution attempts per problem
- Support for C++ (default, configurable)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "paulburgess1357/nvim-leetcode",
  config = function()
    require("nvim-leetcode").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "paulburgess1357/nvim-leetcode",
  config = function()
    require("nvim-leetcode").setup()
  end
}
```

## Configuration

You can customize the plugin by passing options to the setup function:

```lua
require("nvim-leetcode").setup({
  -- Default language for solutions
  default_language = "cpp", -- Options: "cpp", "java", "python", "python3", etc.

  -- XDG-compliant paths
  cache_dir = vim.fn.expand("~/.cache/nvim-leetcode"),

  -- Cache expiry in days
  cache_expiry_days = 14,

  -- Split ratio for description window
  description_split = 0.35,
})
```

## Usage

### Commands

- `:LC Pull` - Fetch and cache the full list of LeetCode problems
- `:LC <number>` - Open the problem with the specified number

### Example Workflow

1. Pull the problem list: `:LC Pull`
2. Open a problem: `:LC 1`
3. The plugin will open a split view with the problem description on the left and solution code on the right
4. Start coding your solution in the right pane
5. When you want to attempt another solution, run `:LC 1` again to create a new solution file

## Where Files Are Stored

- Problem metadata: `~/.cache/nvim-leetcode/meta/`
- Solutions: `~/.cache/nvim-leetcode/solutions/LC{number}_{title}/`

## Requirements

- Neovim >= 0.7.0
- curl (used for API requests)

## License

The Unlicense
