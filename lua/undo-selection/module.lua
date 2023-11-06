---@class UndoSelectionModule
local M = {}

local util = require('util')

M.undo_selection = function()
  local selection = M.get_visual_selection()
  print('selection:')
  util.print_table(selection)

  local undo_history = M.find_undo_history_for_selection(selection)
  print('undo_history')
  util.print_table(undo_history)
end

M.get_visual_selection = function()
  local selection = {}
  selection.start_line = vim.fn.getpos("'<")[2]
  selection.end_line = vim.fn.getpos("'>")[2]
  selection.start_column = vim.fn.getpos("'<")[3]
  selection.end_column = vim.fn.getpos("'>")[3]
  return selection
end

M.find_undo_history_for_selection = function(selection)
  local history = vim.fn['undotree']()
  local changes = {}

  for _, entry in ipairs(history.entries) do
    if entry.seq >= selection.start_line and entry.seq <= selection.end_line then
      table.insert(changes, entry)
    end
  end

  return changes
end

M.undo_changes = function(changes)
  for _, change in ipairs(changes) do
    vim.api.nvim_call_function('undo', {change.seq})
  end
end

-- * get the visual selection
-- * find the lines from the undo history
-- * undo just those lines

return M
