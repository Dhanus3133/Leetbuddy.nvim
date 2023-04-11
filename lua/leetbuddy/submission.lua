local job = require("plenary.job")
local curl = require("plenary.curl")
local domain = require("leetbuddy.config").domain
local leetcode_session = require("leetbuddy.config").leetcode_session
local csrf_token = require("leetbuddy.config").csrf_token
local directory = require("leetbuddy.config").directory

local interpret_solution = domain .. "/problems/two-sum/interpret_solution/"

local headers = {
  ["X-CSRFToken"] = csrf_token,
  ["Cookie"] = string.format("LEETCODE_SESSION=%s;csrftoken=%s", leetcode_session, csrf_token),
  ["Content-Type"] = "application/json",
  ["Accept"] = "application/json",
  ["Referer"] = "https://leetcode.com/problems/two-sum/",
}

local response = curl.post(interpret_solution, {
  headers = headers,
  body = vim.json.encode({
    data_input = "[2,7,11,15]\n9",
    judge_type = "small",
    lang = "cpp",
    question_id = "1",
    typed_code = "nlkmlkjjkh",
  }),
})

local interpret_id = vim.json.decode(response["body"])["interpret_id"]

local Job = require("plenary.job")

if interpret_id then
  print(interpret_id)

  local status_url = domain .. "/submissions/detail/" .. interpret_id .. "/check"
  local status_response
  repeat
    status_response = curl.get(status_url)
    local json_data = vim.fn.json_decode(status_response.body)
  until json_data.state == "SUCCESS"
  P(status_response)
end

-- plenary job to run in background and after 10 seconds it must print hello world
-- local Job = require("plenary.job")
-- local j = Job:new({
--   command = "sleep",
--   args = { "10" },
--   on_exit = function(j, code)
--     print("hello world")
--   end,
-- })
