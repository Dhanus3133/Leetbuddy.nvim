local curl = require("plenary.curl")
local domain = require("leetbuddy.config").domain
local leetcode_session = require("leetbuddy.config").leetcode_session
local csrf_token = require("leetbuddy.config").csrf_token
local utils = require("leetbuddy.utils")
local timer = vim.loop.new_timer()

local M = {}

local function generate_interpret_id()
  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")

  local code_path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

  local input_path = utils.get_input_file_path(code_path)

  local code = utils.read_file_contents(vim.fn.expand("%:p"))

  local question_slug = utils.get_question_slug(file)

  local interpret_solution = domain .. "/problems/" .. question_slug .. "/interpret_solution/"

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
      data_input = utils.read_file_contents(input_path),
      judge_type = "small",
      lang = utils.langSlugToFileExt[utils.get_file_extension(vim.fn.expand("%:t"))],
      question_id = "1",
      typed_code = code,
    }),
  })

  local interpret_id = vim.json.decode(response["body"])["interpret_id"]
  return interpret_id
end

function check_interpret(interpret_id)
  local json_data
  if interpret_id then
    local status_url = domain .. "/submissions/detail/" .. interpret_id .. "/check"
    local status_response = curl.get(status_url)
    json_data = vim.fn.json_decode(status_response.body)
    if json_data.state == "SUCCESS" then
      timer:stop()
      local results_buffer = require("leetbuddy.split").get_results_buffer()
      P(json_data)
      require("leetbuddy.display").display_results(json_data, results_buffer)
      print("DONE")
      return
    end
  end
end

function M.test()
  local interpret_id = generate_interpret_id()
  timer:start(
    100,
    1000,
    vim.schedule_wrap(function()
      check_interpret(interpret_id)
    end)
  )
end

return M
