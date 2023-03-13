local M = {}

M.setup = function(opts)
  local curl = require("plenary.curl")
  local telescope = require("telescope")

  local graphql_endpoint = "https://leetcode.com/graphql"

  local query = [[
    query problemsetQuestionList {
      problemsetQuestionList: questionList(
          categorySlug: ""
          filters: {}
          limit:10
          skip:0
      ) {
          total: totalNum
          questions: data {
            acRate
            difficulty
            questionId: questionFrontendId
            isFavor
            paidOnly: isPaidOnly
            status
            title
            titleSlug
            topicTags {
              name
              id
              slug
            }
          }
        }
      }
    ]]

  local headers = {
    ["Cookie"] = "LEETCODE_SESSION=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJfYXV0aF91c2VyX2lkIjoiMTQ5OTUzMyIsIl9hdXRoX3VzZXJfYmFja2VuZCI6ImRqYW5nby5jb250cmliLmF1dGguYmFja2VuZHMuTW9kZWxCYWNrZW5kIiwiX2F1dGhfdXNlcl9oYXNoIjoiNjJjYWVlZDE5OWZmMGJiZTY4ODZhZDI2ZWJlY2VhNjdjYzIyMDY1OSIsImlkIjoxNDk5NTMzLCJlbWFpbCI6ImRoYW51czMxMzNAZ21haWwuY29tIiwidXNlcm5hbWUiOiJEaGFudXMwMDciLCJ1c2VyX3NsdWciOiJEaGFudXMwMDciLCJhdmF0YXIiOiJodHRwczovL2Fzc2V0cy5sZWV0Y29kZS5jb20vdXNlcnMvYXZhdGFycy9hdmF0YXJfMTY2NzczOTA2MC5wbmciLCJyZWZyZXNoZWRfYXQiOjE2NzQ3OTU4ODAsImlwIjoiNDkuMjA0LjEzOS43NCIsImlkZW50aXR5IjoiMTczZTExOTEzZjI3YzBhNzY2ZmI0MTk5YmFmZTU5MWYiLCJzZXNzaW9uX2lkIjozMzgxMzczMywiX3Nlc3Npb25fZXhwaXJ5IjoxMjA5NjAwfQ.tvH_YamUgzqPa49Psz-0ihQXFKbirLu5dqNlCnzPK2g;csrftoken=tSL5zBa0SYmDZkvLYb28I0x0ymjWHbrlJEbmd4JIQIrYHAUvKtTOhPUD6mkwikUT",
    ["Content-Type"] = "application/json",
    ["Accept"] = "application/json",
  }

  -- local response =
    -- curl.post(graphql_endpoint, { headers = headers, body = vim.json.encode({ query = query, variables = variables }) })

  function dump(o)
    if type(o) == "table" then
      local s = "{ "
      for k, v in pairs(o) do
        if type(k) ~= "number" then
          k = '"' .. k .. '"'
        end
        s = s .. "[" .. k .. "] = " .. dump(v) .. ","
      end
      return s .. "} "
    else
      return tostring(o)
    end
  end

  -- telescope.markers.show_sink:write(table.concat(response))
  -- print(table.concat(response))
  -- print(dump(response["body"]))
  -- print(dump(vim.json.decode(response["body"])["data"]["problemsetQuestionList"]))
  -- print(dump(vim.json.decode(response["body"])["data"]["problemsetQuestionList"]["questions"][1]))
  -- for index, value in ipairs(vim.json.decode(response["body"])["data"]["problemsetQuestionList"]["questions"]) do
  --   print(index, ". ", dump(value["status"]))
  --   print("++++++++++=========================++++++++++++++++++++")
  -- end
  -- print("++++++++++=========================++++++++++++++++++++")
  -- print(dump(vim.json.decode(response["body"])["data"]["problemsetQuestionList"]["questions"][2]))

  -- print(response)

  -- local pickers = require("telescope.pickers")
  -- local finders = require("telescope.finders")
  -- local sorters = require("telescope.sorters")
  -- local conf = require("telescope.config").values
  -- local actions = require("telescope.actions")
  -- local action_state = require("telescope.actions.state")

  -- local opts = {}
  --
  -- pickers
  --   .new(opts, {
  --     -- prompt_title = "Question",
  --     finder = finders.new_table({ "Hello", "world" }),
  --     sorter = sorters.get_generic_fuzzy_sorter({}),
  --   })
  --   :find()
end

return M
