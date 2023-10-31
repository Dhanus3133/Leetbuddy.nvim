local utils = require("leetbuddy.utils")
local lang = utils.Language:new("rs", "rust", "//")

lang.preamble = {
  "pub struct Solution;",
}

function lang:create_additional_files_and_folders(folder)
  vim.cmd(":silent !mkdir -p " .. utils.path_join(folder, "src"))
  local cargo_toml = utils.path_join(folder, "Cargo.toml")
  vim.fn.writefile({
    "[package]",
    'name = "rust"',
    'version = "0.1.0"',
    'edition = "2021"',
    "",
    "# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html",
    "",
    "[dependencies]",
  }, cargo_toml)
end

function lang:get_submission_file_path(folder)
  return utils.path_join(folder, "src", "lib.rs")
end

return lang
