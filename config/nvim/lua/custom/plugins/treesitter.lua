local languages = {
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
  'json',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
    config = function()
      -- Register custom parser before install (new main branch API)
      vim.api.nvim_create_autocmd('User', {
        pattern = 'TSUpdate',
        callback = function()
          require('nvim-treesitter.parsers').wesl = {
            install_info = {
              url = 'https://github.com/wgsl-tooling-wg/tree-sitter-wesl',
              files = { 'src/parser.c', 'src/scanner.c' },
              branch = 'main',
            },
          }
        end,
      })

      -- Install parsers (async, skips already-installed)
      local all_langs = {}
      for _, lang in ipairs(languages) do
        all_langs[#all_langs + 1] = lang
      end
      all_langs[#all_langs + 1] = 'wesl'
      require('nvim-treesitter').install(all_langs)

      -- Use built-in treesitter for highlight, indent, folding
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter.setup', {}),
        callback = function(args)
          local buf = args.buf
          local filetype = args.match
          local lang = vim.treesitter.language.get_lang(filetype) or filetype
          if not pcall(vim.treesitter.language.add, lang) then
            return
          end
          pcall(vim.treesitter.start, buf, lang)
        end,
      })

      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.opt.foldenable = false
      vim.opt.foldlevel = 99

      -- Incremental selection using treesitter node navigation
      -- Ctrl+Space to select current node / expand to parent, BS to select child
      vim.keymap.set('n', '<C-Space>', function()
        local buf = vim.api.nvim_get_current_buf()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local node = vim.treesitter.get_node({ bufnr = buf, row = row - 1, col = col })
        if node then
          local sr, sc, er, ec = node:range()
          vim.fn.setpos("'<", { buf, sr + 1, sc, 0 })
          vim.fn.setpos("'>", { buf, er + 1, ec - 1, 0 })
          vim.cmd 'normal! gv'
        end
      end, { desc = 'Treesitter select node' })

      vim.keymap.set('x', '<C-Space>', function()
        local buf = vim.api.nvim_get_current_buf()
        local _, ec = unpack(vim.fn.getpos("'>"))
        local _, sc = unpack(vim.fn.getpos("'<"))
        local row = vim.fn.line "." - 1
        local col = math.max(0, math.min(ec, sc) - 1)
        local node = vim.treesitter.get_node({ bufnr = buf, row = row, col = col })
        if node then
          local parent = node:parent()
          while parent do
            local sr, sc2, er, ec2 = parent:range()
            local cur_sr = vim.fn.line "'" - 1
            local cur_er = vim.fn.line "'>"
            if sr < cur_sr or (sr == cur_sr and er + 1 > cur_er) then
              vim.fn.setpos("'<", { buf, sr + 1, sc2, 0 })
              vim.fn.setpos("'>", { buf, er + 1, math.max(1, ec2), 0 })
              vim.cmd 'normal! gv'
              return
            end
            parent = parent:parent()
          end
        end
      end, { desc = 'Treesitter expand selection' })

      vim.keymap.set('x', '<BS>', function()
        local buf = vim.api.nvim_get_current_buf()
        local row = vim.fn.line "." - 1
        local col = vim.fn.col "." - 1
        local node = vim.treesitter.get_node({ bufnr = buf, row = row, col = col })
        if node then
          local child = node:child(0)
          if child then
            local sr, sc, er, ec = child:range()
            vim.fn.setpos("'<", { buf, sr + 1, sc, 0 })
            vim.fn.setpos("'>", { buf, er + 1, math.max(1, ec), 0 })
            vim.cmd 'normal! gv'
          end
        end
      end, { desc = 'Treesitter shrink selection' })

      -- Fold keymaps
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
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local move = require 'nvim-treesitter-textobjects.move'
      local swap = require 'nvim-treesitter-textobjects.swap'

      -- Select textobjects
      local select_keys = {
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
      }
      for key, query in pairs(select_keys) do
        vim.keymap.set({ 'x', 'o' }, key, function()
          select.select_textobject(query, 'textobjects')
        end, { desc = 'Select ' .. query })
      end

      -- Move textobjects
      local move_next_start = {
        [']f'] = '@function.outer',
        [']c'] = '@class.outer',
        [']a'] = '@parameter.inner',
        [']b'] = '@block.outer',
        [']i'] = '@conditional.outer',
        [']l'] = '@loop.outer',
        [']s'] = '@statement.outer',
      }
      for key, query in pairs(move_next_start) do
        vim.keymap.set({ 'n', 'x', 'o' }, key, function()
          move.goto_next_start(query, 'textobjects')
        end, { desc = 'Next ' .. query })
      end

      local move_next_end = {
        [']F'] = '@function.outer',
        [']C'] = '@class.outer',
        [']B'] = '@block.outer',
      }
      for key, query in pairs(move_next_end) do
        vim.keymap.set({ 'n', 'x', 'o' }, key, function()
          move.goto_next_end(query, 'textobjects')
        end, { desc = 'Next end ' .. query })
      end

      local move_prev_start = {
        ['[f'] = '@function.outer',
        ['[c'] = '@class.outer',
        ['[a'] = '@parameter.inner',
        ['[b'] = '@block.outer',
        ['[i'] = '@conditional.outer',
        ['[l'] = '@loop.outer',
        ['[s'] = '@statement.outer',
      }
      for key, query in pairs(move_prev_start) do
        vim.keymap.set({ 'n', 'x', 'o' }, key, function()
          move.goto_previous_start(query, 'textobjects')
        end, { desc = 'Prev ' .. query })
      end

      local move_prev_end = {
        ['[F'] = '@function.outer',
        ['[C'] = '@class.outer',
        ['[B'] = '@block.outer',
      }
      for key, query in pairs(move_prev_end) do
        vim.keymap.set({ 'n', 'x', 'o' }, key, function()
          move.goto_previous_end(query, 'textobjects')
        end, { desc = 'Prev end ' .. query })
      end

      -- Swap textobjects
      vim.keymap.set('n', '<leader>sn', function()
        swap.swap_next '@parameter.inner'
      end, { desc = 'Swap with next parameter' })
      vim.keymap.set('n', '<leader>sf', function()
        swap.swap_next '@function.outer'
      end, { desc = 'Swap with next function' })
      vim.keymap.set('n', '<leader>sp', function()
        swap.swap_previous '@parameter.inner'
      end, { desc = 'Swap with prev parameter' })
      vim.keymap.set('n', '<leader>sF', function()
        swap.swap_previous '@function.outer'
      end, { desc = 'Swap with prev function' })

      -- Repeatable move (replaces f/F/t/T and ;/,)
      local ts_repeat_move = require 'nvim-treesitter-textobjects.repeatable_move'
      vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous)
      vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
      vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
      vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })
    end,
  },
}
