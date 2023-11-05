-- Utility functions
local M = {}

-- function that prints a table
function M.print_table(t)
  for k, v in pairs(t) do
    if type(v) == "table" then
      vim.api.nvim_command("echo '" .. k .. ": '")
      M.print_table(v)
    else
      vim.api.nvim_command("echo '" .. k .. ": " .. tostring(v) .. "'")
    end
  end
  vim.api.nvim_command("echo 'Press any key to continue'")
  vim.api.nvim_command("silent! call getchar()")
end

return M
