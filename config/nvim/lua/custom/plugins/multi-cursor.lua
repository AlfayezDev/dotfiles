-- vim-visual-multi — load eagerly (needs VM_maps init before buffers open).
vim.pack.add { gh 'mg979/vim-visual-multi' }

vim.g.VM_maps = { ['Find Under'] = '<C-n>' }

-- VM <-> blink.cmp compatibility shim.
-- On VM exit, VM unmaps buffer-local insert keys (<CR>, <BS>, ...) it had
-- overwritten, which removes blink's maps too. Reset blink's insert maps so
-- its InsertEnter autocmd re-applies them fresh.
local group = vim.api.nvim_create_augroup('vm_blink_compat', { clear = true })

local DESC_PREFIX = 'blink.cmp: '
local BLINK_INSERT_KEYS = {
  '<CR>', '<C-Space>', '<C-e>',
  '<Tab>', '<S-Tab>',
  '<Up>', '<Down>', '<C-p>', '<C-n>',
  '<C-b>', '<C-f>', '<C-k>',
}

local function reset_blink_insert_keymaps()
  for _, key in ipairs(BLINK_INSERT_KEYS) do
    local info = vim.fn.maparg(key, 'i', false, true)
    if info and info.buffer == 1 and info.desc and vim.startswith(info.desc, DESC_PREFIX) then
      pcall(vim.keymap.del, 'i', key, { buffer = true })
    end
  end
end

local function blink_is_stale()
  local cr_info = vim.fn.maparg('<CR>', 'i', false, true)
  local cr_is_blink = cr_info and cr_info.buffer == 1
    and cr_info.desc and vim.startswith(cr_info.desc, DESC_PREFIX)
  if cr_is_blink then return false end
  for _, key in ipairs { '<C-Space>', '<C-e>', '<C-k>', '<Tab>' } do
    local info = vim.fn.maparg(key, 'i', false, true)
    if info and info.buffer == 1 and info.desc and vim.startswith(info.desc, DESC_PREFIX) then
      return true
    end
  end
  return false
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'visual_multi_exit',
  group = group,
  callback = reset_blink_insert_keymaps,
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = group,
  callback = function()
    if vim.b.visual_multi then return end
    if blink_is_stale() then reset_blink_insert_keymaps() end
  end,
})
