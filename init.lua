-- Use 24-bit colors in the terminal.
vim.o.termguicolors = true

-- Use spaces instead of tabs.
vim.o.expandtab = true

-- Use 2 spaces by default.
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

-- Show a visual line under the cursor.
vim.o.cursorline = true

-- Ignore case by default.
vim.o.ignorecase = true

-- Disable write backup and swap files.
vim.o.writebackup = false
vim.o.swapfile = false

-- Enable mouse in the terminal.
vim.o.mouse = "a"

-- Always show 5 lines above or below the cursor.
vim.o.scrolloff = 3

-- Show line numbers.
vim.o.number = true

-- Show sign column.
vim.o.signcolumn = "yes"

-- Hide intro at Vim startup.
vim.o.shortmess = vim.o.shortmess .. "I"

-- Split below and right.
vim.o.splitbelow = true
vim.o.splitright = true

-- Set the fill char for diff to blank.
vim.o.fillchars = "diff: "

-- Persist the undo records on the disk.
if vim.fn.has("persistent_undo") == 1 then
  vim.fn.system("mkdir -p $HOME/.cache/vim-undo")
  vim.o.undodir = os.getenv("HOME") .. "/.cache/vim-undo"
  vim.o.undofile = true
end

-- Don't wrap lines.
vim.o.wrap = false

-- Use system clipboard.
vim.o.clipboard = "unnamedplus"

-- Enable linematch in diff mode (added in Neovim 0.9)
vim.opt.diffopt = vim.opt.diffopt + "linematch:60"

-- Allow returning to normal mode by just pressing <Esc> in terminal mode.
-- To send <Esc> to the terminal, press <C-v><Esc>.
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true, noremap = true })
vim.keymap.set("t", "<C-v><Esc>", "<Esc>", { silent = true, noremap = true })

-- Set up diagnostic sign icons.
vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵 ", texthl = "DiagnosticSignHint" })

-- Plugin configuration.

-- ensure_packer is a function that installs packer.nvim for you if it has not
-- been installed in your system.
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

-- Make sure packer.nvim has been installed.
local packer_bootstrap = ensure_packer()

local keymap_opts = {
  noremap = true,
  silent = true,
}

