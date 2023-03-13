M = {}

function M.question(slug)
  local curl = require("plenary.curl")
  local graphql_endpoint = require("leetbuddy.config").graphql_endpoint

  local variables = {
    titleSlug = slug,
  }

  local query = [[
    query questionData($titleSlug: String!) {
      question(titleSlug: $titleSlug) {
        questionId: questionFrontendId
        title
        titleSlug
        content
        canSeeQuestion
        difficulty
        exampleTestcases
        codeSnippets {
          lang
          langSlug
          code
        }
        status
        sampleTestCase
        judgerAvailable
        judgeType
      }
    }
  ]]

  local headers = {
    ["Cookie"] = "LEETCODE_SESSION=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJfYXV0aF91c2VyX2lkIjoiMTQ5OTUzMyIsIl9hdXRoX3VzZXJfYmFja2VuZCI6ImRqYW5nby5jb250cmliLmF1dGguYmFja2VuZHMuTW9kZWxCYWNrZW5kIiwiX2F1dGhfdXNlcl9oYXNoIjoiNjJjYWVlZDE5OWZmMGJiZTY4ODZhZDI2ZWJlY2VhNjdjYzIyMDY1OSIsImlkIjoxNDk5NTMzLCJlbWFpbCI6ImRoYW51czMxMzNAZ21haWwuY29tIiwidXNlcm5hbWUiOiJEaGFudXMwMDciLCJ1c2VyX3NsdWciOiJEaGFudXMwMDciLCJhdmF0YXIiOiJodHRwczovL2Fzc2V0cy5sZWV0Y29kZS5jb20vdXNlcnMvYXZhdGFycy9hdmF0YXJfMTY2NzczOTA2MC5wbmciLCJyZWZyZXNoZWRfYXQiOjE2NzQ3OTU4ODAsImlwIjoiNDkuMjA0LjEzOS43NCIsImlkZW50aXR5IjoiMTczZTExOTEzZjI3YzBhNzY2ZmI0MTk5YmFmZTU5MWYiLCJzZXNzaW9uX2lkIjozMzgxMzczMywiX3Nlc3Npb25fZXhwaXJ5IjoxMjA5NjAwfQ.tvH_YamUgzqPa49Psz-0ihQXFKbirLu5dqNlCnzPK2g;csrftoken=tSL5zBa0SYmDZkvLYb28I0x0ymjWHbrlJEbmd4JIQIrYHAUvKtTOhPUD6mkwikUT",
    ["Content-Type"] = "application/json",
    ["Accept"] = "application/json",
  }

  local response =
    curl.post(graphql_endpoint, { headers = headers, body = vim.json.encode({ query = query, variables = variables }) })

  local question = vim.json.decode(response["body"])["data"]["question"]
  local content = question["content"]
  if not question["canSeeQuestion"] then
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
