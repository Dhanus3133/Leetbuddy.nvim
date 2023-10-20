local sep = require("plenary.path").path.sep

local default_config = {
  domain = "com", -- Change to "cn" for china website
  directory = vim.loop.os_homedir() .. sep .. ".leetcode",
  language = "py",
  debug = false,
  keys = {
    select = "<CR>",
    reset = "<C-r>",
    easy = "<C-e>",
    medium = "<C-m>",
    hard = "<C-h>",
    accepted = "<C-a>",
    not_started = "<C-y>",
    tried = "<C-t>",
  },
}

return default_config
