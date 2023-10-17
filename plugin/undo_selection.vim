" This is the plugin/undo_selection.vim file, the main entrypoint of a neovim
" plugin I'm developing called undo_selection. It will be developed in lua,
" so we just need to call the appropriate lua function.

" Call the lua function
lua require('undo_selection').undo_selection()

