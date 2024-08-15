# visual-commit.nvim

a neovim plugin that provides a UI for creating git commits. still very WIP, expect bugs and weird behaviour

## why use this?

you see, you probably shouldn't. vim fugitive is miles better and more feature-rich. i just wanted to make my first plugin and this seemed like a good idea,
and also because i don't need all the features of vim fugitive, just a simple way to stage files and write a commit message

## preview

![image](https://github.com/user-attachments/assets/8c46d462-b3f9-4140-aaf1-88adb1769765)


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

additional arguments to `git commit` can be passed in the command like so:

- `:VisualCommit --amend` will add the `--amend` flag to the `git commit` command
- `require('visual-commit').commit("--amend")` or `require('visual-commit').commit({ "--amend" })` will do the same in lua

## features

- [x] add a simple menu that allows for selecting the files to stage and inputting the commit message
- [ ] somehow visually separating the already staged, unstaged, and untracked files
- [ ] add an optional second screen that shows the diff and asks for confirmation
- [x] passing on arguments to `git commit` in the command/method arguments
- [ ] default arguments for `git commit` in opts

### known bugs/limitations

- when commit signing is enabled and the ncurses dialog is used, it may screw up the terminal

## credits

- [nvim-telescope/telescope.nvim](telescope.nvim) for the input UI framework
- [ellisonleao/nvim-plugin-template](https://github.com/ellisonleao/nvim-plugin-template) for the plugin template

## license & usage

licensed under MIT (see [LICENSE](LICENSE))

if you plan on using this plugin in a distribution, i would appreciate it if you let me know and credited me properly

