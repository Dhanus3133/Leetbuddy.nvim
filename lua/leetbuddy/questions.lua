local curl = require("plenary.curl")
local sep = require("plenary.path").path.sep
local config = require("leetbuddy.config")
local headers = require("leetbuddy.headers")
local utils = require("leetbuddy.utils")

local M = {}

local function display_questions(search_query)
  local graphql_endpoint = config.graphql_endpoint

  local variables = {
    searchKeyword = search_query,
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

local function update_status(sts, is_paid)
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

local function gen_from_questions()
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

local function select_problem(prompt_bufnr)
  actions.close(prompt_bufnr)
  local problem = action_state.get_selected_entry()
  local question_slug = string.format("%04d-%s", problem["value"]["questionId"], problem["value"]["slug"])

  if not utils.find_file_inside_folder(config.directory, question_slug) then
    vim.api.nvim_command(":silent !mkdir " .. config.directory .. sep .. question_slug)
  end

  local file = config.directory .. sep .. question_slug .. sep .. question_slug .. "." .. config.language
  local input = config.directory .. sep .. question_slug .. sep .. "input" .. "." .. "txt"

  local qfound =
    utils.find_file_inside_folder(config.directory .. sep .. question_slug, question_slug .. "." .. config.language)

  if not qfound then
    vim.api.nvim_command(":silent !touch " .. file)
    vim.api.nvim_command(":silent !touch " .. input)
    vim.api.nvim_command("edit! " .. file)
    vim.api.nvim_command("LBReset")
  else
    vim.api.nvim_command("edit! " .. file)
  end
  vim.api.nvim_command("LBSplit")
  vim.api.nvim_command("LBQuestion")
end

local function filter_problems()
  -- local cancel = function() end
  return function(prompt)
    return display_questions(prompt)
  end
end

function M.questions()
  vim.cmd("LBCheckCookies")
  pickers
    .new(opts, {
      prompt_title = "Question",
      finder = finders.new_dynamic({
        fn = filter_problems(),
        entry_maker = gen_from_questions(),
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(_, map)
        map("i", "<CR>", select_problem)
        map("n", "<CR>", select_problem)
        return true
      end,
    })
    :find()
end

return M
