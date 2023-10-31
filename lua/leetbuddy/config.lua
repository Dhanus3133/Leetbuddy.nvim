local user_config = require("leetbuddy").user_config
local path = require("plenary.path")
local sep = require("plenary.path").path.sep
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

local config = vim.tbl_deep_extend(
  "force",
  web_config,
  cookies,
  { languages = require("leetbuddy.languages") },
  user_config
)

return config
