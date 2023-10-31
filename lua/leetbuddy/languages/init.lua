local function get_langs()
  local info = debug.getinfo(1, "S")
  local module_directory = string.match(info.source, "^@(.*)/")
  local module_filename = string.match(info.source, "/([^/]*)$")

  local function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "' .. directory .. '"')
    for filename in pfile:lines() do ---@diagnostic disable-line: need-check-nil
      i = i + 1
      t[i] = filename
    end
    pfile:close() ---@diagnostic disable-line: need-check-nil
    return t
  end

  local config_files = vim.tbl_filter(function(filename)
    local is_lua_module = string.match(filename, "[.]lua$")
    local is_this_file = filename == module_filename
    local is_plugin_file = filename == "plugins.lua"
    return is_lua_module and not is_this_file and not is_plugin_file
  end, scandir(module_directory))

  local langs = {}
  for _, filename in ipairs(config_files) do
    local config_module = string.match(filename, "(.+).lua$")
    langs[config_module] = require("leetbuddy.languages." .. config_module)
  end
  return langs
end

return get_langs()
