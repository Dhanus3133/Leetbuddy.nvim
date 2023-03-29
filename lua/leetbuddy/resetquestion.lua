local qr = require("leetbuddy.questionrender")
local question = require("leetbuddy.question")
local utils = require("leetbuddy.utils")
local curl = require("plenary.curl")
local utils = require("leetbuddy.utils")
local directory = require("leetbuddy.config").directory
local graphql_endpoint = require("leetbuddy.config").graphql_endpoint
local language = require("leetbuddy.config").language

local function reset_question()
  if is_in_folder(vim.api.nvim_buf_get_name(0), directory) then
    local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")

    local slug = get_question_slug(file)

    local variables = {
      titleSlug = slug,
    }

    local query = [[
    query questionData($titleSlug: String!) {
      question(titleSlug: $titleSlug) {
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

    local langSlugToFileExt = {
      ["cpp"] = "cpp",
      ["java"] = "java",
      ["py"] = "python3",
      ["c"] = "c",
      ["cs"] = "csharp",
      ["js"] = "javascript",
      ["rb"] = "ruby",
      ["swift"] = "swift",
      ["go"] = "golang",
      ["scala"] = "scala",
      ["kt"] = "kotlin",
      ["rs"] = "rust",
      ["php"] = "php",
      ["ts"] = "typescript",
      ["rkt"] = "racket",
      ["erl"] = "erlang",
      ["ex"] = "elixir",
      ["dart"] = "dart",
    }

    print(language)
    for _, table in ipairs(question["codeSnippets"]) do
      if table.langSlug == langSlugToFileExt[language] then
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
  end
end

vim.api.nvim_create_user_command("LBReset", reset_question, { bar = true })
