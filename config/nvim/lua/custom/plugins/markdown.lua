-- render-markdown.nvim — lazy on first markdown buffer.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('render-markdown-lazy', { clear = true }),
  pattern = 'markdown',
  once = true,
  callback = function()
    vim.pack.add {
      gh 'MeanderingProgrammer/render-markdown.nvim',
      gh 'nvim-tree/nvim-web-devicons',
    }
    require('render-markdown').setup {
      injections = { gitcommit = { enabled = false } },
    }
  end,
})
