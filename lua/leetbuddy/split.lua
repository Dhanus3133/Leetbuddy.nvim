local M = {}

local utils = require("leetbuddy.utils")

function M.split()
  local code_buffer = vim.api.nvim_get_current_buf()
  local code_path = vim.api.nvim_buf_get_name(code_buffer)

  local input_buffer = vim.api.nvim_create_buf(false, false)
  local results_buffer = vim.api.nvim_create_buf(false, false)

  vim.api.nvim_buf_set_option(input_buffer, "swapfile", false)
  vim.api.nvim_buf_set_option(input_buffer, "modifiable", false)
  vim.api.nvim_buf_set_option(input_buffer, "buftype", "nofile")
  vim.api.nvim_buf_set_option(input_buffer, "buflisted", false)
  vim.api.nvim_buf_set_option(input_buffer, "buftype", "nofile")

  vim.api.nvim_buf_set_option(results_buffer, "swapfile", false)
  vim.api.nvim_buf_set_option(results_buffer, "modifiable", false)
  vim.api.nvim_buf_set_option(results_buffer, "buftype", "nofile")
  vim.api.nvim_buf_set_option(results_buffer, "buflisted", false)
  vim.api.nvim_buf_set_option(results_buffer, "buftype", "nofile")

  vim.api.nvim_buf_call(code_buffer, function()
    vim.cmd("vsplit " .. utils.get_input_file_path(code_path))
  end)

  vim.api.nvim_buf_call(input_buffer, function()
    vim.cmd("split")
  end)

  vim.api.nvim_buf_call(code_buffer, function()
    vim.cmd("vertical resize 100")
  end)
end

return M
