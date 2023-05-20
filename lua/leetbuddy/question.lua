M = {}

local utils = require("leetbuddy.utils")

local old_contents

function M.question_display(contents, oldqbufnr)
  qbufnr = oldqbufnr or vim.api.nvim_create_buf(true, true)

  local width = math.ceil(math.min(vim.o.columns, math.max(90, vim.o.columns - 20)))
  local height = math.ceil(math.min(vim.o.lines, math.max(25, vim.o.lines - 10)))

  local row = math.ceil(vim.o.lines - height) * 0.5 - 1
  local col = math.ceil(vim.o.columns - width) * 0.5 - 1

  vim.api.nvim_open_win(qbufnr, true, {
    border = "rounded",
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
  })

  contents = utils.pad(contents, { pad_top = 1 })
  if not oldqbufnr then
    vim.api.nvim_buf_set_lines(qbufnr, 0, -1, true, contents)
    vim.api.nvim_buf_set_option(qbufnr, "swapfile", false)
    vim.api.nvim_buf_set_option(qbufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(qbufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(qbufnr, "buflisted", false)
    vim.api.nvim_buf_set_keymap(qbufnr, "n", "<esc>", "<cmd>hide<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(qbufnr, "n", "q", "<cmd>hide<CR>", { noremap = true })
  end

  vim.api.nvim_buf_set_keymap(qbufnr, "v", "q", "<cmd>hide<CR>", { noremap = true })
  if contents ~= old_contents then
    vim.api.nvim_buf_set_option(qbufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(qbufnr, 0, -1, true, contents)
    vim.api.nvim_buf_set_option(qbufnr, "modifiable", false)
  end

  old_contents = contents

  return qbufnr
end

return M
