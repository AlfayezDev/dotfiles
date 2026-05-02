--- Detect whether to use eslint+prettier or biome for a given buffer.
--- Walks up from the file's directory (stopping at git root) looking for
--- eslint or prettier config files.  If found → prettier + eslint,
--- otherwise → biome.  Skips anything inside node_modules.
---@param bufnr integer
---@return string[]
local function detect_formatter(bufnr)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == '' then
    return { 'biome' }
  end

  -- skip node_modules
  if filepath:match '/node_modules/' then
    return { 'biome' }
  end

  local configs = {
    -- eslint
    '.eslintrc',
    '.eslintrc.js',
    '.eslintrc.cjs',
    '.eslintrc.json',
    '.eslintrc.yml',
    '.eslintrc.yaml',
    'eslint.config.js',
    'eslint.config.mjs',
    'eslint.config.cjs',
    'eslint.config.ts',
    -- prettier
    '.prettierrc',
    '.prettierrc.js',
    '.prettierrc.cjs',
    '.prettierrc.json',
    '.prettierrc.yml',
    '.prettierrc.yaml',
    'prettier.config.js',
    'prettier.config.cjs',
    'prettier.config.mjs',
  }

  local dir = vim.fs.dirname(filepath)
  local git_root = vim.fs.root(filepath, { '.git' })

  local found = vim.fs.find(configs, {
    path = dir,
    upward = true,
    stop = git_root,
  })

  -- filter out matches inside node_modules (safety net)
  found = vim.tbl_filter(function(p)
    return not p:match '/node_modules/'
  end, found)

  if #found > 0 then
    return { 'prettier', 'eslint' }
  end

  return { 'biome' }
end

return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      if vim.api.nvim_buf_get_name(bufnr):match 'xmake%.lua$' then
        return nil
      end
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback'
      end
      return {
        timeout_ms = 2000,
        lsp_format = lsp_format_opt,
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      svelte = { 'prettier' },
      javascript = detect_formatter,
      typescript = detect_formatter,
      javascriptreact = detect_formatter,
      typescriptreact = detect_formatter,
      json = detect_formatter,
    },
  },
}
