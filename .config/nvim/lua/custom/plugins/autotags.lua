-- nvim-ts-autotag — lazy on first HTML/JSX-like buffer.
local tag_filetypes = { 'html', 'javascriptreact', 'typescriptreact', 'jsx', 'tsx', 'vue', 'svelte', 'xml' }
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('ts-autotag-lazy', { clear = true }),
  pattern = tag_filetypes,
  once = true,
  callback = function()
    vim.pack.add { gh 'windwp/nvim-ts-autotag' }
    require('nvim-ts-autotag').setup {}
  end,
})
