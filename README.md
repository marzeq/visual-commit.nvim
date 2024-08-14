# visual-commit.nvim

a neovim plugin that provides a UI for creating git commits. still very WIP, expect bugs and weird behaviour

## installation

using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "marzeq/visual-commit.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim", -- required by telescope
  },
  opts = {}, -- no configuration yet, but this is for when there is one
},
```

## usage

the commit window can be launched in two ways:

1. using the `:VisualCommit` command
2. by running `require('visual-commit').commit()` in lua

you can use these to create a keybinding for the commit window:

```lua
{
  -- ... plugin table
  keys = {
    { "<leader>c", require("visual-commit").commit, desc = "Create a git commit" },
    -- OR
    { "<leader>c", ":VisualCommit<CR>", desc = "Create a git commit" },
  },
},
```

## features

- [x] add a simple menu that allows for selecting the files to stage and inputting the commit message
- [ ] somehow visually separating the already staged, unstaged, and untracked files
- [ ] allow for amending commits
- [ ] add an optional second screen that shows the diff and asks for confirmation
- [ ] passing on arguments to `git commit` in the opts/method arguments

### known bugs/limitations

- when commit signing is enabled and the ncurses dialog is used, it may screw up the terminal

## credits

- [nvim-telescope/telescope.nvim](telescope.nvim) for the input UI framework
- [ellisonleao/nvim-plugin-template](https://github.com/ellisonleao/nvim-plugin-template) for the plugin template

## license & usage

licensed under MIT (see [LICENSE](LICENSE))

if you plan on using this plugin in a distribution, i would appreciate it if you let me know and credited me properly

