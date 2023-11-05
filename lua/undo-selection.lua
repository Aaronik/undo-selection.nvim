-- main module file
local module = require("undo-selection.module")

---@class Config
local config = {}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.undo_selection = module.undo_selection
M.find_undo_history_for_selection = module.find_undo_history_for_selection
M.get_visual_selection = module.get_visual_selection

-- -- Assigning everything that module exposes to M
-- for k, v in pairs(module) do
--     M[k] = v
-- end

return M
