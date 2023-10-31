local curl = require("plenary.curl")
local config = require("leetbuddy.config")
local path = require("plenary.path")
local sep = require("plenary.path").path.sep
local cookie_file = path:new(vim.loop.os_homedir() .. sep .. ".lbcookie")
local vars = { "leetcode_session", "csrf_token" }
local dir = path:new(config.directory)
local M = {}

local status = false
local cookies = {}
local username

local function saveVariablesToFile()
  local new_cookies = {}
  for _, varName in ipairs(vars) do
    local input = vim.fn.input("Enter cookie for " .. varName .. ": ")
    if input then
      new_cookies[varName] = input
    end
  end

  cookies = new_cookies
  local encoded_data = vim.json.encode(new_cookies)
  cookie_file:write(encoded_data, "w")
  print("\n\nCookies Saved! Restart Neovim to apply changes.")
  return true
end

local function prerequisite_check()
  if not dir:exists() then
    dir:mkdir()
    print("Folder Created: " .. dir)
  end

  if not cookie_file:exists() then
    cookie_file:touch()
    print("File Created: " .. dir)
  end

  local success
  success, cookies = pcall(vim.json.decode, cookie_file:read())

  if not success then
    saveVariablesToFile()
  end
end

function M.check_auth()
  if status then
    return
  end
  prerequisite_check()
  local headers = {
    ["Cookie"] = string.format(
      "LEETCODE_SESSION=%s;csrftoken=%s",
      cookies.leetcode_session or "",
      cookies.csrf_token or ""
    ),
    ["Content-Type"] = "application/json",
    ["Accept"] = "application/json",
    ["x-csrftoken"] = cookies.csrf_token,
    ["Referer"] = config.website,
  }

  local query = [[
    query globalData {
      userStatus {
        isSignedIn
        username
      }
    }
  ]]

  local response = curl.post(config.graphql_endpoint, { headers = headers, body = vim.json.encode({ query = query }) })
  local user_status = vim.json.decode(response["body"])["data"]["userStatus"]
  status = user_status["isSignedIn"]
  username = user_status["username"]
  if not status then
    print("\nCookies Expired!")
    saveVariablesToFile()
    M.check_auth()
  else
    print("Logged in as " .. username)
  end
end

return M
