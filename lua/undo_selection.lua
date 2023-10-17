-- This file is called undo_selection.lua, it's a neovim plugin.

local M = {}

function M.undo_selection()
  vim.cmd("normal! u")
end

return M
