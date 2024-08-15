---
---@param args string[]
---@param env table<string, string>|nil
---@return vim.SystemCompleted
local function run_command(args, env)
  if env == nil then
    env = {}
  end
  return vim.system(args):wait()
end

local function get_git_files()
  local modified_files = run_command({ "git", "ls-files", "-m" }).stdout
  local staged_files = run_command({ "git", "diff", "--name-only", "--cached" }).stdout
  local untracked_files = run_command({ "git", "ls-files", "--others", "--exclude-standard" }).stdout

  if modified_files == nil then
    modified_files = ""
  end
  if staged_files == nil then
    staged_files = ""
  end
  if untracked_files == nil then
    untracked_files = ""
  end

  return {
    modified = vim.split(modified_files, "\n", { trimempty = true }),
    staged = vim.split(staged_files, "\n", { trimempty = true }),
    untracked = vim.split(untracked_files, "\n", { trimempty = true }),
  }
end

local function is_git_directory()
  local result = run_command({ "git", "rev-parse", "--is-inside-work-tree" }).stdout

  if result == nil then
    return false
  end

  return result == "true\n"
end

local function string_to_args(input)
  local args = {}
  local in_single_quotes = false
  local in_double_quotes = false
  local current_arg = ""

  for i = 1, #input do
    local char = input:sub(i, i)

    if char == '"' and not in_single_quotes then
      in_double_quotes = not in_double_quotes
    elseif char == "'" and not in_double_quotes then
      in_single_quotes = not in_single_quotes
    elseif char == " " and not in_single_quotes and not in_double_quotes then
      if #current_arg > 0 then
        table.insert(args, current_arg)
        current_arg = ""
      end
    else
      current_arg = current_arg .. char
    end
  end

  if #current_arg > 0 then
    table.insert(args, current_arg)
  end

  return args
end

---@class GitCommit
local M = {}

---@param git_commit_args_unknown string|string[]
M.commit = function(git_commit_args_unknown)
  local git_commit_args
  if type(git_commit_args_unknown) == "string" then
    git_commit_args = string_to_args(git_commit_args_unknown)
  elseif type(git_commit_args_unknown) == "table" then
    git_commit_args = vim.tbl_map(function(arg)
      return tostring(arg)
    end, git_commit_args_unknown)
  elseif git_commit_args_unknown == nil then
    git_commit_args = {}
  else
    vim.notify("Invalid argument type", vim.log.levels.ERROR)
    return
  end

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
          local add_output = run_command(git_add_command)

          if add_output.code ~= 0 then
            vim.notify("Error staging files", vim.log.levels.ERROR)
            return
          end

          local git_commit_command = { "git", "commit", "-m", commit_message }
          vim.list_extend(git_commit_command, git_commit_args)
          local commit_output = run_command(git_commit_command)

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
