package = "undo-selection"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/Aaronik/undo_selection.nvim.git"
}
description = {
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      undo_selection = "lua/undo_selection.lua"
   },
   copy_directories = {
      "doc"
   }
}
