vim.api.nvim_create_user_command("VisualCommit", function(opts)
  require("visual-commit.module").commit(opts.args)
end, {
  nargs = "*",
})
