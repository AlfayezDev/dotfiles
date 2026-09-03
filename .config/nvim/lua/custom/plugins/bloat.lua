-- bloat.nvim — lazy on first :Bloat invocation.
vim.api.nvim_create_user_command('Bloat', function(opts)
  vim.pack.add { gh 'dundalek/bloat.nvim' }
  vim.cmd('Bloat ' .. table.concat(opts.fargs, ' '))
end, { nargs = '*', bang = true })
