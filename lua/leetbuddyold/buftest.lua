local filetype = require("plenary.filetype")

local function split_string_to_table(str)
  local lines = {}
  for line in str:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  return lines
end

local function question()
  file = io.open("question.md", "r")

  content = file:read("a")

  local entities = {
    { "amp", "&" },
    { "apos", "'" },
    { "#x27", "'" },
    { "#x2F", "/" },
    { "#39", "'" },
    { "#47", "/" },
    { "lt", "<" },
    { "gt", ">" },
    { "nbsp", " " },
    { "quot", '"' },
  }

  local img_urls = {}
  content = content:gsub("<img.-src=[\"'](.-)[\"'].->", function(url)
    table.insert(img_urls, url)
    return "##IMAGE##"
  end)
  content = string.gsub(content, "<[^>]+>", "")

  for _, url in ipairs(img_urls) do
    content = string.gsub(content, "##IMAGE##", url, 1)
  end

  for _, entity in ipairs(entities) do
    content = string.gsub(content, "&" .. entity[1] .. ";", entity[2])
  end

  -- print(content)
  return split_string_to_table(content)
end

-- local function pad(contents, opts)
--   vim.validate({
--     contents = { contents, "t" },
--     opts = { opts, "t", true },
--   })
--   opts = opts or {}
--   local left_padding = (" "):rep(opts.pad_left or 1)
--   local right_padding = (" "):rep(opts.pad_right or 1)
--   for i, line in ipairs(contents) do
--     contents[i] = string.format("%s%s%s", left_padding, line:gsub("\r", ""), right_padding)
--   end
--   if opts.pad_top then
--     for _ = 1, opts.pad_top do
--       table.insert(contents, 1, "")
--     end
--   end
--   if opts.pad_bottom then
--     for _ = 1, opts.pad_bottom do
--       table.insert(contents, "")
--     end
--   end
--   return contents
-- end

-- function display_right(contents)
--   local bufnr = vim.api.nvim_create_buf(true, false)
--   local width = 0
--   for _, value in pairs(contents) do
--     width = math.max(width, string.len(value))
--   end
--   width = width + 5
--   local height = math.floor(vim.o.lines * 0.9)
--   if not vim.g["vsplit"] then
--     vim.api.nvim_open_win(bufnr, true, {
--       border = vim.g["border"] or "rounded",
--       style = "minimal",
--       relative = "editor",
--       row = math.floor(((vim.o.lines - height) / 2) - 1),
--       col = math.floor(vim.o.columns - width - 1),
--       width = width,
--       height = height,
--     })
--   else
--     vim.cmd("vsplit")
--     vim.api.nvim_win_set_buf(0, bufnr)
--     vim.api.nvim_win_set_width(0, width)
--     -- vim.api.nvim_win_set_option(0, "number", false)
--     -- vim.api.nvim_win_set_option(0, "relativenumber", false)
--     -- vim.api.nvim_win_set_option(0, "cursorline", false)
--     -- vim.api.nvim_win_set_option(0, "cursorcolumn", false)
--     -- vim.api.nvim_win_set_option(0, "spell", false)
--     -- vim.api.nvim_win_set_option(0, "list", false)
--     -- vim.api.nvim_win_set_option(0, "signcolumn", "auto")
--   end
--   contents = pad(contents, { pad_top = 1 })
--   -- vim.api.nvim_win_set_option(0, "linebreak", true)
--   vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)
--   -- vim.api.nvim_buf_set_option(bufnr, "shiftwidth", 2)
--   vim.api.nvim_buf_set_var(0, "file_name", "question.lua")
--   return bufnr
-- end

local file = filetype.detect(vim.api.nvim_buf_get_name(0))

local q = require("leetbuddy.questionrender")

local val = question()
-- local bufnr = display_right(val)
local bufnr = vim.api.nvim_create_buf(true, false)
print(bufnr)
vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, val)

vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
vim.api.nvim_buf_set_option(bufnr, "filetype", "LC")
vim.api.nvim_buf_set_option(bufnr, "bufhidden", "hide")
vim.api.nvim_buf_set_option(bufnr, "buflisted", true)
vim.api.nvim_buf_set_name(bufnr, "file")

vim.api.nvim_buf_set_keymap(bufnr, "n", "<esc>", "<cmd>bd<CR>", { noremap = true })
vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>bd<CR>", { noremap = true })
