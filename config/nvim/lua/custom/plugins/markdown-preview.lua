-- markdown-preview.nvim — lazy on first markdown buffer (also installs yarn deps
-- via the PackChanged build hook in init.lua).
vim.g.mkdp_filetypes = { 'markdown' }

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('markdown-preview-lazy', { clear = true }),
  pattern = 'markdown',
  once = true,
  callback = function()
    vim.pack.add { gh 'iamcco/markdown-preview.nvim' }
  end,
})
