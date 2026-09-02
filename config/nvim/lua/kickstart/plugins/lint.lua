-- Linting

vim.pack.add { 'https://github.com/mfussenegger/nvim-lint' }

local lint = require 'lint'
lint.linters_by_ft = {
  kotlin = { 'ktlint' },
  markdown = { 'markdownlint' }, -- Make sure to install `markdownlint` via npm
  javascript = { 'biomejs', 'eslint' },
  javascriptreact = { 'biomejs', 'eslint' },
  typescript = { 'biomejs', 'eslint' },
  typescriptreact = { 'biomejs', 'eslint' },
  json = { 'biomejs' },
  svelte = { 'eslint' },
}

-- Create autocommand which carries out the actual linting
-- on the specified events.
local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = lint_augroup,
  callback = function()
    -- Only run the linter in buffers that you can modify in order to
    -- avoid superfluous noise, notably within the handy LSP pop-ups that
    -- describe the hovered symbol using Markdown.
    if not vim.bo.modifiable then return end

    local ft = vim.bo.filetype
    if ft == 'javascript' or ft == 'javascriptreact' or ft == 'typescript' or ft == 'typescriptreact' then
      if vim.fn.executable 'biome' == 1 then
        lint.try_lint 'biomejs'
      elseif vim.fn.executable 'eslint' == 1 then
        lint.try_lint 'eslint'
      end
    elseif ft == 'svelte' then
      -- Svelte: eslint only (needs project-local eslint-plugin-svelte)
      if vim.fn.executable 'eslint' == 1 then lint.try_lint 'eslint' end
    elseif ft == 'json' then
      if vim.fn.executable 'biome' == 1 then lint.try_lint 'biomejs' end
    else
      -- Only lint if the required tool is actually installed
      local ft_linters = lint.linters_by_ft[ft]
      if ft_linters then
        for _, linter_name in ipairs(ft_linters) do
          local linter = lint.linters[linter_name]
          if linter and vim.fn.executable(linter.cmd) == 1 then
            lint.try_lint(linter_name)
          end
        end
      end
    end
  end,
})
