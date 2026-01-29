-- return { -- [colorscheme]
--
--   -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
--   'folke/tokyonight.nvim',
--   priority = 1000, -- Make sure to load this before all the other start plugins.
--   init = function()
--     vim.cmd.colorscheme 'tokyonight'
--     vim.cmd.hi 'Comment gui=none'
--   end,
-- }
return {
  'ellisonleao/gruvbox.nvim',
  init = function()
    require('gruvbox').setup {
      contrast = 'hard',
      transparent_mode = true,
      dim_inactive = false,
    }
    vim.cmd.colorscheme 'gruvbox'
    vim.cmd.hi 'Comment gui=none'
  end,
}
