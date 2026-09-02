-- opencode.nvim — lazy on first <leader>o* keymap.
vim.g.opencode_opts = {
  terminal = {
    env = {
      NODE_EXTRA_CA_CERTS = '/Users/malfayez/mycerts.pem',
    },
  },
}

local function load_opencode()
  vim.pack.add {
    gh 'NickvanDyke/opencode.nvim',
    gh 'folke/snacks.nvim',
  }
  require('snacks').setup { input = { enabled = true } }
end

vim.keymap.set('n', '<leader>oA', function() load_opencode(); require('opencode').ask() end, { desc = 'Ask opencode' })
vim.keymap.set('n', '<leader>oa', function() load_opencode(); require('opencode').ask '@cursor: ' end, { desc = 'Ask opencode about this' })
vim.keymap.set('v', '<leader>oa', function() load_opencode(); require('opencode').ask '@selection: ' end, { desc = 'Ask opencode about selection' })
vim.keymap.set('n', '<leader>ot', function() load_opencode(); require('opencode').toggle() end, { desc = 'Toggle embedded opencode' })
vim.keymap.set('n', '<leader>on', function() load_opencode(); require('opencode').command 'session_new' end, { desc = 'New session' })
vim.keymap.set('n', '<leader>oy', function() load_opencode(); require('opencode').command 'messages_copy' end, { desc = 'Copy last message' })
vim.keymap.set('n', '<S-C-u>', function() load_opencode(); require('opencode').command 'messages_half_page_up' end, { desc = 'Scroll messages up' })
vim.keymap.set('n', '<S-C-d>', function() load_opencode(); require('opencode').command 'messages_half_page_down' end, { desc = 'Scroll messages down' })
vim.keymap.set({ 'n', 'v' }, '<leader>op', function() load_opencode(); require('opencode').select_prompt() end, { desc = 'Select prompt' })
vim.keymap.set('n', '<leader>oe', function() load_opencode(); require('opencode').prompt 'Explain @cursor and its context' end, { desc = 'Explain code near cursor' })
