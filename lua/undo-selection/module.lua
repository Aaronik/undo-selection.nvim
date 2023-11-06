---@class UndoSelectionModule
local M = {}

local util = require('util')

local function _traverse_undotree(opts, entries, level)
  local undolist = {}
  -- create diffs for each entry in our undotree
  for i = #entries, 1, -1 do
    -- grab the buffer as it is after this iteration's undo state
    vim.cmd("silent undo " .. entries[i].seq)
    local buffer_after_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) or {}
    local buffer_after = table.concat(buffer_after_lines, "\n")

    -- grab the buffer as it is after this undo state's parent
    vim.cmd("silent undo")
    local buffer_before_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) or {}
    local buffer_before = table.concat(buffer_before_lines, "\n")

    -- create temporary vars and prepare this iteration
    local diff = ""
    local ordinal = ""
    local additions = {}
    local deletions = {}
    local on_hunk_callback = function(start_a, count_a, start_b, count_b)
      -- build diff file header for this hunk, this is important for delta to syntax highlight
      -- TODO: timestamps are being omitted, but could be included here
      diff = vim.fn.expand("%")
      diff = "--- " .. diff .. "\n+++ " .. diff .. "\n"
      -- build diff location header for this hunk, this is important for delta to show line numbers
      diff = diff .. "@@ -" .. start_a
      if count_a ~= 1 then
        diff = diff .. "," .. count_a
      end
      diff = diff .. " +" .. start_b
      if count_b ~= 1 then
        diff = diff .. "," .. count_b
      end
      diff = diff .. " @@"
      -- get front context based on options
      local context_lines = 0

      if opts.diff_context_lines ~= nil then
        context_lines = opts.diff_context_lines
      end

      for i = start_a - context_lines, start_a - 1 do
        if buffer_before_lines[i] ~= nil then
          diff = diff .. "\n " .. buffer_before_lines[i]
        end
      end

      -- get deletions
      for i = start_a, start_a + count_a - 1 do
        diff = diff .. "\n-" .. buffer_before_lines[i]
        table.insert(deletions, buffer_before_lines[i])
        ordinal = ordinal .. buffer_before_lines[i]
      end

      -- get additions
      for i = start_b, start_b + count_b - 1 do
        diff = diff .. "\n+" .. buffer_after_lines[i]
        table.insert(additions, buffer_after_lines[i])
        ordinal = ordinal .. buffer_after_lines[i]
      end

      -- and finally, get some more context in the back
      for i = start_a + count_a, start_a + count_a + context_lines - 1 do
        if buffer_before_lines[i] ~= nil then
          diff = diff .. "\n " .. buffer_before_lines[i]
        end
      end

      -- terminate all this with a newline, so we're ready for the next hunk
      diff = diff .. "\n"
    end

    -- do the diff using our internal diff function
    vim.diff(buffer_before, buffer_after, {
      result_type = "indices",
      on_hunk = on_hunk_callback,
      algorithm = "patience",
    })

    -- use the data we just created to feed into our finder later
    table.insert(undolist, {
      seq = entries[i].seq,                   -- save state number, used in display and to restore
      alt = level,                            -- current level, i.e. how deep into alt branches are we, used to graph
      first = i == #entries,                  -- whether this is the first node in this branch, used to graph
      time = entries[i].time,                 -- save state time, used in display
      ordinal = ordinal,                      -- a long string of all additions and deletions, used for search
      diff = diff,                            -- the proper diff, used for preview
      additions = additions,                  -- all additions, used to yank a result
      deletions = deletions,                  -- all deletions, used to yank a result
      bufnr = vim.api.nvim_get_current_buf(), -- for which buffer this telescope was invoked, used to restore
    })

    -- descend recursively into alternate histories of undo states
    if entries[i].alt ~= nil then
      local alt_undolist = _traverse_undotree(opts, entries[i].alt, level + 1)
      -- pretend these results are our results
      for _, elem in pairs(alt_undolist) do
        table.insert(undolist, elem)
      end
    end
  end
  return undolist
end

local function build_undolist(opts)
  -- save our current cursor
  local cursor = vim.api.nvim_win_get_cursor(0)

  -- get all diffs
  local ut = vim.fn.undotree()

  -- TODO: maybe use this opportunity to limit the number of root nodes we process overall, to ensure good performance
  local undolist = _traverse_undotree(opts, ut.entries, 0)

  print('undolist:')
  util.print_table(undolist)

  -- restore everything after all diffs have been created
  -- BUG: `gi` (last insert location) is being killed by our method, we should save that as well
  vim.cmd("silent undo " .. ut.seq_cur)
  vim.api.nvim_win_set_cursor(0, cursor)

  return undolist
end

-- The main function
M.undo_selection = function()
  -- local selection = M.get_visual_selection()
  -- print('selection:')
  -- util.print_table(selection)

  -- local changes = M.find_undo_history_for_selection(selection)
  -- print('changes')
  -- util.print_table(changes)

  local undolist = build_undolist({})
  print('undolist')
  util.print_table(undolist)
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

return M
