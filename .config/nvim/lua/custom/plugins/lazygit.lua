-- lazygit.nvim — lazy on first <leader>gg or :LazyGit command.
vim.api.nvim_create_user_command('LazyGit', function(opts)
  vim.pack.add { gh 'kdheepak/lazygit.nvim' }
  vim.g.lazygit_use_neovim_remote = 1
  if vim.fn.executable 'nvr' == 1 then
    vim.env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
  end
  pcall(require('telescope').load_extension, 'lazygit')
  -- Re-run the command now that the plugin is loaded.
  vim.cmd('LazyGit ' .. table.concat(opts.fargs, ' '))
end, { nargs = '*', bang = true })

vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })
