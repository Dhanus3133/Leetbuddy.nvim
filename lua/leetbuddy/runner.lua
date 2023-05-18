local curl = require("plenary.curl")
local domain = require("leetbuddy.config").domain
local leetcode_session = require("leetbuddy.config").leetcode_session
local csrf_token = require("leetbuddy.config").csrf_token
local utils = require("leetbuddy.utils")
local timer = vim.loop.new_timer()
local request_mode = {
  test = {
    endpoint = "interpret_solution",
    response_id = "interpret_id",
  },
  submit = {
    endpoint = "submit",
    response_id = "submission_id",
  },
}

local M = {}

local function generate_id(mode)
  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")

  local code = utils.read_file_contents(vim.fn.expand("%:p"))

  local question_slug = utils.get_question_slug(file)

  local endpoint_url = domain .. "/problems/" .. question_slug .. "/" .. request_mode[mode]["endpoint"] .. "/"

  local headers = {
    ["X-CSRFToken"] = csrf_token,
    ["Cookie"] = string.format("LEETCODE_SESSION=%s;csrftoken=%s", leetcode_session, csrf_token),
    ["Content-Type"] = "application/json",
    ["Accept"] = "application/json",
    ["Referer"] = domain .. "/problems/" .. utils.get_question_slug(question_slug) .. "/",
  }

  local body = {
    lang = utils.langSlugToFileExt[utils.get_file_extension(vim.fn.expand("%:t"))],
    question_id = utils.get_question_number_from_file_name(vim.fn.expand("%:t")),
    typed_code = code,
  }

  if mode == "test" then
    local code_path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    local input_path = utils.get_input_file_path(code_path)
    local test_body_extra = {
      data_input = utils.read_file_contents(input_path),
      judge_type = "small",
    }

    for key, value in pairs(test_body_extra) do
      body[key] = value
    end
  end

  local response = curl.post(endpoint_url, {
    headers = headers,
    body = vim.json.encode(body),
  })

  local id = vim.json.decode(response["body"])[request_mode[mode]["response_id"]]
  return id
end

function check_id(id, mode)
  local json_data

  local code = utils.read_file_contents(vim.fn.expand("%:p"))
  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")

  local question_slug = utils.get_question_slug(file)

  local headers = {
    ["X-CSRFToken"] = csrf_token,
    ["Cookie"] = string.format("LEETCODE_SESSION=%s;csrftoken=%s", leetcode_session, csrf_token),
    ["Content-Type"] = "application/json",
    ["Accept"] = "application/json",
    ["Referer"] = domain .. "/problems/" .. utils.get_question_slug(question_slug) .. "/submissions/",
  }

  if id then
    local status_url = domain .. "/submissions/detail/" .. id .. "/check"
    local status_response = curl.get(status_url, {
      headers = headers,
    })
    json_data = vim.fn.json_decode(status_response.body)
    if json_data["state"] == "SUCCESS" then
      timer:stop()
      local results_buffer = require("leetbuddy.split").get_results_buffer()
      P(json_data)
      require("leetbuddy.display").display_results(json_data, results_buffer, mode, code)
      print("DONE")
      return
    end
  end
end

function M.run(mode)
  local id = generate_id(mode)
  timer:start(
    100,
    1000,
    vim.schedule_wrap(function()
      check_id(id, mode)
    end)
  )
end

function M.test()
  M.run("test")
end

function M.submit()
  M.run("submit")
end

return M
