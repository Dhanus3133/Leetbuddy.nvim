local path = require("plenary.path")

M = {}

M.langSlugToFileExt = {
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

function M.split_string_to_table(str)
  local lines = {}
  for line in str:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  return lines
end

function M.pad(contents, opts)
  vim.validate({ contents = { contents, "t" }, opts = { opts, "t", true } })
  opts = opts or {}
  local left_padding = (" "):rep(opts.pad_left or 1)
  local right_padding = (" "):rep(opts.pad_right or 1)
  for i, line in ipairs(contents) do
    contents[i] =
      string.format("%s%s%s", left_padding, line:gsub("\r", ""), right_padding)
  end
  if opts.pad_top then
    for _ = 1, opts.pad_top do
      table.insert(contents, 1, "")
    end
  end
  if opts.pad_bottom then
    for _ = 1, opts.pad_bottom do
      table.insert(contents, "")
    end
  end
  return contents
end

function M.find_file_inside_folder(folderpath, foldername)
  local folder = io.popen("ls " .. folderpath)
  local files_str = folder:read("*all")

  for line in files_str:gmatch("%s*(.-)%s*\n") do
    if foldername == line then
      return true
    end
  end
  return false
end

function M.is_in_folder(file, folder)
  return string.sub(file, 1, string.len(folder)) == folder
end

function M.get_question_slug(file)
  local folder_name = vim.fn.fnamemodify(M.get_folder(file), ":t")
  local output =
    string.gsub(string.gsub(folder_name, "^%d+%-", ""), "%.[^.]+$", "")
  return output
end

---Get the folder for this question from the buffer name
---@param file string
---@return string
function M.get_folder(file)
  local config = require("leetbuddy.config")
  local parents = path:new(file):parents()
  local prev = file
  for _, current in ipairs(parents) do
    if current == config.directory then
      return prev
    end
    prev = current
  end ---@diagnostic disable-line: missing-return
end

function M.read_file_contents(file_path)
  local file = io.open(file_path, "r")
  if file then
    local contents = file:read("*a")
    file:close()
    return contents
  end
  return nil
end

function M.get_file_extension(filename)
  local _, _, extension = string.find(filename, "%.([^%.]+)$")
  return extension
end

function M.strip_file_extension(file)
  local lastDotIndex = file:find("%.[^%.]*$")
  return file:sub(1, lastDotIndex - 1)
end

function M.get_input_file_path(file_path)
  local directory_path = file_path:match("(.*/)") or ""

  local input_file_path = directory_path .. "input.txt"

  return input_file_path
end

function M.get_question_number_from_file_name(file_name)
  local number = string.match(file_name, "^0*(%d+)%-")

  if number then
    number = tonumber(number)
    return number
  end
  return nil
end

function M.split_test_case_inputs(test_path, num_tests)
  local test_input = M.read_file_contents(test_path)
  local all_parameters = {}
  for param in string.gmatch(test_input, "([^\n]+)") do
    table.insert(all_parameters, param)
  end

  local params_per_test = math.floor(#all_parameters / num_tests)

  local test_case_inputs = {}
  for i = 1, num_tests do
    local test_input_i = {}
    local start_param_idx = (i - 1) * params_per_test + 1
    local end_param_idx = start_param_idx + params_per_test - 1
    for j = start_param_idx, end_param_idx do
      table.insert(test_input_i, all_parameters[j])
    end
    table.insert(test_case_inputs, test_input_i)
  end

  return test_case_inputs
end

---Join the path fragments with the system separator
---@param ... string Path fragments
---@return string path Joined path
function M.path_join(...)
  return table.concat({ ... }, path.path.sep)
end

---Find the first value in the table matching the predicate
---@generic T
---@param pred fun(T): boolean Predicate function
---@param table T[]
---@return T match The first matching value
function M.find_in_table(pred, table)
  return vim.tbl_filter(pred, table)[1]
end

function M.is_in_table(tab, val)
  for _, value in ipairs(tab) do
    if value == val then
      return true
    end
  end

  return false
end

M.P = function(v)
  print(vim.inspect(v))
  return v
end

---@alias FileExtensions
---| "c" # C
---| "cpp" # C++
---| "cs" # C#
---| "dart" # Dart
---| "erl" # Erlang
---| "ex" # Elixir
---| "go" # Go
---| "java" # Java
---| "js" # Javascript
---| "kt" # Kotlin
---| "php" # PHP
---| "py" # Python3
---| "rkt" # Racket
---| "rb" # Ruby
---| "rs" # Rust
---| "scala" # Scala
---| "swift" # Swift
---| "ts" # Typescript

---@alias LeetcodeNames
---| "c" # C
---| "cpp" # C++
---| "csharp" # C#
---| "dart" # Dart
---| "erlang" # Erlang
---| "elixir" # Elixir
---| "golang" # Go
---| "java" # Java
---| "javascript" # Javascript
---| "kotlin" # Kotlin
---| "php" # PHP
---| "python3" # Python3
---| "racket" # Racket
---| "ruby" # Ruby
---| "rust" # Rust
---| "scala" # Scala
---| "swift" # Swift
---| "typescript" # Typescript

LEETBUDDY_SUBMISSION_START = "LEETBUDDY_SUBMISSION_START"
LEETBUDDY_END_SUBMISSION = "LEETBUDDY_END_SUBMISSION"

---@class Language
---@field extension FileExtensions The file extension associated with this language
---@field leetcode_name LeetcodeNames The name of this language in the LeetCode API
---@field comment_chars string The string used to mark comments in this language
---@field preamble string[] Any additional lines to insert before the submission guards e.g. to get LSPs working
M.Language =
  { extension = nil, leetcode_name = nil, comment_chars = nil, preamble = {} } ---@diagnostic disable-line: assign-type-mismatch
M.Language.__index = M.Language

---Create a new language
---@param extension FileExtensions File extension for the language
---@param leetcode_name LeetcodeNames Name of the language in leetcode
---@param comment_chars string Comment chars to use for language
---@return table
function M.Language:new(extension, leetcode_name, comment_chars)
  local o = {
    extension = extension,
    leetcode_name = leetcode_name,
    comment_chars = comment_chars,
  }
  setmetatable(o, M.Language)
  return o
end

---Get the submission file path
---@param folder string Path to the language-specific question folder
---@return string
function M.Language:get_submission_file_path(folder)
  return M.path_join(folder, "submission." .. self.extension)
end

---Get the submission file contents
---@param folder string Path to the question folder
---@return table
function M.Language:get_submission_file_contents(folder)
  local start_index, end_index
  local contents = vim.fn.readfile(self:get_submission_file_path(folder))
  for index, line in ipairs(contents) do
    if string.find(line, LEETBUDDY_SUBMISSION_START) then
      start_index = index + 1
    end
    if string.find(line, LEETBUDDY_END_SUBMISSION) then
      end_index = index - 1
    end
  end
  local filtered_contents = { unpack(contents, start_index, end_index) }
  return filtered_contents
end

---Put the contents from the code snippet into the submission file
---@param folder string Path to the submission folder
---@param code_snippet table Code snippet from LeetCode
function M.Language:put_submission_contents(folder, code_snippet)
  local submission_file = self:get_submission_file_path(folder)
  vim.cmd(":silent !touch " .. submission_file)
  local wrapped_contents = vim.tbl_flatten({
    self.preamble,
    self.comment_chars .. " " .. LEETBUDDY_SUBMISSION_START,
    "",
    code_snippet,
    "",
    self.comment_chars .. " " .. LEETBUDDY_END_SUBMISSION,
  })
  vim.fn.writefile(wrapped_contents, submission_file)
end

---Get the path to the input file
---@param folder string Path to the language-specific question folder
---@return string
function M.Language:get_input_file_path(folder)
  return M.path_join(folder, "input.txt")
end

---Get the input file contents
---@param folder string Question folder
---@return string[]
function M.Language:get_input_contents(folder)
  return vim.fn.readfile(self:get_input_file_path(folder))
end

---Put the contents into the input file
---@param folder string Question folder
function M.Language:put_input_contents(folder, contents)
  vim.fn.writefile(contents, self:get_input_file_path(folder))
end

function M.Language:get_folder(file_path)
  local folder = M.get_folder(file_path)
  return M.path_join(folder, self.leetcode_name)
end

---Create any additional files and folders required for this language
---@param folder string Question folder
---@param submission_contents table Code snippet from LeetCode
---@param input_contents table Input contents from LeetCode
function M.Language:make_folder(folder, submission_contents, input_contents)
  vim.cmd(":silent !mkdir -p " .. folder)
  self:create_additional_files_and_folders(folder)
  self:put_submission_contents(folder, submission_contents)
  self:put_input_contents(folder, input_contents)
end

function M.Language:create_additional_files_and_folders(folder) ---@diagnostic disable-line: unused-local
end

return M
