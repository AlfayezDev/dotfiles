-- Migrated from kickstart.nvim (commit f0a2108, 2026-06-11) to vim.pack.
-- Customizations preserved: NODE_EXTRA_CA_CERTS, guifont, termbidi, gruvbox,
-- tab=2, relativenumber, <leader>qq/<leader>dd, no mason.

-- ============================================================
-- SECTION 1: OPTIONS
-- Core Neovim settings, leaders, options, basic keymaps, basic autocmds
-- ============================================================
do
  -- Enable faster startup by caching compiled Lua modules
  vim.loader.enable()

  -- Local buffer conceal (for markdown, etc.)
  vim.opt_local.conceallevel = 1
  -- RTL/bi-di text rendering
  vim.o.termbidi = true
  -- Corporate cert for node-based LSPs/tools
  vim.env.NODE_EXTRA_CA_CERTS = '/Users/malfayez/mycerts.pem'

  -- Set <space> as the leader key
  -- See `:help mapleader`
  --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  vim.o.guifont = 'MonoLisaCode:h18,Symbols_Nerd_Font_Mono:h18'
  -- Set to true if you have a Nerd Font installed and selected in the terminal
  vim.g.have_nerd_font = true

  -- [[ Setting options ]]
  --  See `:help vim.o`

  -- Make line numbers default
  vim.o.number = true
  vim.o.relativenumber = true

  -- Enable mouse mode, can be useful for resizing splits for example!
  vim.o.mouse = 'a'

  -- Don't show the mode, since it's already in the status line
  vim.o.showmode = false

  -- Sync clipboard between OS and Neovim.
  --  Schedule the setting after `UiEnter` because it can increase startup-time.
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

  -- Enable break indent
  vim.o.breakindent = true

  -- Enable undo/redo changes even after closing and reopening a file
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Keep signcolumn on by default
  vim.o.signcolumn = 'yes'

  -- Decrease update time
  vim.o.updatetime = 250

  -- Decrease mapped sequence wait time
  vim.o.timeoutlen = 300

  -- Configure how new splits should be opened
  vim.o.splitright = true
  vim.o.splitbelow = true

  -- Sets how neovim will display certain whitespace characters in the editor.
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

  -- Tab / indent width
  vim.o.tabstop = 2
  vim.o.shiftwidth = 2
  vim.o.softtabstop = 2

  -- Preview substitutions live, as you type!
  vim.o.inccommand = 'split'

  -- Show which line your cursor is on
  vim.o.cursorline = true

  -- Minimal number of screen lines to keep above and below the cursor.
  vim.o.scrolloff = 10

  -- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
  -- instead raise a dialog asking if you wish to save the current file(s)
  vim.o.confirm = true
end

-- ============================================================
-- SECTION 2: KEYMAPS
-- basic keymaps
-- ============================================================
do
  -- Clear highlights on search when pressing <Esc> in normal mode
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  -- Quit all (custom)
  vim.keymap.set('n', '<leader>qq', '<cmd>qa<CR>', { desc = 'Quit' })

  -- Diagnostic Config & Keymaps
  --  See `:help vim.diagnostic.Opts`
  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },
    virtual_text = true,
    virtual_lines = false,
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }

  -- Custom: <leader>dd (instead of upstream <leader>q which we use for Quit)
  vim.keymap.set('n', '<leader>dd', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
  -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
  -- is not what someone will guess without a bit more experience.
  --
  -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
  -- or just use <C-\><C-n> to exit terminal mode
  -- (disabled: kept commented to match prior config)
  -- vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- TIP: Disable arrow keys in normal mode
  vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
  vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
  vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
  vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

  -- Keybinds to make split navigation easier.
  --  Use CTRL+<hjkl> to switch between windows
  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

  -- Highlight when yanking (copying) text
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })
end

-- ============================================================
-- SECTION 3: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks
-- ============================================================
do
  -- `gh` shorthand for github source URLs.
  local function gh(repo) return 'https://github.com/' .. repo end
  _G.gh = gh

  -- Build hook runner: invoked from the PackChanged autocmd below for plugins
  -- that need a post-install/update build step.
  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end

      if name == 'markdown-preview.nvim' then
        run_build(name, { 'yarn', 'install' }, ev.data.path .. '/app')
        return
      end
    end,
  })
end

