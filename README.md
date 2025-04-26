# nvim‑leetcode

_A distraction‑free way to fetch, read and solve LeetCode problems **inside Neovim**._

> **Note** – This plugin **does not compile or run your code** against LeetCode’s judge.
> If you need in‑editor execution and submission, check out
> [`kawre/leetcode.nvim`](https://github.com/kawre/leetcode.nvim).

---

## Features

- Pull the entire public LeetCode problem set into a local JSON cache
- Open a problem description side‑by‑side with starter code – **one command, one tab**
- Highlighted, nicely wrapped markdown with optional inline images<sup>†</sup>
- Per‑problem solution folder with automatic versioning (`Solution_1.cpp`, `Solution_2.cpp`, …)
- Metadata comment (difficulty, tags, your own tags) folded at the bottom of every file

<sup>†</sup> Images render only if you use a _Kitty‑protocol_ terminal and have [`image.nvim`](https://github.com/3rd/image.nvim) installed; otherwise we show lightweight placeholders.

---

## Installation

### lazy.nvim

```lua
{
  "paulburgess1357/nvim-leetcode",
  config = function()
    require("nvim-leetcode").setup()
  end,
}
```

### packer.nvim

```lua
use({
  "paulburgess1357/nvim-leetcode",
  config = function()
    require("nvim-leetcode").setup()
  end,
})
```

---

## Configuration

All options (with defaults) – copy the block and tweak what you need:

```lua
require("nvim-leetcode").setup({
  ---------------------------------------------------------------------------
  -- Core
  ---------------------------------------------------------------------------
  default_language      = "cpp",   -- any of: cpp, python, java, javascript, go …
  cache_dir             = vim.fn.expand("~/.cache/nvim-leetcode"),
  cache_subdir          = "meta",
  cache_file            = "leetcode_cache.json",
  cache_expiry_days     = 14,
  solutions_subdir      = "solutions",
  images_subdir         = "images",
  description_split     = 0.35,   -- left/right split ratio (0‑1)

  ---------------------------------------------------------------------------
  -- Display Tweaks
  ---------------------------------------------------------------------------
  enable_custom_wrap    = true,   -- hard‑wrap description text
  custom_wrap_offset    = 0.02,
  colors = {                     -- change any of these to suit your colourscheme
    problem_title           = "#ff7a6c",
    problem_section         = "#d8a657",
    problem_constraints     = "#89b482",
    problem_constraint_num  = "#d8a657",
    problem_followup        = "#d8a657",
    problem_example         = "#a9b665",
    problem_bullet          = "#d3869b",
    problem_input           = "#d19a66",
    problem_output          = "#98c379",
    problem_explanation     = "#e5c07b",
    problem_math            = "#d3869b",
    problem_number          = "#d8a657",
    problem_superscript     = "#d8a657",
    problem_variable        = "#7daea3",
    problem_code_block      = "#e6c07a",

    metadata_line           = "#d8a657",
    difficulty_line         = "#a9b665",
    tags_line               = "#7daea3",
    user_tags_line          = "#e78a4e",
  },

  ---------------------------------------------------------------------------
  -- Metadata section
  ---------------------------------------------------------------------------
  include_problem_metadata = true,
  include_leetcode_tags    = true,
  include_user_tags        = true,
  metadata_at_bottom       = true,
  metadata_comment_style   = "multi", -- "multi" | "single"

  ---------------------------------------------------------------------------
  -- Images (Kitty only)
  ---------------------------------------------------------------------------
  enable_images            = true,
  image_terminals          = { { var = "TERM", match = "kitty" }, { var = "KITTY_WINDOW_ID" } },
  notify_on_image_support  = true,
  use_direct_urls          = true,
  image_render_delay       = 100, -- ms
  image_max_width          = nil, -- fixed px; nil → auto
  image_max_height         = 20,
  image_max_width_pct      = 40,  -- relative to window (%)
  image_max_height_pct     = 30,
  image_right_after_separator = true,
  image_preserve_aspect_ratio = true,
  image_auto_render_on_win_focus = true,

  ---------------------------------------------------------------------------
  -- Code‑block markers in descriptions
  ---------------------------------------------------------------------------
  code_block_start         = "{",
  code_block_end           = "}",
  code_block_color         = "#e6c07a",
  code_block_style         = "italic",
})
```

### Language identifier

`default_language` accepts the LeetCode _slug_ for the language you want your starter code in:

| Value          | Language        | File extension |
| -------------- | --------------- | -------------- |
| `"cpp"`        | C++17/20/23     | `.cpp`         |
| `"python"`     | Python 3        | `.py`          |
| `"java"`       | Java 17         | `.java`        |
| `"javascript"` | ECMAScript 2021 | `.js`          |
| `"go"`         | Go 1.20         | `.go`          |
| …and more      |                 |                |

---

## Usage

| Command        | Action                                                     |
| -------------- | ---------------------------------------------------------- |
| `:LC Pull`     | (re‑)download the full problem list into the cache         |
| `:LC <number>` | Open Problem – if the cache is stale it is refreshed first |

### Typical workflow 📚 (no execution, just editing)

1. `:LC Pull` – fetch metadata (run again occasionally to refresh)
2. `:LC 1` – opens “**Two Sum**” in a new tab: left‑pane description, right‑pane `Solution_1.cpp`
3. Solve the problem locally, build / test with your own tools
4. Need another attempt? Run `:LC 1` again and you’ll get `Solution_2.cpp`
5. Grep or Telescope through `solutions/` when you want to revisit old work

---

## File Layout

```
~/.cache/nvim-leetcode/
├── meta/
│   └── leetcode_cache.json
└── solutions/
    └── LC1_Two_Sum/
        ├── Solution_1.cpp
        ├── Solution_2.cpp
        ├── lc_includes.h -> symlink to plugin/dependencies
        └── .clang-format
```

_(Example for C++ – other languages get their own helper files.)_

---

## Requirements

- **Neovim ≥ 0.8**
- `curl` in your `$PATH`
- _(optional)_ [**image.nvim**](https://github.com/3rd/image.nvim) **+** a terminal that supports the [Kitty graphics protocol](https://sw.kovidgoyal.net/kitty/graphics‑protocol/) for inline images.

---

## License

[The Unlicense](https://unlicense.org/) – public domain, no strings attached.

---

## Screenshots

_(coming soon)_

>
