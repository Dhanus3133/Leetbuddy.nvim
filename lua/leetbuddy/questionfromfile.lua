local directory = require("leetbuddy.config").directory
local qr = require("leetbuddy.questionrender")
local question = require("leetbuddy.question")
local utils = require("leetbuddy.utils")

function is_in_folder(file, folder)
  return string.sub(file, 1, string.len(folder)) == folder
end

function get_question_slug(file)
  return string.gsub(string.gsub(file, "^%d+%-", ""), "%.[^.]+$", "")
end

local function setup_vim_commands()
  if is_in_folder(vim.api.nvim_buf_get_name(0), directory) then
    local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")

    local question_slug = get_question_slug(file)
    if previous_question_slug ~= question_slug then
      question_content = utils.split_string_to_table(qr.question(question_slug))
    end

    previous_question_slug = question_slug
    question.question_display(question_content, qbufnr)
  end
end

local function lc_question(p)
  P(tonumber(p["args"]))
  -- local number = tonumber(args[1])
  -- if number then
  --   print("LCQuestion: input number is " .. number)
  -- else
  --   print("LCQuestion: please specify a number")
  -- end
end

-- Create the command
-- vim.api.nvim_create_user_command("LCTest", lc_question, { bang = false })
vim.api.nvim_create_user_command("LCTest", lc_question, { nargs = 1, bang = false })

vim.api.nvim_create_user_command("LCQuestion", setup_vim_commands, { bar = true })
-- vim.api.nvim_create_user_command("LCTest", lc_test, { nargs = 1, bar = true })
