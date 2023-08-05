local curl = require("plenary.curl")
local config = require("leetbuddy.config")
local headers = require("leetbuddy.headers")
local utils = require("leetbuddy.utils")
local question = require("leetbuddy.question")
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

  local endpoint_url = config.website .. "/problems/" .. question_slug .. "/" .. request_mode[mode]["endpoint"] .. "/"

  local extra_headers = {
    ["Referer"] = config.website .. "/problems/" .. utils.get_question_slug(question_slug) .. "/",
  }

  local new_headers = vim.tbl_deep_extend("force", headers, extra_headers)

  local body = {
    lang = utils.langSlugToFileExt[utils.get_file_extension(vim.fn.expand("%:t"))],
    question_id = question.get_question_id(),
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
    headers = new_headers,
    body = vim.json.encode(body),
  })

  -- utils.P(response)
  local id = vim.json.decode(response["body"])[request_mode[mode]["response_id"]]
  return id
end

local function check_id(id, mode)
  local json_data

  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")

  local question_slug = utils.get_question_slug(file)

  local extra_headers = {
    ["Referer"] = config.website .. "/problems/" .. utils.get_question_slug(question_slug) .. "/submissions/",
  }

  local new_headers = vim.tbl_deep_extend("force", headers, extra_headers)

  if id then
    local status_url = config.website .. "/submissions/detail/" .. id .. "/check"
    local status_response = curl.get(status_url, {
      headers = new_headers,
    })
    json_data = vim.fn.json_decode(status_response.body)
    if config.debug then
      utils.P(json_data)
    end
    if json_data["state"] == "SUCCESS" then
      timer:stop()
      local results_buffer = require("leetbuddy.split").get_results_buffer()
      -- utils.P(json_data) -- DEBUGGING
      local code_path = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
      local input_path = utils.get_input_file_path(code_path)
      require("leetbuddy.display").display_results(false, results_buffer, json_data, mode, input_path)
      return
    end
  end
end

function M.run(mode)
  vim.cmd("LBCheckCookies")
  local results_buffer = require("leetbuddy.split").get_results_buffer()
  require("leetbuddy.display").display_results(true, results_buffer)
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
