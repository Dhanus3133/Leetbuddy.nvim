local M = {}
local utils = require("leetbuddy.utils")
local sep = require("plenary.path").path.sep
local path = require("plenary.path")

function M.get_languages()
  local languages = {}
  for key, _ in pairs(utils.langSlugToFileExt) do
    table.insert(languages, key)
  end
  return languages
end

function M.main(args)
  local language = args["fargs"][1]
  local languages = M.get_languages()
  if not utils.is_in_table(languages, language) then
    vim.api.nvim_err_writeln("Invalid Language Extension: " .. language)
    return
  end
  local directory = vim.fn.expand("%:p:h")
  local file = vim.fn.expand("%:t"):match("(.+)%..+")
  local fileLocation = directory .. sep .. file .. "." .. language
  local fileLocationFile = path:new(fileLocation)

  local current_bufnr = vim.api.nvim_get_current_buf()

  if not fileLocationFile:exists() then
    fileLocationFile:touch()
    vim.cmd("edit! " .. fileLocation)
    vim.cmd("LBReset")
  else
    vim.cmd("edit! " .. fileLocation)
  end
  vim.api.nvim_buf_delete(current_bufnr, { force = true })
end

return M
