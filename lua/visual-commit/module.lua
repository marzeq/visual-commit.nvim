local function get_git_files()
  local handle_m = io.popen("git ls-files -m")
  --- @type string
  local modified_files
  if handle_m ~= nil then
    modified_files = handle_m:read("*a")
    handle_m:close()
  else
    modified_files = ""
  end

  local handle_s = io.popen("git diff --name-only --cached")
  --- @type string
  local staged_files
  if handle_s ~= nil then
    staged_files = handle_s:read("*a")
    handle_s:close()
  else
    staged_files = ""
  end

  local handle_u = io.popen("git ls-files --others --exclude-standard")
  --- @type string
  local untracked_files
  if handle_u ~= nil then
    untracked_files = handle_u:read("*a")
    handle_u:close()
  else
    untracked_files = ""
  end

  return {
    modified = vim.split(modified_files, "\n", { trimempty = true }),
    staged = vim.split(staged_files, "\n", { trimempty = true }),
    untracked = vim.split(untracked_files, "\n", { trimempty = true }),
  }
end

local is_git_directory = function()
  local handle = io.popen("git rev-parse --is-inside-work-tree")
  local result = handle:read("*a")
  handle:close()

  return result == "true\n"
end

---@class GitCommit
local M = {}

M.commit = function()
  if not is_git_directory() then
    vim.notify("Not a git repository", vim.log.levels.ERROR)
    return
  end

  local files = get_git_files()

  local modified = files.modified
  local staged = files.staged
  local untracked = files.untracked

  local git_files = vim.tbl_flatten({ modified, staged, untracked })

  if #git_files == 0 then
    vim.notify("No files to commit", vim.log.levels.INFO)
  end

  local finders = require("telescope.finders")
  local pickers = require("telescope.pickers")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  pickers
    .new({
      prompt_title = "Commit message",
      results_title = "Files to be commited",
      layout_config = {
        width = 0.5,
        height = 0.5,
      },
    }, {
      finder = finders.new_table({
        results = git_files,
      }),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          local selection = action_state.get_current_picker(prompt_bufnr):get_multi_selection()
          local commit_message = action_state.get_current_line()
          actions.close(prompt_bufnr)

          local files_to_commit = {}

          for _, file in ipairs(selection) do
            table.insert(files_to_commit, file.value)
          end

          if #files_to_commit == 0 then
            vim.notify("No files selected", vim.log.levels.ERROR)
            return
          end

          if #commit_message == 0 then
            vim.notify("Commit message cannot be empty", vim.log.levels.ERROR)
            return
          end

          local git_add_command = { "git", "add" }
          vim.list_extend(git_add_command, files_to_commit)
          local add_output = vim.system(git_add_command):wait()

          if add_output.code ~= 0 then
            vim.notify("Error staging files", vim.log.levels.ERROR)
            return
          end

          local git_commit_command = { "git", "commit", "-m", commit_message }
          local commit_output = vim.system(git_commit_command):wait()

          if commit_output.code ~= 0 then
            vim.notify(
              "Error committing files:\n" .. commit_output.stdout .. commit_output.stderr,
              vim.log.levels.ERROR
            )
            return
          end

          vim.notify("Files committed:\n" .. commit_output.stdout .. commit_output.stderr, vim.log.levels.INFO)
        end)
        return true
      end,
    })
    :find()
end

return M
