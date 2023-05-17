local curl = require("plenary.curl")
local utils = require("leetbuddy.utils")
local directory = require("leetbuddy.config").directory
local graphql_endpoint = require("leetbuddy.config").graphql_endpoint
local language = require("leetbuddy.config").language

local M = {}

function M.reset_question()
  if utils.is_in_folder(vim.api.nvim_buf_get_name(0), directory) then
    local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")

    local input = directory .. "/" .. utils.strip_file_extension(file) .. "/" .. "input.txt"

    local slug = utils.get_question_slug(file)

    local variables = {
      titleSlug = slug,
    }

    local query = [[
    query questionData($titleSlug: String!) {
      question(titleSlug: $titleSlug) {
        sampleTestCase
        codeSnippets {
          langSlug
          code
        }
      }
    }
  ]]

    local headers = {
      ["Cookie"] = string.format("LEETCODE_SESSION=%s;csrftoken=%s", leetcode_session, csrf_token),
      ["Content-Type"] = "application/json",
      ["Accept"] = "application/json",
    }

    local response = curl.post(
      graphql_endpoint,
      { headers = headers, body = vim.json.encode({ query = query, variables = variables }) }
    )

    local question = vim.json.decode(response["body"])["data"]["question"]

    for _, table in ipairs(question["codeSnippets"]) do
      if table.langSlug == utils.langSlugToFileExt[language] then
        vim.api.nvim_buf_set_lines(
          vim.api.nvim_get_current_buf(),
          0,
          -1,
          false,
          utils.split_string_to_table(table.code)
        )
        break
      end
    end

    local input_file = io.open(input, "w")

    if input_file then
      input_file:write(question["sampleTestCase"])
      input_file:close()
      print("Text written successfully.")
    else
      print("Failed to open the file.")
    end
  end
end

return M
