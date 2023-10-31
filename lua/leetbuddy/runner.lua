local config = require("leetbuddy.config")
local curl = require("plenary.curl")
local headers = require("leetbuddy.headers")
local question = require("leetbuddy.question")
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
  local buf_name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local lang = config.get_lang_by_extension(config.language)
  local folder = lang:get_folder(buf_name)

  local code = lang:get_submission_file_contents(folder)

  local question_slug = utils.get_question_slug(buf_name)

  local endpoint_url = config.website
    .. "/problems/"
    .. question_slug
    .. "/"
    .. request_mode[mode]["endpoint"]
    .. "/"

  local extra_headers = {
    ["Referer"] = config.website .. "/problems/" .. question_slug .. "/",
  }

  local new_headers = vim.tbl_deep_extend("force", headers, extra_headers)

  local body = {
    lang = lang.leetcode_name,
    question_id = question.get_question_id(),
    typed_code = table.concat(code, "\n"),
  }

  if mode == "test" then
    local input_contents = lang:get_input_contents(folder)
    local test_body_extra = {
      data_input = table.concat(input_contents, "\n"),
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

  if config.debug then
    print("Response from " .. endpoint_url)
    utils.P(response["body"])
  end
  local id =
    vim.json.decode(response["body"])[request_mode[mode]["response_id"]]
  return id
end

local function check_id(id, mode)
  local json_data

  local buf_name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local lang = config.get_lang_by_extension(config.language)
  local folder = lang:get_folder(buf_name)

  local question_slug = utils.get_question_slug(buf_name)

  local extra_headers = {
    ["Referer"] = config.website
      .. "/problems/"
      .. question_slug
      .. "/submissions/",
  }

  local new_headers = vim.tbl_deep_extend("force", headers, extra_headers)

  if id then
    local status_url = config.website
      .. "/submissions/detail/"
      .. id
      .. "/check"
    local status_response = curl.get(status_url, {
      headers = new_headers,
    })
    json_data = vim.fn.json_decode(status_response.body)
    if config.debug then
      print("Response from " .. status_url)
      utils.P(json_data)
    end
    if json_data["state"] == "SUCCESS" then
      timer:stop()
      local results_buffer = require("leetbuddy.split").get_results_buffer()
      -- utils.P(json_data) -- DEBUGGING
      require("leetbuddy.display").display_results(
        false,
        results_buffer,
        json_data,
        mode,
        lang:get_input_file_path(folder)
      )
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
