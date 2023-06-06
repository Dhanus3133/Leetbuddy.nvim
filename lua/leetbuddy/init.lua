local M = {}

M.user_config = require("leetbuddy.default_config")

local function create_cmds(config)
  local questions, todayQuestion
  if config["domain"] == "cn" then
    questions = require("leetbuddy.questions_cn").questions
    todayQuestion = require("leetbuddy.questions_cn").questionOfToday
  else
    questions = require("leetbuddy.questions").questions
    -- todayQuestion = require("leetbuddy.questions").questions
  end
  local question = require("leetbuddy.questionfromfile").question
  local reset = require("leetbuddy.reset").reset_question
  local split = require("leetbuddy.split").split
  local test = require("leetbuddy.runner").test
  local submit = require("leetbuddy.runner").submit
  local checkcookies = require("leetbuddy.cookies").check_auth

  local opts = {}

  vim.api.nvim_create_user_command("LBQuestions", questions, opts)
  vim.api.nvim_create_user_command("LBQuestion", question, opts)
  vim.api.nvim_create_user_command("LBQuestionOfToday", todayQuestion, opts)
  vim.api.nvim_create_user_command("LBReset", reset, opts)
  vim.api.nvim_create_user_command("LBSplit", split, opts)
  vim.api.nvim_create_user_command("LBTest", test, opts)
  vim.api.nvim_create_user_command("LBSubmit", submit, opts)
  vim.api.nvim_create_user_command("LBClose", "qall", opts)
  vim.api.nvim_create_user_command("LBCheckCookies", checkcookies, opts)
end

M.setup = function(opts)
  M.user_config = vim.tbl_deep_extend("force", M.user_config, opts)
  create_cmds(opts)
end

return M
