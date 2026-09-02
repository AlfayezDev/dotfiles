-- leap.nvim — lazy on first s/S/gs press.
local function load_leap()
  vim.pack.add { gh 'ggandor/leap.nvim' }
  local leap = require 'leap'
  leap.add_default_mappings(true)
  vim.keymap.del({ 'x', 'o' }, 'x')
  vim.keymap.del({ 'x', 'o' }, 'X')
end

for _, lhs in ipairs({ 's', 'S' }) do
  vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
    load_leap()
    -- Feed the original key now that leap is mapped.
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, false, true), 'n', false)
  end, { desc = 'Leap (lazy)' })
end
vim.keymap.set({ 'n', 'x', 'o' }, 'gs', function()
  load_leap()
  vim.api.nvim_feedkeys('gs', 'n', false)
end, { desc = 'Leap from Windows (lazy)' })
