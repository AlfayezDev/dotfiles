-- oil.nvim (file editor like dir-tree but edits buffers directly).
-- Lazy: load on first Oil command / `-` press.
vim.keymap.set('n', '-', function()
  vim.pack.add { gh 'stevearc/oil.nvim', gh 'nvim-tree/nvim-web-devicons' }
  _G.CustomOilBar = function()
    local path = vim.fn.expand '%':gsub('oil://', '')
    return '  ' .. vim.fn.fnamemodify(path, ':.')
  end
  require('oil').setup {
    columns = { 'icon' },
    keymaps = {
      ['<C-h>'] = false, ['<C-l>'] = false, ['<C-k>'] = false, ['<C-j>'] = false,
      ['<M-h>'] = 'actions.select_split',
    },
    win_options = { winbar = '%{v:lua.CustomOilBar()}' },
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name, _)
        return vim.tbl_contains({ 'dev-tools.locks', 'dune.lock', '_build' }, name)
      end,
    },
  }
  vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
  vim.keymap.set('n', '<space>-', require('oil').toggle_float, { desc = 'Open parent dir (float)' })
  vim.cmd 'Oil'
end, { desc = 'Open parent directory' })
