-- Use 24-bit colors in the terminal.
vim.o.termguicolors = true

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
  vim.o.undodir = os.getenv("HOME") .. '/.cache/vim-undo'
  vim.o.undofile = true
end

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

-- Remap <Esc> to <C-\><C-n> and <C-v><Esc> to <Esc>
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true, noremap = true })
vim.keymap.set("t", "<C-v><Esc>", "<Esc>", { silent = true, noremap = true })

-- Plugins.
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'

  use 'EdenEast/nightfox.nvim'
  use 'mbbill/undotree'
  use 'nvim-lualine/lualine.nvim'
  use 'nvim-telescope/telescope.nvim'
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use 'nvim-tree/nvim-web-devicons'
  use 'windwp/nvim-autopairs'
  use 'skywind3000/asyncrun.vim'

  use 'tpope/vim-fugitive'
  use 'tpope/vim-vinegar'
  use 'tpope/vim-rsi'
  use 'tomtom/tcomment_vim'

  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'
  use 'jose-elias-alvarez/null-ls.nvim'
  use { 'nvim-treesitter/nvim-treesitter',
    run = function()
      local installer = require('nvim-treesitter.install')
      local ts_update = installer.update { with_sync = true }
      ts_update()
    end,
  }

  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/nvim-cmp'
  use 'saadparwaiz1/cmp_luasnip'
  use 'onsails/lspkind.nvim'
  use 'L3MON4D3/LuaSnip'

  if packer_bootstrap then
    require('packer').sync()
  end
end)

if packer_bootstrap then
  return
end

local try_require = function(names, fn)
  if type(names) == 'table' then
    local all_ok = true
    local modules = {}

    for i, name in pairs(names) do
      local status_ok, module = pcall(require, name)
      if status_ok then
        modules[i] = module
      else
        all_ok = false
      end
    end

    if all_ok then
      fn(unpack(modules))
    end
  else
    local status_ok, module = pcall(require, names)
    if status_ok then
      fn(module)
    end
  end
end

local try_cmd = function(cmd, fn)
  local status_ok, _ = pcall(vim.cmd, cmd)
  if status_ok and type(fn) == 'function' then
    fn()
  end
end

-- Set color scheme.
vim.o.background = 'dark'
try_cmd('colorscheme carbonfox')

-- Set lualine theme.
try_require('lualine', function(lualine)
  lualine.setup {
    options = { theme = 'auto' }
  }
end)

-- Set up undotree.
vim.keymap.set('n', '<leader>u', ':UndotreeToggle<CR>',
  { silent = true, noremap = true })

-- Set up autopairs.
try_require('nvim-autopairs', function(autopairs)
  autopairs.setup {}

  -- Disable closing single quotes on file type ocaml.
  autopairs.get_rule("'")[1].not_filetypes = { 'ocaml' }
end)

-- Set up telescope.
try_require('telescope', function(telescope)
  telescope.setup {
    defaults = {
      path_display = { 'truncate' },
    }
  }

  telescope.load_extension('fzf')
end)

try_require('telescope.builtin', function(builtin)
  vim.keymap.set('n', '<leader>f', builtin.find_files, {})
  vim.keymap.set('n', '<leader>/', builtin.live_grep, {})
  vim.keymap.set('n', '<leader>b', builtin.buffers, {})
  vim.keymap.set('n', '<leader>:', builtin.commands, {})
end)

-- Set up auto completion.
try_require({ 'cmp', 'luasnip', 'lspkind', 'nvim-web-devicons' },
  function(cmp, luasnip, lspkind, devicons)
    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-f>'] = cmp.mapping.scroll_docs(-4),
        ['<C-b>'] = cmp.mapping.scroll_docs(4),
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
      formatting = {
        format = function(entry, vim_item)
          if vim.tbl_contains({ 'path' }, entry.source.name) then
            local icon, hl_group = devicons.get_icon(entry:get_completion_item().label)
            if icon then
              vim_item.kind = icon
              vim_item.kind_hl_group = hl_group
              return vim_item
            end
          end
          return lspkind.cmp_format({ with_text = false })(entry, vim_item)
        end
      },
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'buffer' },
      })
    }
  end)

-- Set up treesitter.
try_require('nvim-treesitter.configs', function(treesitter)
  treesitter.setup {
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
    },
    indent = {
      enable = true,
    },
  }

  -- Set up folding.
  vim.o.foldmethod = 'expr'
  vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
  vim.o.foldenable = false
end)

-- Set up LSP.
try_require({ 'mason', 'mason-lspconfig', 'lspconfig' }, function(mason, mason_lspconfig, lspconfig)
  mason.setup()
  mason_lspconfig.setup {
    ensure_installed = { 'lua_ls' },
    automatic_installation = false,
  }

  local opts = { noremap = true, silent = true }
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[e', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']e', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  local on_attach = function(_, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<leader>k', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<leader>=', function()
      vim.lsp.buf.format { async = true }
    end, bufopts)
  end

  local flags = {
    debounce_text_changes = 150,
  }

  -- Set up Lua LSP for Neovim.
  lspconfig.lua_ls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = flags,
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

  lspconfig.tsserver.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = flags,
  }

  lspconfig.ocamllsp.setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = flags,
  }
end)

-- Set up null-ls.
try_require('null-ls', function(null_ls)
  null_ls.setup {
    sources = {
      null_ls.builtins.formatting.prettier,
    }
  }
end)
