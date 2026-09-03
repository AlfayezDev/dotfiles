-- Minimal Neovim config for the Zed Oil task.
-- Keep this isolated from the full editor config so opening Oil does not eagerly
-- initialize LSP, completion, Telescope, Treesitter, or unrelated plugins.
vim.g.oil_open_in_zed = 1
vim.g.oil_defer_open = 1
vim.g.have_nerd_font = true
vim.g.mapleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.laststatus = 2
vim.cmd 'filetype on'

_G.gh = function(repo) return 'https://github.com/' .. repo end

dofile(vim.fn.stdpath('config') .. '/lua/custom/plugins/oil.lua')
