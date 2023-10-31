local sep = require("plenary.path").path.sep

local default_config = {
  domain = "com", ---@type "com" | "cn" Change to "cn" for china website
  directory = vim.loop.os_homedir() .. sep .. ".leetcode",
  language = "py", ---@type FileExtensions
  debug = false,
  limit = 30,
  keys = {
    select = "<CR>",
    reset = "<C-r>",
    easy = "<C-e>",
    medium = "<C-m>",
    hard = "<A-h>",
    accepted = "<C-a>",
    not_started = "<C-y>",
    tried = "<C-t>",
    page_next = "<C-l>",
    page_prev = "<C-h>",
  },
}

return default_config
