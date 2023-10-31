local user_config = require("leetbuddy").user_config
local path = require("plenary.path")
local sep = require("plenary.path").path.sep
local utils = require("leetbuddy.utils")
local cookie_file = path:new(vim.loop.os_homedir() .. sep .. ".lbcookie")

local website = "https://leetcode." .. user_config.domain
local graphql_endpoint = website .. "/graphql"

cookie_file:touch()
local success, cookies = pcall(vim.json.decode, cookie_file:read())

if not success then
  cookies = {}
end

local web_config = {
  website = website,
  graphql_endpoint = graphql_endpoint,
}
local default_languages = require("leetbuddy.languages")
local M = vim.tbl_deep_extend(
  "force",
  web_config,
  cookies,
  { languages = default_languages },
  user_config
)

---Get language class by file extension
---@param extension FileExtensions
---@return Language
function M.get_lang_by_extension(extension)
  return utils.find_in_table(function(l)
    return l.extension == extension
  end, M["languages"])
end

---Get language class by leetcode name
---@param name LeetcodeNames Language name
---@return Language
function M.get_lang_by_name(name)
  return utils.find_in_table(function(l)
    return l.leetcode_name == name
  end, M["languages"])
end

--rebuild the languages metatables after possibly being
--overridden by the users
for key, lang in pairs(M["languages"]) do
  M["languages"][key] = vim.tbl_deep_extend("force", utils.Language, lang)
end

return M
