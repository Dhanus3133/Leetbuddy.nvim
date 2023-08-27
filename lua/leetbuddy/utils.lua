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
    contents[i] = string.format("%s%s%s", left_padding, line:gsub("\r", ""), right_padding)
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
  return string.gsub(string.gsub(file, "^%d+%-", ""), "%.[^.]+$", "")
end

function M.read_file_contents(path)
  local file = io.open(path, "r")
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

return M