-- ============================================================
-- SECTION 4: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules
-- ============================================================
do
  vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
  require('guess-indent').setup {}

  vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
  require('gitsigns').setup {
    signs = {
      add = { text = '+' }, ---@diagnostic disable-line: missing-fields
      change = { text = '~' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
    },
  }

  vim.pack.add { gh 'folke/which-key.nvim' }
  require('which-key').setup {
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },
    spec = {
      { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
      { '<leader>g', group = '[g]f debug' },
      { '<leader>o', group = '[o]pencode' },
      { '<leader>x', group = 'Swap/Tree-sitter' },
      { '<leader>z', group = 'Folds' },
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
    },
  }

  -- [[ Colorscheme: gruvbox (was tokyonight upstream) ]]
  vim.pack.add { gh 'ellisonleao/gruvbox.nvim' }
  require('gruvbox').setup {
    contrast = 'hard',
    transparent_mode = true,
    dim_inactive = false,
  }
  vim.cmd.colorscheme 'gruvbox'
  vim.cmd.hi 'Comment gui=none'

  -- Highlight todo, notes, etc in comments
  vim.pack.add { gh 'folke/todo-comments.nvim', gh 'nvim-lua/plenary.nvim' }
  require('todo-comments').setup { signs = false }

  -- mini.nvim
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  if vim.g.have_nerd_font then
    require('mini.icons').setup()
    MiniIcons.mock_nvim_web_devicons()
  end

  require('mini.ai').setup {
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
  }

  require('mini.surround').setup()

  local statusline = require 'mini.statusline'
  statusline.setup { use_icons = vim.g.have_nerd_font }
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function() return '%2l:%-2v' end

  -- Comment.nvim (preserved from prior config)
  vim.pack.add { gh 'numToStr/Comment.nvim' }
  require('Comment').setup {}
end

-- ============================================================
-- SECTION 5: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ============================================================
do
  ---@type (string|vim.pack.Spec)[]
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-ui-select.nvim',
  }
  if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

  vim.pack.add(telescope_plugins)

  require('telescope').setup {
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
      ['lazygit'] = {},
    },
  }

  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

  -- Telescope-based LSP pickers (attached per-buffer)
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf
      vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
      vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
      vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
      vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
      vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
      vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })

  vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end, { desc = '[S]earch [/] in Open Files' })

  vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '[S]earch [N]eovim files' })
end

