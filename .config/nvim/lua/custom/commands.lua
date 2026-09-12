-- Custom user commands

-- :Run <cmd> — run shell command, put output in scratch buffer (editable, copyable)
-- equivalent to: new | setlocal buftype=nofile bufhidden=wipe noswapfile | 0r !<cmd>
vim.api.nvim_create_user_command('Run', function(opts)
  vim.cmd 'new'
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.swapfile = false
  vim.cmd('0r !' .. opts.args)
end, {
  nargs = '+',
  complete = 'shellcmd',
  desc = 'run shell command, output into scratch buffer',
})

-- :R — short alias for :Run
vim.api.nvim_create_user_command('R', function(opts)
  vim.cmd.Run(opts.args)
end, { nargs = '+', complete = 'shellcmd', desc = 'alias for :Run' })

-- <leader>R — fast entry: opens cmdline prefilled with 'Run '
vim.keymap.set('n', '<leader>R', ':Run ', { desc = 'Run shell command into scratch buffer' })