-- Plugin list.
require("packer").startup(function(use)
  -- The package manager itself.
  use("wbthomason/packer.nvim")
  -- The _de-facto_ standard library for Neovim. Used by many other plugins.
  use("nvim-lua/plenary.nvim")

  -- Color scheme.
  use({
    "rebelot/kanagawa.nvim",
    config = function()
      vim.cmd("colorscheme kanagawa")
    end,
  })

  -- Undotree UI. Visualize the undo history as a tree.
  use({
    "mbbill/undotree",
    config = function()
      vim.keymap.set("n", "<space>u", "<Cmd>UndotreeToggle<CR>", keymap_opts)
    end,
  })

  -- File manager.
  use({
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup()
      vim.keymap.set("n", "<space>j", "<Cmd>Neotree toggle filesystem<CR>", keymap_opts)
    end,
  })

  -- Quick navigation between commonly accessed files.
  use({
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    requires = { { "nvim-lua/plenary.nvim" } },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      vim.keymap.set("n", "<space>'", function()
        harpoon:list():add()
      end)
      vim.keymap.set("n", "<space>;", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      for i = 1, 5 do
        vim.keymap.set("n", "<space>" .. i, function()
          harpoon:list():select(i)
        end)
      end
    end,
  })

  -- Powerful fuzzy finder.
  use({
    "ibhagwan/fzf-lua",
    requires = { { "junegunn/fzf", run = "./install --bin" } },
    config = function()
      local fzf = require("fzf-lua")
      fzf.setup({
        winopts = {
          preview = {
            layout = "vertical",
          },
        },
        files = { cwd_prompt = false },
      })

      -- File/buffer/glob fuzzy search.
      -- Uses home row keys s/d/f.
      vim.keymap.set("n", "<space>f", fzf.files)
      vim.keymap.set("n", "<space>d", fzf.buffers)
      vim.keymap.set("n", "<space>s", fzf.live_grep_glob)
      vim.keymap.set("n", "<space>k", fzf.lsp_document_symbols)

      -- Bind LSP actions to FZF.
      vim.keymap.set("n", "gD", fzf.lsp_typedefs)
      vim.keymap.set("n", "gd", fzf.lsp_definitions)
      vim.keymap.set("n", "gi", fzf.lsp_implementations)
      vim.keymap.set("n", "gr", fzf.lsp_references)
      vim.keymap.set("n", "gf", fzf.lsp_code_actions)
      vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help)
      vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
      vim.keymap.set("n", "<space>r", vim.lsp.buf.rename)
    end,
  })

  -- VSCode-like icons for Git, file types, and etc.
  -- Patched fonts are required for these icons to be rendered correctly.
  -- I use https://www.nerdfonts.com/ but others should work too.
  use("nvim-tree/nvim-web-devicons")

  -- Auto close parentheses, brackets and tags.
  use({
    "windwp/nvim-autopairs",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({})

      -- Disable closing single quotes on ocaml files.
      autopairs.get_rule("'")[1].not_filetypes = { "ocaml" }
    end,
  })

  -- Allow using readline mappings (C-d/C-e/C-f/etc) in the command line mode.
  use("tpope/vim-rsi")

  -- LSP.
  use("hrsh7th/cmp-nvim-lsp")
  use({
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-c>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          -- Bind <Tab> to selecting the next candidate.
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          -- Bind <Super-Tab> to selecting the previous candidate.
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }),
      })
    end,
  })
  use("saadparwaiz1/cmp_luasnip")
  use("onsails/lspkind.nvim")
  use("L3MON4D3/LuaSnip")

  use("williamboman/mason.nvim")
  use("williamboman/mason-lspconfig.nvim")
  use({
    "neovim/nvim-lspconfig",
    config = function()
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local lspconfig = require("lspconfig")
      mason.setup()
      mason_lspconfig.setup({
        ensure_installed = { "lua_ls" },
        automatic_installation = false,
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      -- Automatically set up LSP servers installed via mason.
      mason_lspconfig.setup_handlers({
        -- Default set up handler.
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
          })
        end,
        lua_ls = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  globals = { "vim" },
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                },
                telemetry = {
                  enable = false,
                },
              },
            },
          })
        end,
        -- Disable Mason lsp config for rust analyzer.
        rust_analyzer = function() end,
      })
    end,
  })

  -- Rust LSP enhancement.
  use("mrcjkb/rustaceanvim")

  -- Syntax highlighting based off of treesitter, a generic parser generator tool that supports a variety
  -- of programming languages.
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local installer = require("nvim-treesitter.install")
      local ts_update = installer.update({ with_sync = true })
      ts_update()
    end,
    config = function()
      local treesitter = require("nvim-treesitter.configs")
      treesitter.setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "markdown", "markdown_inline" },
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        modules = {},
        highlight = {
          enable = true,
          disable = function(_, buf)
            -- Disable treesitter when the file size is larger than 1 MB.
            local max_filesize = 1024 * 1024
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
          -- Disable Vim's regex-based syntax highlighting when treesitter is enabled.
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  })

  -- Formatter.
  use({
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          rust = { "rustfmt", lsp_format = "fallback" },
          typescript = { "prettierd", "prettier", stop_after_first = true },
        },
      })

      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  })

  -- Git diff tool.
  use({
    "sindrets/diffview.nvim",
    config = function()
      vim.keymap.set("n", "<space>g", "<Cmd>DiffviewOpen<CR>", keymap_opts)
    end,
  })

  -- Git signs on the sign column.
  use({
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  })

  -- Show terminal ASCII colors.
  use({
    "powerman/vim-plugin-AnsiEsc",
  })

  -- Run :PackerSync if it is the first time.
  -- You still need to run :PackerSync from time to time to keep all the plugins
  -- up to date.
  if packer_bootstrap then
    require("packer").sync()
  end
end)

-- Stop here if it is the first time.
if packer_bootstrap then
  print("Please restart Neovim to load the plugins just installed.")
  return
end
