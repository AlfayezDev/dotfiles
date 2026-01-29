return {
  'mg979/vim-visual-multi',
  lazy = false,
  branch = 'master',
  init = function()
    vim.g.VM_maps = {
      ['Find Under'] = '<C-n>',
    }
  end,
}
