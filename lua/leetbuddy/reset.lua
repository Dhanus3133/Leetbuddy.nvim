local curl = require("plenary.curl")
local utils = require("leetbuddy.utils")
local directory = require("leetbuddy.config").directory
local graphql_endpoint = require("leetbuddy.config").graphql_endpoint
local headers = require("leetbuddy.headers")

local M = {}

function M.reset_question()
  local config = require("leetbuddy.config")
  vim.cmd("LBCheckCookies")
  if utils.is_in_folder(vim.api.nvim_buf_get_name(0), directory) then
    local lang = config.languages.get_lang_by_extension(config.language)
    local buf_name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    local slug = utils.get_question_slug(buf_name)

    local variables = {
      titleSlug = slug,
    }

    local query = [[
      query questionData($titleSlug: String!) {
        question(titleSlug: $titleSlug) {
          exampleTestcaseList
          sampleTestCase
          codeSnippets {
            langSlug
            code
          }
        }
      }
    ]]

    local response = curl.post(
      graphql_endpoint,
      {
        headers = headers,
        body = vim.json.encode({ query = query, variables = variables }),
      }
    )

    local question = vim.json.decode(response["body"])["data"]["question"]
    local submission_contents
    for _, code_table in ipairs(question["codeSnippets"]) do
      if code_table.langSlug == utils.langSlugToFileExt[lang.extension] then
        submission_contents = utils.split_string_to_table(code_table.code)
        break
      end
    end

    local folder = lang:get_folder(buf_name)
    local input_contents =
      vim.split(table.concat(question["exampleTestcaseList"], "\n\n"), "\n")
    lang:make_folder(folder, submission_contents, input_contents)
  end
  vim.cmd("edit")
end

return M
