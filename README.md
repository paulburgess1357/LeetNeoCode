# nvim-leetcode (UNDER CONSTRUCTION!!)

A lightweight, distraction-free Neovim plugin for viewing and writing LeetCode code in your favorite editor.

**Note:** This plugin is designed for offline problem viewing and solution development only. It does not execute code against LeetCode test cases or support premium problems. For a more feature-rich alternative with test execution capabilities, consider [leetcode.nvim](https://github.com/kawre/leetcode.nvim).

TODO: Add screenshots with kitty terminal

## Features

- Fetch LeetCode problem metadata and cache it locally
- Open problem descriptions with syntax highlighting
- Automatically fetch problem-specific starter code
- Track multiple solution attempts per problem
- Includes problem metadata, difficulty level, and LeetCode tags
- Support for user-defined tags for personal organization
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

  -- Metadata and tags configuration
  include_problem_metadata = true,     -- Include problem metadata
  include_leetcode_tags = true,        -- Include LeetCode tags
  include_user_tags = true,            -- Include user tags section
  metadata_at_bottom = true,           -- Put metadata at the bottom of the file
  metadata_comment_style = "multi",    -- Use multiline comment style
})
```

## Usage

### Commands

- `:LC Pull` - Fetch and cache the full list of LeetCode problems
- `:LC <number>` - Open the problem with the specified number

### Searching by Tags

To search for problems by tag, you can use standard Vim/Neovim commands:

```vim
" Search for problems with the "Dynamic Programming" tag
:grep -r "LC Tags:.*Dynamic Programming" --include="Solution_*.cpp" ~/.cache/nvim-leetcode/solutions

" Search for problems with user tags containing "Favorite"
:grep -r "User Tags:.*Favorite" --include="Solution_*.cpp" ~/.cache/nvim-leetcode/solutions

" Use Telescope for a nicer UI (if you have Telescope installed)
:Telescope grep_string search="LC Tags:.*Array"
```

### Example Workflow

1. Pull the problem list: `:LC Pull`
2. Open a problem: `:LC 1`
3. The plugin will open a split view with the problem description on the left and solution code on the right
4. Start coding your solution in the right pane
5. When you want to attempt another solution, run `:LC 1` again to create a new solution file

### Working with Tags and Metadata

Each solution file includes problem metadata and tags in a folded comment section at the bottom:

```cpp
#include "lc_includes.h"

class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        // Your solution here
    }
};

/*{{{
* Problem: LC#1 Two Sum
* Difficulty: Easy
* LC Tags: Array, Hash Table
* User Tags:
}}}*/
```

- **Viewing metadata**: Use `zo` to open the folded section at the bottom of the file
- **Adding user tags**: Open the fold and add your own tags on the "User Tags:" line
- **Searching by tag**: Use grep or your editor's search functionality to find problems by tag

## Where Files Are Stored

- Problem metadata: `~/.cache/nvim-leetcode/meta/`
- Solutions: `~/.cache/nvim-leetcode/solutions/LC{number}_{title}/`

## Keyboard Shortcuts

You can add these mappings to your Neovim configuration:

```lua
-- LeetCode Pull problems
vim.keymap.set("n", "<leader>ll", "<cmd>LC Pull<cr>", { desc = "LeetCode: Pull problems" })

-- LeetCode Open problem
vim.keymap.set("n", "<leader>lp", function()
  -- Prompt for a problem number
  vim.ui.input({ prompt = "Problem Number: " }, function(input)
    if input and input:match("^%d+$") then
      vim.cmd("LC " .. input)
    end
  end)
end, { desc = "LeetCode: Open problem" })

-- Search for problems by tag
vim.keymap.set("n", "<leader>lt", function()
  vim.ui.input({ prompt = "Search for tag: " }, function(input)
    if input and input ~= "" then
      -- Search in solutions directory
      vim.cmd('grep -r "LC Tags:.*' .. input .. '" --include="Solution_*.cpp" ' ..
              vim.fn.expand("~/.cache/nvim-leetcode/solutions"))
    end
  end)
end, { desc = "LeetCode: Search by tag" })
```

## Requirements

- Neovim >= 0.7.0
- curl (used for API requests)

## License

The Unlicense
