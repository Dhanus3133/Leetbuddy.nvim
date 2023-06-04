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

local extra_config = {
  website = website,
  graphql_endpoint = graphql_endpoint,
}

extra_config = vim.tbl_deep_extend("force", extra_config, cookies)

local config = vim.tbl_deep_extend("force", user_config, cookies)
config = vim.tbl_deep_extend("force", config, extra_config)

return config
