local curl = require("plenary.curl")
local telescope = require("telescope")

function fetch_problems(query)
  local graphql_endpoint = require("leetbuddy.config").graphql_endpoint

  local variables = {
    searchKeyword = query,
  }

  local query = [[
    query problemsetQuestionList($searchKeyword: String!) {
      problemsetQuestionList: questionList(
        categorySlug: ""
        filters: {searchKeywords: $searchKeyword}
        limit: 20
        skip:0
    ) {
        total: totalNum
        questions: data {
          difficulty
          questionId: questionFrontendId
          isFavor
          paidOnly : isPaidOnly
          status
          title
          titleSlug
        }
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

  local data = vim.json.decode(response["body"])["data"]["problemsetQuestionList"]
  return (data ~= vim.NIL and data["questions"] or {})
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local make_entry = require("telescope.make_entry")
local entry_display = require("telescope.pickers.entry_display")

local opts = {}
local questions_table = {}

function update_status(sts, is_paid)
  if sts == vim.NIL and not is_paid then
    return " "
  end

  local statuses = {
    ac = "✔️",
    notac = "❌",
  }
  local s = sts ~= vim.NIL and statuses[sts] or ""
  local c = is_paid and "👑" or ""
  return s .. c
end

function gen_from_questions(opts)
  local displayer = entry_display.create({
    separator = "",
    items = {
      { width = 6 },
      { width = 6 },
      { width = 60 },
      { width = 8 },
    },
  })

  local make_display = function(entry)
    return displayer({
      { entry.value.questionId, "Number" },
      { update_status(entry.value.status, entry.value.paid_only), "Status" },
      { entry.value.title, "Title" },
      { entry.value.difficulty, "Difficulty" },
    })
  end

  return function(o)
    local entry = {
      display = make_display,
      value = {
        questionId = o.questionId,
        status = o.status,
        title = o.title,
        slug = o.titleSlug,
        difficulty = o.difficulty,
        paid_only = o.paidOnly,
      },
      ordinal = string.format("%s %s %s %s", o.questionId, o.status, o.title, o.difficulty),
    }
    return make_entry.set_default_entry_mt(entry, opts)
  end
end

function select_problem(prompt_bufnr)
  local problem = action_state.get_selected_entry()
  print(P(problem))
  actions.close(prompt_bufnr)
end

function wait(seconds)
  local start = os.time()
  repeat
  until os.time() > start + seconds
end

local function filter_problems(bufnr, opts)
  local cancel = function() end
  return function(prompt)
    return fetch_problems(prompt)
  end
end

fetch_problems("")

pickers
  .new(opts, {
    prompt_title = "Question",
    finder = finders.new_dynamic({
      fn = filter_problems(opts.bufnr, opts),
      entry_maker = gen_from_questions(opts),
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<CR>", select_problem)
      return true
    end,
  })
  :find()
