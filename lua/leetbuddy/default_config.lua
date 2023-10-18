local sep = require("plenary.path").path.sep

local default_config = {
  domain = "com", -- Change to "cn" for china website
  directory = vim.loop.os_homedir() .. sep .. ".leetcode",
  language = "py",
  debug = false,
  keys = {
    select = "<CR>",
    reset = "<A-r>",
    easy = "<A-e>",
    medium = "<A-m>",
    hard = "<A-h>",
    accepted = "<A-a>",
    not_started = "<A-y>",
    tried = "<A-t>",
  },
}

return default_config
