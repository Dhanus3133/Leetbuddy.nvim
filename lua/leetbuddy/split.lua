local M = {}

local config = require("leetbuddy.config")
local utils = require("leetbuddy.utils")
local cn = require("leetbuddy.display").cn

local input_buffer
local results_buffer

function M.split()
  local code_buffer = vim.api.nvim_get_current_buf()
  local code_path = vim.api.nvim_buf_get_name(code_buffer)
  local lang = config.get_lang_by_extension(config.language)
  local folder = lang:get_folder(code_path)

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
    vim.cmd("botright vsplit " .. lang:get_input_file_path(folder))
  end)

  vim.api.nvim_buf_call(input_buffer, function()
    vim.cmd("rightbelow split +buffer" .. results_buffer)
  end)

  vim.api.nvim_buf_call(code_buffer, function()
    vim.cmd("vertical resize 100")
  end)

  vim.api.nvim_buf_call(results_buffer, function()
    vim.cmd("set nonumber")
    vim.cmd("set norelativenumber")
    local highlights = {
      -- [""] = "TabLineSel IncSearch",
      [".* Error.*"] = "StatusLine",
      [".*Line.*"] = "ErrorMsg",
    }
    local extra_highlights

    if config.domain == "cn" then
      extra_highlights = {
        [cn["res"]] = "TabLineFill",
        [cn["acc"]] = "DiffAdd",
        [cn["pc"]] = "DiffAdd",
        [cn["totc"]] = "DiffAdd",
        [cn["f_case_in"]] = "ErrorMsg",
        [cn["wrong_ans_err"]] = "ErrorMsg",
        [cn["failed"]] = "ErrorMsg",
        [cn["testc"] .. ": #\\d\\+"] = "Title",
        [cn["mem"] .. ": .*"] = "Title",
        [cn["rt"] .. ": .*"] = "Title",
        [cn["exp"]] = "Type",
        [cn["out"]] = "Type",
        [cn["exp_out"]] = "Type",
        [cn["stdo"]] = "Type",
        [cn["exe"] .. "..."] = "Todo",
      }
    else
      extra_highlights = {
        ["Results"] = "TabLineFill",
        ["Accepted"] = "DiffAdd",
        ["Passed Cases"] = "DiffAdd",
        ["Total Cases"] = "DiffAdd",
        ["Failed Case Input"] = "ErrorMsg",
        ["Wrong Answer"] = "ErrorMsg",
        ["Failed"] = "ErrorMsg",
        ["Test Case: #\\d\\+"] = "Title",
        ["Memory: .*"] = "Title",
        ["Runtime: .*"] = "Title",
        ["Expected"] = "Type",
        ["Input"] = "Type",
        ["Output"] = "Type",
        ["Std Output"] = "Type",
        ["Executing..."] = "Todo",
      }
    end

    highlights = vim.tbl_deep_extend("force", highlights, extra_highlights)

    for match, group in pairs(highlights) do
      vim.fn.matchadd(group, match)
    end
  end)
end

function M.get_input_buffer()
  if input_buffer == nil then
    M.split()
  end
  return input_buffer
end

function M.get_results_buffer()
  return results_buffer
end

local function close_buffer_window(win)
  local num = vim.api.nvim_win_get_number(win) - 1
  vim.cmd(num .. "close")
end

function M.close_split()
  if input_buffer then
    vim.api.nvim_buf_call(input_buffer, function()
      close_buffer_window(vim.api.nvim_get_current_win())
    end)
  end
  if results_buffer then
    vim.api.nvim_buf_call(results_buffer, function()
      close_buffer_window(vim.api.nvim_get_current_win())
    end)
  end

  if utils.is_in_folder(vim.api.nvim_buf_get_name(0), config.directory) then
    local code_path = vim.api.nvim_buf_get_name(0)
    vim.cmd("silent! bd " .. code_path)
    vim.cmd("silent! bd " .. utils.get_input_file_path(code_path))
  end
  input_buffer = nil
  results_buffer = nil
end

return M
