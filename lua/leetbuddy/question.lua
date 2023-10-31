local utils = require("leetbuddy.utils")
local curl = require("plenary.curl")
local config = require("leetbuddy.config")
local headers = require("leetbuddy.headers")

local M = {}

local question_content, previous_question_slug, question_id

local old_contents

local function question_display(contents, oldqbufnr)
  Qbufnr = oldqbufnr or vim.api.nvim_create_buf(true, true)

  local width = math.ceil(math.min(vim.o.columns, math.max(90, vim.o.columns - 20)))
  local height = math.ceil(math.min(vim.o.lines, math.max(25, vim.o.lines - 10)))

  local row = math.ceil(vim.o.lines - height) * 0.5 - 1
  local col = math.ceil(vim.o.columns - width) * 0.5 - 1

  vim.api.nvim_open_win(Qbufnr, true, {
    border = "rounded",
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
  })

  if not oldqbufnr then
    local c = utils.pad(contents)
    vim.api.nvim_buf_set_lines(Qbufnr, 0, -1, true, c)
    vim.api.nvim_buf_set_option(Qbufnr, "swapfile", false)
    vim.api.nvim_buf_set_option(Qbufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(Qbufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(Qbufnr, "buflisted", false)
    vim.api.nvim_buf_set_keymap(Qbufnr, "n", "<esc>", "<cmd>hide<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(Qbufnr, "n", "q", "<cmd>hide<CR>", { noremap = true })
  end

  vim.api.nvim_buf_set_keymap(Qbufnr, "v", "q", "<cmd>hide<CR>", { noremap = true })
  if contents ~= old_contents then
    contents = utils.pad(contents, { pad_top = 1 })
    vim.api.nvim_buf_set_option(Qbufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(Qbufnr, 0, -1, true, contents)
    vim.api.nvim_buf_set_option(Qbufnr, "modifiable", false)
  end

  old_contents = contents

  return Qbufnr
end

function M.fetch_question_api(slug)
  vim.cmd("LBCheckCookies")

  local variables = {
    titleSlug = slug,
  }

  local query = [[
  query questionData($titleSlug: String!) {
    question(titleSlug: $titleSlug) {
      questionId
      questionFrontendId
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
  return vim.json.decode(response["body"])

end

local function fetch_question(slug)
  local body = M.fetch_question_api(slug)
  local question = body["data"]["question"]
  question_id = question["questionId"]
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
  return question["questionFrontendId"] .. ". " .. question["title"] .. "\n" .. content
end

function M.question()
  local buf_name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  if utils.is_in_folder(buf_name, config.directory) then
    local question_slug = utils.get_question_slug(buf_name)
    if previous_question_slug ~= question_slug then
      question_content = utils.split_string_to_table(fetch_question(question_slug))
    end

    previous_question_slug = question_slug
    question_display(question_content, Qbufnr)
  end
end

function M.get_question_id()
  if not question_id then
    local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
    local question_slug = utils.get_question_slug(file)
    local _ = fetch_question(question_slug)
  end
  return question_id
end

return M
