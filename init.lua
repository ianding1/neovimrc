-- Plugins.
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'sainnhe/everforest'
  use 'mbbill/undotree'
  use 'nvim-lualine/lualine.nvim'
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use 'nvim-tree/nvim-web-devicons'
  use 'm4xshen/autoclose.nvim'

  use 'tpope/vim-fugitive'
  use 'tpope/vim-vinegar'
  use 'tpope/vim-rsi'
  use 'tomtom/tcomment_vim'

  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  }
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/nvim-cmp'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'
end)

-- Use 24-bit colors in the terminal.
vim.o.termguicolors = true

-- Set color scheme.
vim.o.background = 'dark'
vim.cmd('colorscheme everforest')

-- Use spaces instead of tabs.
vim.o.expandtab = true

-- Set indentation to 2 spaces.
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

-- Show a visual line under the cursor.
vim.o.cursorline = true

-- Enable auto-completion for Vim commands.
vim.o.wildmenu = true
vim.o.wildmode = 'full'

-- Enable incremental search and highlight matches.
vim.o.incsearch = true
vim.o.hlsearch = true

-- Make backspace fully functional.
vim.o.backspace = 'indent,eol,start'

-- Disable backup and swap files.
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- Set the leader key to space.
vim.g.mapleader = ' '

-- Set the local leader key to backslash.
vim.g.maplocalleader = '\\'

-- Enable mouse in the terminal.
vim.o.mouse = 'a'

-- Show the line number.
vim.o.number = true

-- Always show 5 lines above or below the cursor.
vim.o.scrolloff = 5

-- Hide the mode prompt.
vim.o.showmode = false

-- Persist the undo records on the disk.
if vim.fn.has('persistent_undo') == 1 then
  vim.fn.system('mkdir -p $HOME/.cache/vim-undo')
  vim.o.undodir = os.getenv( "HOME" ) .. '/.cache/vim-undo'
  vim.o.undofile = true
end

-- Split the diff window vertically.
vim.o.diffopt = vim.o.diffopt .. ',vertical'

-- Don't wrap lines.
vim.o.wrap = false

-- Hide the buffer when switching out.
vim.o.hidden = true

-- Preview the substitution.
vim.o.inccommand = 'nosplit'

-- Use the system clipboard as default.
vim.o.clipboard = 'unnamed'

-- Split the window below or on the right.
vim.o.splitbelow = true
vim.o.splitright = true

-- Combine the sign column with line number.
vim.o.signcolumn = 'number'

-- Set completion options.
vim.o.completeopt = 'menu,menuone,noselect'

-- Set lualine theme.
require('lualine').setup {
  options = { theme = 'everforest' }
}

-- Set up undotree.
vim.api.nvim_create_user_command(
  'ToggleUndoTree',
  'UndotreeToggle | UndotreeFocus',
  {}
)
vim.keymap.set('n', '<leader>u', ':ToggleUndoTree<CR>',
  { silent = true, noremap = true })

-- Set up autoclose.
require('autoclose').setup({})

-- Set up telescope.
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Set up auto completion.
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping.scroll_docs(-4),
    ['<C-p>'] = cmp.mapping.scroll_docs(4),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<CR>'] = cmp.mapping.confirm { select = true },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer' },
  })
}

-- Set up treesitter.
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'lua', 'vim', 'help' },
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  highlight = {
    enable = true,
    disable = function(_, buf)
      local max_filesize = 1024 * 1024 -- 1 MB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
  }
}


-- Set up LSP package manager.
require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = { 'sumneko_lua' },
  automatic_installation = false,
}

-- Set up LSP key maps.
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Set up LSP global configurations.
local lspconfig = require('lspconfig')
local lsp_defaults = lspconfig.util.default_config

lsp_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lsp_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities())

lsp_defaults.on_attach = function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

lsp_defaults.flags = {
  debounce_text_changes = 150,
}

-- Set up Lua LSP for Neovim.
require('lspconfig').sumneko_lua.setup {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
      },
      telemetry = {
        enable = false,
      }
    }
  }
}

require('lspconfig').ocamllsp.setup {}