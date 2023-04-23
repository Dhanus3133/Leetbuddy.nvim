local curl = require("plenary.curl")
local domain = require("leetbuddy.config").domain
local leetcode_session = require("leetbuddy.config").leetcode_session
local csrf_token = require("leetbuddy.config").csrf_token

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

local timer = vim.loop.new_timer()

local json_data

local function make_api_call()
  if interpret_id then
    print(interpret_id)

    local status_url = domain .. "/submissions/detail/" .. interpret_id .. "/check"
    local status_response = curl.get(status_url)
    json_data = vim.fn.json_decode(status_response.body)
    if json_data.state == "SUCCESS" then
        P(json_data)
        timer:stop()
        print("DONE")
    end
  end
end

timer:start(100, 1000, vim.schedule_wrap(function()
    make_api_call()
end))
