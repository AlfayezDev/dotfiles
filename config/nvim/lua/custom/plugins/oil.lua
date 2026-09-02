-- oil.nvim (file editor like dir-tree but edits buffers directly).
-- Lazy: load on first Oil command / `-` press, or when nvim opens a directory (e.g. `vv` = `nvim .`).
vim.g.loaded_netrwPlugin = 1 -- stop built-in netrw so oil owns directory buffers

local function load_oil(dir)
  vim.pack.add { gh 'stevearc/oil.nvim', gh 'nvim-tree/nvim-web-devicons' }
  _G.CustomOilBar = function()
    local path = vim.fn.expand '%':gsub('oil://', '')
    return '  ' .. vim.fn.fnamemodify(path, ':.')
  end
  require('oil').setup {
    columns = { 'icon' },
    win_options = { winbar = '%{v:lua.CustomOilBar()}' },
    keymaps = (function()
      local km = {
        ['<C-h>'] = false, ['<C-l>'] = false, ['<C-k>'] = false, ['<C-j>'] = false,
        ['<M-h>'] = 'actions.select_split',
      }
      -- Spawned from Zed task (`-` in Zed): <CR> on a file opens it in Zed and quits.
      if vim.g.oil_open_in_zed then
        km['<CR>'] = function()
          local oil = require 'oil'
          local entry, dir = oil.get_cursor_entry(), oil.get_current_dir()
          if entry and entry.type == 'file' and dir then
            vim.fn.jobstart({ 'zeditor', dir .. entry.name }, { detach = true })
            vim.cmd 'silent! qa!'
          else
            require('oil.actions').select.callback()
          end
        end
      end
      return km
    end)(),
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name, _)
        return vim.tbl_contains({ 'dev-tools.locks', 'dune.lock', '_build' }, name)
      end,
    },
  }
  vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
  vim.keymap.set('n', '<space>-', require('oil').toggle_float, { desc = 'Open parent dir (float)' })
  if dir then
    require('oil').open(dir)
  else
    vim.cmd 'Oil'
  end
end

vim.keymap.set('n', '-', function()
  load_oil()
end, { desc = 'Open parent directory' })

-- `nvim .` / `nvim somedir` -> open oil on that dir instead of netrw
vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'oil: open dir arg',
  callback = function()
    for i = 0, vim.fn.argc() - 1 do
      local arg = vim.fn.argv(i)
      if arg ~= '' and vim.fn.isdirectory(vim.fn.expand(arg)) == 1 then
        load_oil(vim.fn.fnamemodify(arg, ':p'))
        return
      end
    end
  end,
})
