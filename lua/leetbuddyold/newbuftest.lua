BUFNR_PER_TAB = {}

local BUFFER_OPTIONS = {
  -- swapfile = false,
  -- buftype = "nofile",
  modifiable = false,
  filetype = "NvimTree",
  -- bufhidden = "wipe",
  -- buflisted = false,
}

function get_bufnr()
  return BUFNR_PER_TAB[vim.api.nvim_get_current_tabpage()]
end

local function create_buffer(bufnr)
  local tab = vim.api.nvim_get_current_tabpage()
  BUFNR_PER_TAB[tab] = bufnr or vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(get_bufnr(), "NvimTree_" .. tab)

  for option, value in pairs(BUFFER_OPTIONS) do
    vim.bo[get_bufnr()][option] = value
  end

  -- events._dispatch_tree_attached_post(M.get_bufnr())
end

create_buffer()
