local directory = require('leetbuddy.config').directory
local qr = require 'leetbuddy.questionrender'
local question = require 'leetbuddy.question'
local utils = require 'leetbuddy.utils'

local M = {}

function M.question()
  if utils.is_in_folder(vim.api.nvim_buf_get_name(0), directory) then
    local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':t')

    local question_slug = utils.get_question_slug(file)
    if previous_question_slug ~= question_slug then
      question_content = utils.split_string_to_table(qr.question(question_slug))
    end

    previous_question_slug = question_slug
    question.question_display(question_content, qbufnr)
  end
end

return M
