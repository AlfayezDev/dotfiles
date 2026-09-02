-- nvim-spectre — lazy on first <leader>S press.
vim.keymap.set('n', '<leader>S', function()
  vim.pack.add { gh 'nvim-pack/nvim-spectre' }
  require('spectre').toggle()
end, { desc = 'Toggle Spectre' })
