---@class UndoSelectionModule
local M = {}

local util = require('util')

local function _traverse_undotree(opts, entries, level)
  -- function body goes here
end

M.traverse_undotree = _traverse_undotree

-- The main function
M.undo_selection = function()
  local selection = M.get_visual_selection()
  print('selection:')
  util.print_table(selection)

  local changes = M.find_undo_history_for_selection(selection)
  print('changes')
  util.print_table(changes)

  M.undo_changes(changes)
end

-- Just get some data about the current visual selection
M.get_visual_selection = function()
  local selection = {}
  selection.start_line = vim.fn.getpos("'<")[2]
  selection.end_line = vim.fn.getpos("'>")[2]
  selection.start_column = vim.fn.getpos("'<")[3]
  selection.end_column = vim.fn.getpos("'>")[3]
  return selection
end

-- Gets relevant information about the undo tree which we will then consume
-- to apply the changes from the relevant section of undo.
M.find_undo_history_for_selection = function(selection)
  local history = vim.fn['undotree']()
  local changes = {}

  for _, entry in ipairs(history.entries) do
    if entry.seq >= selection.start_line and entry.seq <= selection.end_line then
      table.insert(changes, {seq = entry.seq, text = entry.text})
    end
  end

  return changes
end

-- Consume the information from find_undo_history_for_selection
-- and apply the changes to the selected lines in the buffer.
M.undo_changes = function(changes)
  for _, change in ipairs(changes) do
    vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), change.seq - 1, change.seq, false, {change.text})
  end
end

-- * get the visual selection
-- * find the lines from the undo history
-- * undo just those lines

return M

-- Here is the documentation for the undotree() function:
--
-- undotree()						*undotree()*
-- 		Return the current state of the undo tree in a dictionary with
-- 		the following items:
-- 		  "seq_last"	The highest undo sequence number used.
-- 		  "seq_cur"	The sequence number of the current position in
-- 				the undo tree.  This differs from "seq_last"
-- 				when some changes were undone.
-- 		  "time_cur"	Time last used for |:earlier| and related
-- 				commands.  Use |strftime()| to convert to
-- 				something readable.
-- 		  "save_last"	Number of the last file write.  Zero when no
-- 				write yet.
-- 		  "save_cur"	Number of the current position in the undo
-- 				tree.
-- 		  "synced"	Non-zero when the last undo block was synced.
-- 				This happens when waiting from input from the
-- 				user.  See |undo-blocks|.
-- 		  "entries"	A list of dictionaries with information about
-- 				undo blocks.

-- 		The first item in the "entries" list is the oldest undo item.
-- 		Each List item is a |Dictionary| with these items:
-- 		  "seq"		Undo sequence number.  Same as what appears in
-- 				|:undolist|.
-- 		  "time"	Timestamp when the change happened.  Use
-- 				|strftime()| to convert to something readable.
-- 		  "newhead"	Only appears in the item that is the last one
-- 				that was added.  This marks the last change
-- 				and where further changes will be added.
-- 		  "curhead"	Only appears in the item that is the last one
-- 				that was undone.  This marks the current
-- 				position in the undo tree, the block that will
-- 				be used by a redo command.  When nothing was
-- 				undone after the last change this item will
-- 				not appear anywhere.
-- 		  "save"	Only appears on the last block before a file
-- 				write.  The number is the write count.  The
-- 				first write has number 1, the last one the
-- 				"save_last" mentioned above.
-- 		  "alt"		Alternate entry.  This is again a List of undo
-- 				blocks.  Each item may again have an "alt"
-- 				item.
