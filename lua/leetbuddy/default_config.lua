local sep = require("plenary.path").path.sep

local default_config = {
  domain = "com", -- Change to "cn" for china website
  directory = vim.loop.os_homedir() .. sep .. ".leetcode",
  language = "py",
  debug = false,
  page_next = "<Right>",  -- list question with next page (20)
  page_prev = "<Left>",  -- list question with prev page (20)
}

return default_config
