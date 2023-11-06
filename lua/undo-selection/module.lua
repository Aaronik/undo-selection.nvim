---@class UndoSelectionModule
local M = {}

local util = require('util')

M.undo_selection = function()
  local selection = M.get_visual_selection()
  print('selection:')
  util.print_table(selection)

  local changes = M.find_undo_history_for_selection(selection)
  print('changes')
  util.print_table(changes)

  M.undo_changes(changes)
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

-- history will look like:
-- seq_cur: 103
-- save_cur: 36
-- seq_last: 103
-- time_cur: 1699232889
-- save_last: 36
-- change
--   time: 1699226596
--   seq: 1
--   seq_last: 107
-- entries:
-- 1:
-- alt:
--   1:
--     alt:
--       1:
--         time: 1699227474
--         save: 10
--         seq: 27
--     save: 12
--     time: 1699227713
--     seq: 28
--   2:
--     time: 1699227736
--     seq: 29
-- seq: 30
-- time: 1699227787
--   2:
--     time: 1699226659
--     save: 1
--     newhead: 1
--     seq: 2
--   etc

