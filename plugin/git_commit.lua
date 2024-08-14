vim.api.nvim_create_user_command("Commit", require("git_commit").commit, {})
