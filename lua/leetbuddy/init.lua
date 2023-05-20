local M = {}

M.user_config = require("leetbuddy.default_config")

M.setup = function(opts)
  M.user_config = vim.tbl_deep_extend("force", M.user_config, opts)
end

return M
