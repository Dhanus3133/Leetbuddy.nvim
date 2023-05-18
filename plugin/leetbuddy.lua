local questions = require("leetbuddy.questions").questions
local question = require("leetbuddy.questionfromfile").question
local reset = require("leetbuddy.reset").reset_question
local split = require("leetbuddy.split").split
local test = require("leetbuddy.runner").test
local submit = require("leetbuddy.runner").submit

vim.api.nvim_create_user_command("LBQuestions", questions, { bar = true })
vim.api.nvim_create_user_command("LBQuestion", question, { bar = true })
vim.api.nvim_create_user_command("LBReset", reset, { bar = true })
vim.api.nvim_create_user_command("LBSplit", split, { bar = true })
vim.api.nvim_create_user_command("LBTest", test, { bar = true })
vim.api.nvim_create_user_command("LBSubmit", submit, { bar = true })
vim.api.nvim_create_user_command("LBClose", "qall", { bar = true })

vim.api.nvim_set_keymap("n", "<leader>lq", ":LBQuestions<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>ll", ":LBQuestion<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>lr", ":LBReset<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>l;", ":LBSplit<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>lt", ":LBTest<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>ls", ":LBSubmit<CR>", { silent = true })
vim.api.nvim_set_keymap("n", "<leader>lc", ":LBClose<CR>", { silent = true })
