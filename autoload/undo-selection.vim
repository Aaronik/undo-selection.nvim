" This is a vim autoload file for undo_selection.vim

if exists('g:undo_selection_loaded')
  finish
endif
let g:undo_selection_loaded = 1

runtime! plugin/undo-selection.vim
