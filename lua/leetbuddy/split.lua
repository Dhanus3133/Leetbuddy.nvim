local M = {}

local utils = require("leetbuddy.utils")
local code_buffer = vim.api.nvim_get_current_buf()
local input_buffer
local results_buffer

function M.split()
  local code_path = vim.api.nvim_buf_get_name(code_buffer)

  if input_buffer ~= nil then
    return
  end

  input_buffer = vim.api.nvim_create_buf(false, false)
  results_buffer = vim.api.nvim_create_buf(false, false)

  vim.api.nvim_buf_set_option(input_buffer, "swapfile", false)
  vim.api.nvim_buf_set_option(input_buffer, "buflisted", false)

  vim.api.nvim_buf_set_option(results_buffer, "swapfile", false)
  vim.api.nvim_buf_set_option(results_buffer, "buflisted", false)
  vim.api.nvim_buf_set_option(results_buffer, "buftype", "nofile")
  vim.api.nvim_buf_set_option(results_buffer, "filetype", "Results")

  vim.api.nvim_buf_call(code_buffer, function()
    vim.cmd("vsplit " .. utils.get_input_file_path(code_path))
  end)

  vim.api.nvim_buf_call(input_buffer, function()
    vim.cmd("split +buffer" .. results_buffer)
  end)

  vim.api.nvim_buf_call(code_buffer, function()
    vim.cmd("vertical resize 100")
  end)

  vim.api.nvim_buf_call(results_buffer, function()
    vim.cmd("set nonumber")
    vim.cmd("set norelativenumber")
    local highlights = {
      -- [""] = "TabLineSel IncSearch",
      ["Results"] = "TabLineFill",
      [".* Error.*"] = "StatusLine",
      ["Accepted"] = "DiffAdd",
      ["Passed Cases"] = "DiffAdd",
      ["Total Cases"] = "DiffAdd",
      ["Failed Case Input"] = "ErrorMsg",
      ["Failed Cases"] = "ErrorMsg",
      ["Wrong Answer"] = "ErrorMsg",
      ["Failed"] = "ErrorMsg",
      ["Test Case: #\\d\\+"] = "Title",
      [".*Line.*"] = "ErrorMsg",
      ["Memory: .*"] = "Title",
      ["Runtime: .*"] = "Title",
      ["Expected"] = "Type",
      ["Output"] = "Type",
      ["Std Output"] = "Type",
      ["Expected Std Output"] = "Type",
    }
    for match, group in pairs(highlights) do
      vim.fn.matchadd(group, match)
    end
  end)

  vim.api.nvim_exec([[ autocmd VimResized * lua vim.cmd("vertical resize 100") ]], true)
end

function M.get_results_buffer()
  if results_buffer == nil then
    M.split()
  end
  return results_buffer
end

return M
