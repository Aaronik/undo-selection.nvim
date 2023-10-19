-- This file is called undo_selection.lua, it's a neovim plugin.

local M = {}

-- returns a table with the current visual selection
local function get_visual_selection()
  local selection = {}
  selection.start_line = vim.fn.getpos("'<")[2]
  selection.end_line = vim.fn.getpos("'>")[2]
  selection.start_column = vim.fn.getpos("'<")[3]
  selection.end_column = vim.fn.getpos("'>")[3]
  return selection
end

function M.undo_selection()
  return get_visual_selection()
end

return M
