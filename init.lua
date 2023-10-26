-- Use 24-bit colors in the terminal.
vim.o.termguicolors = true

-- Use spaces instead of tabs.
vim.o.expandtab = true

-- Show a visual line under the cursor.
vim.o.cursorline = true

-- Disable write backup and swap files.
vim.o.writebackup = false
vim.o.swapfile = false

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

-- Use the system clipboard as default.
vim.o.clipboard = 'unnamed'

-- Split the window on below (horizontally) or right (vertically).
vim.o.splitbelow = true
vim.o.splitright = true

-- Allow returning to normal mode by just pressing <Esc> in terminal mode.
-- To send <Esc> to the terminal, press <C-v><Esc>.
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true, noremap = true })
vim.keymap.set("t", "<C-v><Esc>", "<Esc>", { silent = true, noremap = true })

-- Neovide configuration.
if vim.g.neovide then
  vim.o.guifont = "Hack Nerd Font Mono,Source Code Pro:h13"
  vim.g.neovide_cursor_animate_in_insert_mode = false
  vim.g.neovide_input_macos_alt_is_meta = true
end

-- Plugin configuration.

-- ensure_packer is a function that installs packer.nvim for you if it has not
-- been installed in your system.
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

-- Make sure packer.nvim has been installed.
local packer_bootstrap = ensure_packer()

-- Plugin list.
require('packer').startup(function(use)
  -- The package manager itself.
  use 'wbthomason/packer.nvim'
  -- The _de-facto_ standard library for Neovim. Used by many other plugins.
  use 'nvim-lua/plenary.nvim'

  -- Nightfox color scheme.
  use 'EdenEast/nightfox.nvim'

  -- Undotree UI. Visualize the undo history as a tree.
  use 'mbbill/undotree'

  -- Pretty status line written in Lua.
  use 'nvim-lualine/lualine.nvim'

  -- Show git signs.
  use 'lewis6991/gitsigns.nvim'

  -- Powerful fuzzy finder written in Lua.
  -- See https://github.com/nvim-telescope/telescope.nvim
  use 'nvim-telescope/telescope.nvim'
  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && ' ..
        'cmake --build build --config Release && ' ..
        'cmake --install build --prefix build'
  }
  use 'nvim-telescope/telescope-file-browser.nvim'

  -- VSCode-like icons for Git, file types, and etc.
  -- Patched fonts are required for these icons to be rendered correctly.
  -- I use https://www.nerdfonts.com/ but others should work too.
  use 'nvim-tree/nvim-web-devicons'

  -- Auto close parentheses, brackets and tags.
  use 'windwp/nvim-autopairs'

  -- A very powerful Git plugin for Vim.
  -- See http://vimcasts.org/categories/git/ for a series of awesome tutorials on fugitive.
  use 'tpope/vim-fugitive'

  -- Allow using readline mappings (C-d/C-e/C-f/etc) in the command line mode.
  use 'tpope/vim-rsi'

  -- Code commenting plugin.
  use 'tomtom/tcomment_vim'

  -- Below are the plugins to configure LSP and auto completion.
  --
  -- This configuration uses Neovim's native LSP API. You are encouraged to also check out
  -- coc.nvim, which was created before Neovim LSP was added, closed in the gap for Vim
  -- LSP support, and has maintained an active community till today.
  --
  -- I don't use snippets personally but Neovim LSP requires a snippet engine.
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/nvim-cmp'
  use 'saadparwaiz1/cmp_luasnip'
  use 'onsails/lspkind.nvim'
  use 'L3MON4D3/LuaSnip'

  -- Syntax highlighting based off of treesitter, a generic parser generator tool that supports a variety
  -- of programming languages.
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local installer = require('nvim-treesitter.install')
      local ts_update = installer.update { with_sync = true }
      ts_update()
    end,
  }

  -- Run :PackerSync if it is the first time.
  -- You still need to run :PackerSync from time to time to keep all the plugins
  -- up to date.
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Stop here if it is the first time.
if packer_bootstrap then
  print('Please restart Neovim to load the plugins just installed.')
  return
end

-- Set color scheme to carbonfox, a variant of nightfox.
vim.o.background = 'dark'
vim.cmd('colorscheme carbonfox')

-- Set up lualine theme.
local lualine = require('lualine')
lualine.setup {
  options = { theme = 'auto' }
}

-- Set up gitsigns.
local gitsigns = require('gitsigns')
gitsigns.setup {}

-- Set up undotree.
vim.keymap.set('n', '<space>u', ':UndotreeToggle<CR>', { noremap = true })

-- Set up autopairs.
local autopairs = require('nvim-autopairs')
autopairs.setup {}

-- Disable closing single quotes on ocaml files.
autopairs.get_rule("'")[1].not_filetypes = { 'ocaml' }

