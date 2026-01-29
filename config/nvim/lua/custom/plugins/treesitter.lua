return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
  keys = {
    { '<c-space>', desc = 'Increment Selection' },
    { '<bs>', desc = 'Decrement Selection', mode = 'x' },
  },
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  opts = {
    ensure_installed = {
      'bash',
      'python',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'vim',
      'vimdoc',
      'zig',
      'typescript',
      'javascript',
      'wesl',
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    fold = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-space>',
        node_incremental = '<C-space>',
        scope_incremental = '<C-s>',
        node_decremental = '<BS>',
      },
    },
  },

  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {

        ['af'] = '@function.outer',
        ['if'] = '@function.inner',

        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',

        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',

        ['ab'] = '@block.outer',
        ['ib'] = '@block.inner',

        ['a/'] = '@comment.outer',

        ['ai'] = '@conditional.outer',
        ['ii'] = '@conditional.inner',

        ['al'] = '@loop.outer',
        ['il'] = '@loop.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        [']f'] = '@function.outer',
        [']c'] = '@class.outer',
        [']a'] = '@parameter.inner',
        [']b'] = '@block.outer',
        [']i'] = '@conditional.outer',
        [']l'] = '@loop.outer',
        [']s'] = '@statement.outer',
      },
      goto_next_end = {
        [']F'] = '@function.outer',
        [']C'] = '@class.outer',
        [']B'] = '@block.outer',
      },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[c'] = '@class.outer',
        ['[a'] = '@parameter.inner',
        ['[b'] = '@block.outer',
        ['[i'] = '@conditional.outer',
        ['[l'] = '@loop.outer',
        ['[s'] = '@statement.outer',
      },
      goto_previous_end = {
        ['[F'] = '@function.outer',
        ['[C'] = '@class.outer',
        ['[B'] = '@block.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>sn'] = '@parameter.inner',
        ['<leader>sf'] = '@function.outer',
      },
      swap_previous = {
        ['<leader>sp'] = '@parameter.inner',
        ['<leader>sF'] = '@function.outer',
      },
    },
    lsp_interop = {
      enable = true,
      border = 'none',
      floating_preview_opts = {},
      peek_definition_code = {
        ['<leader>pf'] = '@function.outer',
        ['<leader>pc'] = '@class.outer',
      },
    },
  },
  config = function(_, opts)
    require('nvim-treesitter.install').prefer_git = true

    local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'
    local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
    parser_config.wesl = {
      install_info = {
        url = 'https://github.com/wgsl-tooling-wg/tree-sitter-wesl',
        files = { 'src/parser.c', 'src/scanner.c' },
        branch = 'main',
      },
    }
    vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move)
    vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_opposite)

    vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f)
    vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F)
    vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t)
    vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T)

    vim.keymap.set('n', '<leader>z', function()
      local ts_fold = require 'nvim-treesitter.fold'
      if ts_fold.get_fold_level() > 0 then
        vim.cmd 'foldclose'
      else
        vim.cmd 'foldopen'
      end
    end, { desc = 'Toggle fold' })

    vim.keymap.set('n', '<leader>df', function()
      require('nvim-treesitter.localtionlist').function_definitions()
    end, { desc = 'List functions' })
    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.opt.foldenable = false
    vim.opt.foldlevel = 99

    vim.keymap.set('n', 'zc', function()
      local line = vim.fn.line '.'
      local fold_level = vim.fn.foldlevel(line)
      if fold_level > 0 then
        vim.cmd 'normal! zc'
      end
    end, { desc = 'Close fold' })

    vim.keymap.set('n', 'zo', function()
      local line = vim.fn.line '.'
      local fold_closed = vim.fn.foldclosed(line)
      if fold_closed ~= -1 then
        vim.cmd 'normal! zo'
      end
    end, { desc = 'Open fold' })

    vim.keymap.set('n', 'za', function()
      local line = vim.fn.line '.'
      local fold_closed = vim.fn.foldclosed(line)
      if fold_closed ~= -1 then
        vim.cmd 'normal! zo'
      else
        local fold_level = vim.fn.foldlevel(line)
        if fold_level > 0 then
          vim.cmd 'normal! zc'
        end
      end
    end, { desc = 'Toggle fold' })

    vim.keymap.set('n', '<leader>zc', 'zM', { desc = 'Close all folds' })
    vim.keymap.set('n', '<leader>zo', 'zR', { desc = 'Open all folds' })
    vim.keymap.set('n', '<leader>z', 'za', { desc = 'Toggle fold under cursor' })

    require('nvim-treesitter.configs').setup(opts)
  end,
}
