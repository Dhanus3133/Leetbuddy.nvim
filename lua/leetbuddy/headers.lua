local config = require("leetbuddy.config")

local headers = {
  ["Cookie"] = string.format(
    "LEETCODE_SESSION=%s;csrftoken=%s",
    config.leetcode_session,
    config.csrf_token
  ),
  ["Content-Type"] = "application/json",
  ["Accept"] = "application/json",
  ["x-csrftoken"] = config.csrf_token,
}

return headers