-- Set up telescope.
local telescope = require('telescope')
local fb_actions = telescope.extensions.file_browser.actions

telescope.setup {
  defaults = {
    path_display = { 'shorten' },
  },
  extensions = {
    file_browser = {
      mappings = {
        ["n"] = {
          -- map `-` to go to parent dir for consistency.
          ["-"] = fb_actions.backspace,
        }
      },
    },
  },
}

telescope.load_extension('fzf')
telescope.load_extension('file_browser')

-- Set up key mappings for telescope.
local builtin = require('telescope.builtin')
-- Bind <space>f to Telescope builtins.
-- Note: <space> is bound to <space> at the beginning of this configuraiton.
vim.keymap.set('n', '<space>f', builtin.find_files)
vim.keymap.set('n', '<space>r', builtin.oldfiles)  -- r for recent
vim.keymap.set('n', '<space>g', builtin.live_grep)
vim.keymap.set('n', '<space>b', builtin.buffers)
vim.keymap.set('n', '<space>h', builtin.help_tags)

vim.keymap.set(
  'n',
  '<space>cd',  -- cd for "current directory"
  ':Telescope file_browser<CR>',
  { noremap = true }
)

vim.keymap.set(
  'n',
  '-',  -- - is bound to "go to parent directory" in vinegar.vim
  ':Telescope file_browser path=%:p:h select_buffer=true<CR>',
  { noremap = true }
)

-- Bind LSP actions to Telescope.
vim.keymap.set('n', 'gD', builtin.lsp_type_definitions)
vim.keymap.set('n', 'gd', builtin.lsp_definitions)
vim.keymap.set('n', 'gi', builtin.lsp_implementations)
vim.keymap.set('n', 'gr', builtin.lsp_references)
-- Show diagnostics for the current buffer.
vim.keymap.set('n', '<space>d', function()  -- d for diagnostics
  builtin.diagnostics { bufnr = 0 }
end)

-- Show diagnostics for all open buffers.
vim.keymap.set('n', '<space>D', builtin.diagnostics)

-- Set up auto completion.
local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')
local devicons = require('nvim-web-devicons')
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  -- Set up key mappings for the completion popup window.
  mapping = cmp.mapping.preset.insert({
    -- Bind <C-f> to scrolling the documentation window down.
    ['<C-f>'] = cmp.mapping.scroll_docs(-4),
    -- Bind <C-b> to scrolling the documentation window up.
    ['<C-b>'] = cmp.mapping.scroll_docs(4),
    -- Bind <CR> to confirming completion.
    ['<CR>'] = cmp.mapping.confirm { select = true },
    -- Bind <Tab> to selecting the next candidate.
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    -- Bind <Super-Tab> to selecting the previous candidate.
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
    -- Add icons to the completion popup window.
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
  })
}

-- Set up treesitter.
local treesitter = require('nvim-treesitter.configs')
treesitter.setup {
  ensure_installed = { 'c', 'lua', 'vim', 'vimdoc' },
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  modules = {},
  highlight = {
    enable = true,
    disable = function(_, buf)
      -- Disable treesitter when the file size is larger than 1 MB.
      local max_filesize = 1024 * 1024
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    -- Disable Vim's regex-based syntax highlighting when treesitter is enabled.
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
}

-- Set up folding with treesitter.
-- See :h folding for how to use Vim folding.
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldenable = false

-- Set up LSP.
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')
local lspconfig = require('lspconfig')
mason.setup()
mason_lspconfig.setup {
  ensure_installed = { 'lua_ls' },
  automatic_installation = false,
}

-- Make the original `,` accessible via `,,`.
-- Original `,`: repeat the last `ftFT` in the opposite direction.
-- It is used much less frequently than `;` personally so I repurposed it as
-- the prefix key for LSP commands.
vim.keymap.set({ 'n', 'v' }, ',,', ',', { noremap = true })

-- Bind <space>e to showing error under the cursor.
-- e for error.
vim.keymap.set('n', ',e', vim.diagnostic.open_float)
-- Bind [e to jumping to the previous error.
vim.keymap.set('n', '[e', vim.diagnostic.goto_prev)
-- Bind ]e to jumping to the next error.
vim.keymap.set('n', ']e', vim.diagnostic.goto_next)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(event)
    local bufopts = { buffer = event.buf }
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', ';rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set({ 'n', 'v' }, ';a', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', ',f', function()
      vim.lsp.buf.format { async = true }
    end, bufopts)
  end
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Automatically set up LSP servers installed via mason.
mason_lspconfig.setup_handlers {
  -- Default set up handler.
  function(server_name)
    lspconfig[server_name].setup {
      capabilities = capabilities,
    }
  end,
  lua_ls = function()
    lspconfig.lua_ls.setup {
      capabilities = capabilities,
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
  end
}

