local questions = require("leetbuddy.questions").questions
local question = require("leetbuddy.questionfromfile").question
local reset = require("leetbuddy.reset").reset_question
local split = require("leetbuddy.split").split
local test = require("leetbuddy.runner").test
local submit = require("leetbuddy.runner").submit
local checkcookies = require("leetbuddy.cookies").check_auth

local opts = {}

vim.api.nvim_create_user_command("LBQuestions", questions, opts)
vim.api.nvim_create_user_command("LBQuestion", question, opts)
vim.api.nvim_create_user_command("LBReset", reset, opts)
vim.api.nvim_create_user_command("LBSplit", split, opts)
vim.api.nvim_create_user_command("LBTest", test, opts)
vim.api.nvim_create_user_command("LBSubmit", submit, opts)
vim.api.nvim_create_user_command("LBClose", "qall", opts)
vim.api.nvim_create_user_command("LBCheckCookies", checkcookies, opts)