-- ============================================================
-- SECTION 6: LSP
-- vim.lsp.config + vim.lsp.enable (no mason)
-- ============================================================
do
  -- Useful status updates for LSP.
  vim.pack.add { gh 'j-hui/fidget.nvim' }
  require('fidget').setup {}

  -- Blink.cmp LSP capabilities (blink is loaded in SECTION 8; safe to call here
  -- because blink's lua module exists as soon as its plugin is added, but we add
  -- blink before invoking any LSP later via lazy attach). We resolve capabilities
  -- at server config time below to avoid an ordering dependency.

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Custom: smart goto definition (telescope if multiple clients, else direct)
      local function smart_goto_definition()
        local clients = vim.lsp.get_clients { bufnr = 0 }
        if #clients > 1 then
          require('telescope.builtin').lsp_definitions()
        else
          vim.lsp.buf.definition()
        end
      end

      -- Upstream-style keymaps
      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- Custom: keep direct gd/K/gI for muscle memory + smart goto
      map('gd', smart_goto_definition, '[G]oto [D]efinition')
      map('K', vim.lsp.buf.hover, 'Hover Documentation')
      map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
      map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
      map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
      map('<leader>cr', vim.lsp.buf.rename, '[C]ode [R]ename')
      map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

      -- Custom: toggle LSP attach/detach for current buffer
      map('<leader>tl', function()
        local clients = vim.lsp.get_clients { bufnr = 0 }
        if #clients == 0 then
          vim.lsp.start(vim.lsp.config[vim.bo.filetype] or {})
          vim.notify('LSP re-attached', vim.log.levels.INFO)
        else
          for _, c in ipairs(clients) do
            vim.lsp.buf_detach_client(0, c.id)
          end
          vim.notify('LSP detached', vim.log.levels.INFO)
        end
      end, '[T]oggle [L]SP')

      -- Document highlight on cursor hold
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })
        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- Inlay hints toggle
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  -- LSP servers. Tools must be installed manually (no mason):
  --   clangd, zls, lua-language-server, ols, vscode-json-languageserver,
  --   svelte-language-server, typescript-language-server (ts_ls),
  --   stylua, biome, prettier, eslint, markdownlint
  -- NOTE: root_dir uses the new `function(bufnr, on_dir)` signature on
  -- Neovim 0.12+. Don't override unless necessary — lspconfig defaults work.
  ---@type table<string, vim.lsp.Config>
  local servers = {
    clangd = {
      enabled = false, -- off: valiant project parses via unity; re-enable when needed
      cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--header-insertion=iwyu',
        '--completion-style=detailed',
        '--function-arg-placeholders',
        '--fallback-style=llvm',
      },
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
      },
      -- lspconfig's clangd default already lists compile_commands.json/.git.
      -- Add xmake.lua so xmake C/C++ projects resolve root correctly.
      root_markers = { 'xmake.lua', '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', '.git' },
    },
    zls = {},
    ts_ls = (function()
      -- typescript-language-server auto-discovery misses the mise-isolated
      -- typescript install: its bundled-mode require.resolve walks its own
      -- node_modules chain, not the active node global root, so it errors with
      -- "Could not find a valid TypeScript installation". Resolve tsserver.js
      -- explicitly from `tsc` on PATH (mise npm-backend shim exposes it).
      local tsc = vim.fn.exepath 'tsc'
      local tsserver = tsc ~= '' and vim.fs.joinpath(
        vim.fs.dirname(vim.fs.dirname(tsc)),
        'lib',
        'node_modules',
        'typescript',
        'lib',
        'tsserver.js'
      ) or nil
      if tsserver and vim.uv.fs_stat(tsserver) then
        return { init_options = { tsserver = { path = tsserver } } }
      end
      return {}
    end)(),
    -- Odin: ols binary on PATH. lspconfig default resolves root via
    -- ols.json / .git / *.odin — no override needed.
    ols = {},
    -- Svelte: svelte-language-server binary on PATH. lspconfig default
    -- resolves root via package-lock.json / yarn.lock / pnpm-lock.yaml / .git.
    -- Formatting owned by conform (prettier + project-local prettier-plugin-svelte).
    svelte = { init_options = { provideFormatter = false } },
    kotlin_language_server = {},
    -- JSON: vscode-json-languageserver binary on PATH
    -- (npm i -g vscode-langservers-extracted). lspconfig default root = .git.
    jsonls = {
      init_options = { provideFormatter = false }, -- conform/biome handle formatting
      settings = {
        json = {
          schemas = {},
          validate = { enable = true },
        },
      },
    },
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end
        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
              '${3rd}/luv/library',
              '${3rd}/busted/library',
            }),
          },
        })
      end,
      settings = {
        Lua = {
          completion = { callSnippet = 'Replace' },
          diagnostics = { disable = { 'missing-fields' } },
          format = { enable = false },
        },
      },
    },
  }

  -- lspconfig provides default configs the new API picks up. We still add it so
  -- `vim.lsp.config[name]` resolves bundled server definitions, then layer our own.
  vim.pack.add { gh 'neovim/nvim-lspconfig' }

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- pcall: blink.cmp is added in SECTION 8 but may not be loaded yet at first
  -- server start; the helper degrades gracefully if blink is absent.
  local ok, blink = pcall(require, 'blink.cmp')
  if ok and blink.get_lsp_capabilities then
    capabilities = vim.tbl_deep_extend('force', capabilities, blink.get_lsp_capabilities())
  end

  for name, server in pairs(servers) do
    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- ============================================================
