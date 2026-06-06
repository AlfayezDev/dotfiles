return {
  'mg979/vim-visual-multi',
  lazy = false,
  branch = 'master',
  init = function()
    vim.g.VM_maps = {
      ['Find Under'] = '<C-n>',
    }
  end,
  config = function()
    local group = vim.api.nvim_create_augroup('vm_blink_compat', { clear = true })

    -- After VM exits, clean up any residual buffer-local insert maps
    vim.api.nvim_create_autocmd('User', {
      pattern = 'visual_multi_exit',
      group = group,
      callback = function()
        for _, key in ipairs({
          '<CR>', '<BS>', '<C-w>', '<C-u>', '<C-d>', '<C-^>', '<Del>',
          '<Home>', '<End>', '<C-b>', '<C-f>', '<C-c>', '<C-o>', '<Insert>',
          '<Left>', '<Right>', '<Up>', '<Down>',
          '<C-Right>', '<C-Left>', '<C-S-Right>', '<C-S-Left>',
          '<C-Up>', '<C-Down>', '<C-S-Up>', '<C-S-Down>',
        }) do
          pcall(vim.keymap.del, 'i', key, { buffer = true })
        end
      end,
    })

    -- Safety net: if VM exited ungracefully (buffer switch during insert),
    -- clean up on next BufEnter
    vim.api.nvim_create_autocmd('BufEnter', {
      group = group,
      callback = function()
        if not vim.b.visual_multi then
          for _, key in ipairs({ '<CR>', '<BS>', '<C-e>', '<C-n>', '<C-p>' }) do
            pcall(vim.keymap.del, 'i', key, { buffer = true })
          end
        end
      end,
    })
  end,
}
