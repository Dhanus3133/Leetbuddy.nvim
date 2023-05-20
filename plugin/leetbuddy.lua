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

vim.api.nvim_set_keymap("n", "<leader>lq", ":LBQuestions<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>ll", ":LBQuestion<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>lr", ":LBReset<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>l;", ":LBSplit<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>lt", ":LBTest<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>ls", ":LBSubmit<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>lc", ":LBClose<CR>", { silent = true })