-- SECTION 7: FORMATTING
-- conform.nvim setup and keymap (with detect_formatter preserved)
-- ============================================================
do
  --- Detect whether to use eslint+prettier or biome for a given buffer.
  --- Walks up from the file's directory (stopping at git root) looking for
  --- eslint or prettier config files.  If found -> prettier + eslint,
  --- otherwise -> biome.  Skips anything inside node_modules.
  ---@param bufnr integer
  ---@return string[]
  local function detect_formatter(bufnr)
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    if filepath == '' then return { 'biome' } end
    if filepath:match '/node_modules/' then return { 'biome' } end

    local configs = {
      '.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.json', '.eslintrc.yml', '.eslintrc.yaml',
      'eslint.config.js', 'eslint.config.mjs', 'eslint.config.cjs', 'eslint.config.ts',
      '.prettierrc', '.prettierrc.js', '.prettierrc.cjs', '.prettierrc.json', '.prettierrc.yml', '.prettierrc.yaml',
      'prettier.config.js', 'prettier.config.cjs', 'prettier.config.mjs',
    }

    local dir = vim.fs.dirname(filepath)
    local git_root = vim.fs.root(filepath, { '.git' })
    local found = vim.fs.find(configs, { path = dir, upward = true, stop = git_root })
    found = vim.tbl_filter(function(p) return not p:match '/node_modules/' end, found)

    if #found > 0 then return { 'prettier', 'eslint' } end
    return { 'biome' }
  end

  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      if vim.api.nvim_buf_get_name(bufnr):match 'xmake%.lua$' then return nil end
      local disable_filetypes = { c = true, cpp = true }
      local lsp_format_opt = disable_filetypes[vim.bo[bufnr].filetype] and 'never' or 'fallback'
      return {
        timeout_ms = 2000,
        lsp_format = lsp_format_opt,
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      -- kotlin: handled by kotlin_language_server (LSP formatting)
      -- to avoid ~530ms+ ktlint JVM spawn on every save.
      -- ktlint kept as linter via nvim-lint.
      -- Svelte: prettier (needs project-local prettier-plugin-svelte).
      -- Biome never used for .svelte — experimental support only.
      svelte = { 'prettier' },
      javascript = detect_formatter,
      typescript = detect_formatter,
      javascriptreact = detect_formatter,
      typescriptreact = detect_formatter,
      json = detect_formatter,
      jsonc = detect_formatter,
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
    require('conform').format { async = true, lsp_format = 'fallback' }
  end, { desc = '[F]ormat buffer' })
end

-- ============================================================
-- SECTION 8: AUTOCOMPLETE & SNIPPETS
-- blink.cmp + luasnip (with <A-CR> confirm + VM-disable preserved)
-- ============================================================
do
  vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
  require('luasnip').setup {}

  vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
  require('blink.cmp').setup {
    -- Disable completion during vim-visual-multi to prevent CompleteDone conflict.
    enabled = function() return not vim.b.visual_multi end,

    keymap = {
      -- 'default' preset: <C-y> accept, <C-space> show, <Tab>/<S-Tab> snippet nav,
      -- <C-n>/<C-p> cycle, <C-e> cancel. <CR>: accept selection when menu open,
      -- else newline (fallback). <A-CR> global confirm kept as alias below.
      -- Buffer-local <CR> is covered by the VM-exit shim in multi-cursor.lua
      -- (BLINK_INSERT_KEYS already lists '<CR>').
      preset = 'default',
      ['<CR>'] = { 'select_and_accept', 'fallback' },
    },

    appearance = { nerd_font_variant = 'mono' },

    completion = {
      list = {
        selection = {
          preselect = true,
          auto_insert = false,
        },
      },
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },

    snippets = { preset = 'luasnip' },

    fuzzy = { implementation = 'lua' },

    signature = { enabled = true },
  }

  -- <A-CR>: confirm completion (or insert newline if no menu).
  -- Global (not buffer-local) to survive blink's idempotency skip-check.
  vim.keymap.set('i', '<A-CR>', function()
    if require('blink.cmp').is_visible() then
      require('blink.cmp').select_and_accept()
    else
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes('<CR>', true, false, true),
        'n',
        false
      )
    end
  end, { desc = 'blink.cmp: Confirm completion' })
end

-- ============================================================
-- SECTION 9: TREESITTER
-- Delegated to lua/custom/plugins/treesitter.lua (large config kept modular).
-- ============================================================
require('custom.plugins.treesitter')

-- ============================================================
-- SECTION 10: OPTIONAL EXAMPLES / NEXT STEPS
-- kickstart.plugins.* examples + custom plugins
-- ============================================================
do
  -- kickstart plugin examples (vim.pack versions)
  require 'kickstart.plugins.indent_line'
  require 'kickstart.plugins.lint'
  require 'kickstart.plugins.autopairs'
  require 'kickstart.plugins.gitsigns' -- adds gitsigns recommended keymaps

  -- Load remaining custom plugins (each file calls vim.pack.add directly)
  local custom_dir = vim.fn.stdpath 'config' .. '/lua/custom/plugins'
  for _, f in ipairs(vim.fn.glob(custom_dir .. '/*.lua', false, true)) do
    -- skip treesitter (loaded above)
    local name = vim.fn.fnamemodify(f, ':t:r')
    if name ~= 'treesitter' then dofile(f) end
  end
end

-- vim: ts=2 sts=2 sw=2 et
