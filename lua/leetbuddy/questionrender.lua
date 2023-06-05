M = {}

local curl = require("plenary.curl")
local config = require("leetbuddy.config")
local headers = require("leetbuddy.headers")

function M.question(slug)
  vim.cmd("LBCheckCookies")

  local variables = {
    titleSlug = slug,
  }

  local query = [[
  query questionData($titleSlug: String!) {
    question(titleSlug: $titleSlug) {
      questionId: questionFrontendId
      ]] .. (config.domain == "cn" and [[
         title: translatedTitle
         content: translatedContent
      ]] or [[
         title
         content
      ]]) .. [[
      codeSnippets {
        lang
        langSlug
        code
      }
    }
  }
]]

  local response = curl.post(
    config.graphql_endpoint,
    { headers = headers, body = vim.json.encode({ query = query, variables = variables }) }
  )

  local question = vim.json.decode(response["body"])["data"]["question"]
  local content = question["content"]
  if question["content"] == vim.NIL then
    return "You don't have a premium plan"
  end
  local entities = {
    { "amp", "&" },
    { "apos", "'" },
    { "#x27", "'" },
    { "#x2F", "/" },
    { "#39", "'" },
    { "#47", "/" },
    { "lt", "<" },
    { "gt", ">" },
    { "nbsp", " " },
    { "quot", '"' },
  }

  local img_urls = {}
  content = content:gsub("<img.-src=[\"'](.-)[\"'].->", function(url)
    table.insert(img_urls, url)
    return "##IMAGE##"
  end)
  content = string.gsub(content, "<[^>]+>", "")

  for _, url in ipairs(img_urls) do
    content = string.gsub(content, "##IMAGE##", url, 1)
  end

  for _, entity in ipairs(entities) do
    content = string.gsub(content, "&" .. entity[1] .. ";", entity[2])
  end
  return question["questionId"] .. ". " .. question["title"] .. "\n" .. content
end

return M
