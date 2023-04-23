local curl = require("plenary.curl")
local leetcode_session = require("leetbuddy.config").leetcode_session
local csrf_token = require("leetbuddy.config").csrf_token
local directory = require("leetbuddy.config").directory
local language = require("leetbuddy.config").language
local utils = require("leetbuddy.utils")

function display_questions(query)
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
    ["Cookie"] = string.format("LEETCODE_SESSION=%s;csrftoken=%s", leetcode_session, csrf_token),
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

function checkFolderPresence(folderpath, foldername)
  -- check for operating system and set command accordingly
  local is_windows = package.config:sub(1, 1) == "\\"
  local command = is_windows and "dir" or "ls"

  -- open the parent folder for reading
  local folder = io.popen(command .. " " .. folderpath)

  -- read the output of the command
  local files = folder:read("*all")

  -- check if the folder is present
  if string.match(files, is_windows and "\\" .. foldername .. "\\" or "/" .. foldername .. "/$") then
    folder:close()
    return true
  else
    folder:close()
    return false
  end
end

function findFiles(dir)
  local files = {}
  for entry in io.popen('dir "' .. dir .. '" /b /a-d'):lines() do
    table.insert(files, dir .. "\\" .. entry)
  end
  for entry in io.popen('dir "' .. dir .. '" /b /ad'):lines() do
    if entry ~= "." and entry ~= ".." then
      local subdir = dir .. "\\" .. entry
      local subfiles = findFiles(subdir)
      for _, file in ipairs(subfiles) do
        table.insert(files, file)
      end
    end
  end
  return files
end

function select_problem(prompt_bufnr)
  actions.close(prompt_bufnr)
  local problem = action_state.get_selected_entry()
  local question_slug = string.format("%04d-%s", problem["value"]["questionId"], problem["value"]["slug"])

  if not utils.find_file_inside_folder(directory, question_slug) then
    vim.api.nvim_command(":silent !mkdir " .. directory .. "/" .. question_slug)
  end

  local file = directory .. "/" .. question_slug .. "/" .. question_slug .. "." .. language

  local qfound = utils.find_file_inside_folder(directory .. "/" .. question_slug, question_slug .. "." .. language)

  if not qfound then
    vim.api.nvim_command(":silent !touch " .. file)
    vim.api.nvim_command("edit! " .. file)
    vim.api.nvim_command("LBReset")
  else
    vim.api.nvim_command("edit! " .. file)
  end
  vim.api.nvim_command("LCQuestion")
end

local function filter_problems(bufnr, opts)
  local cancel = function() end
  return function(prompt)
    return display_questions(prompt)
  end
end

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
      map("n", "<CR>", select_problem)
      return true
    end,
  })
  :find()
