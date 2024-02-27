local pickers = require "telescope.pickers"
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local finders = require "telescope.finders"
local previewers = require "telescope.previewers"
local putils = require "telescope.previewers.utils"
local conf = require("telescope.config").values
local make_entry = require "telescope.make_entry"
local utils = require "telescope.utils"
local popup = require "plenary.popup"

local function msgLoadingPopup(msg, cmd, complete_fn)
  local row = math.floor((vim.o.lines - 5) / 2)
  local width = 20 + #msg
  local col = math.floor((vim.o.columns - width) / 2)
  for _ = 1, (width - #msg) / 2, 1 do
    msg = " " .. msg
  end
  local prompt_win, prompt_opts = popup.create(msg, {
    border = {},
    borderchars = conf.borderchars,
    height = 5,
    col = col,
    line = row,
    width = width,
  })
  vim.api.nvim_win_set_option(prompt_win, "winhl", "Normal:TelescopeNormal")
  vim.api.nvim_win_set_option(prompt_win, "winblend", 0)
  local prompt_border_win = prompt_opts.border and prompt_opts.border.win_id
  if prompt_border_win then
    vim.api.nvim_win_set_option(prompt_border_win, "winhl", "Normal:TelescopePromptBorder")
  end
  vim.defer_fn(
    vim.schedule_wrap(function()
      local results = utils.get_os_command_output(cmd)
      if not pcall(vim.api.nvim_win_close, prompt_win, true) then
        log.trace("Unable to close window: ", prompt_win)
      end
      complete_fn(results)
    end),
    10
  )
end

local Job = require("plenary.job")
local open_bookmark = function(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    local tmp_table = vim.split(selection.value, "\t")
    if vim.tbl_isempty(tmp_table) then
      return
    end
    local id = tmp_table[1]
    local args = {
      "--nostdin",
      "-o",
      id,
    }
    Job:new({command = "buku", args = args}):start()
  end

return function(opts)
  opts = opts or {}

  local cmd = vim.tbl_flatten {
    "buku",
    "--nostdin",
    "-p",
    "-f",
    "5",
  }
  msgLoadingPopup("Loading bookmarks", cmd, function(results)
    if results[1] == "" then
      print("No bookmarks found")
      return
    end
    pickers.new(opts, {
      prompt_title = "<CR>: open url",
      finder = finders.new_table {
        results = results,
        entry_maker = make_entry.gen_from_string(opts),
      },
      layout_strategy = "vertical",
      layout_config = {
        preview_height = 0.15,
      },
      previewer = previewers.new_buffer_previewer {
        title = "Buku",
        teardown = function()end,

        get_buffer_by_name = function(_, entry)
          return entry.value
        end,

        define_preview = function(self, entry)
          local entry_cols = vim.split(entry.value, "\t")
          if vim.tbl_isempty(entry_cols) then
            return { "echo", "" }
          end
          local preview_cmd = {
            "buku",
            "--nostdin",
            "--nc",
            "-p",
            entry_cols[1],
          }
          putils.job_maker(preview_cmd, self.state.bufnr, {
            value = entry.value,
            bufname = self.state.bufname,
            cwd = opts.cwd,
          })
        end,
      },
      sorter = conf.file_sorter(opts),
      attach_mappings = function(_, map)
        actions.select_default:replace(open_bookmark)
        return true
      end,
    }):find()
  end)
end
