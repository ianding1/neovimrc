-- Use 24-bit colors in the terminal.
vim.o.termguicolors = true

-- Use spaces instead of tabs.
vim.o.expandtab = true

-- Use 4 spaces by default.
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

-- Show a visual line under the cursor.
vim.o.cursorline = true

-- Disable write backup and swap files.
vim.o.writebackup = false
vim.o.swapfile = false

-- Enable mouse in the terminal.
vim.o.mouse = "a"

-- Always show 5 lines above or below the cursor.
vim.o.scrolloff = 3

-- Disable sign column.
vim.o.signcolumn = "no"

-- Hide intro at Vim startup.
vim.o.shortmess = vim.o.shortmess .. "I"

-- Split below and right.
vim.o.splitbelow = true
vim.o.splitright = true

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

-- Copy/paste for MacOS.
vim.keymap.set("v", "<D-c>", '"+y') -- Copy
vim.keymap.set({ "n", "v", "s", "x", "o", "i", "l", "c", "t" }, "<D-v>", function() -- Paste
  vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end, { noremap = true, silent = true })

-- Disable some animations in Neovide.
vim.g.neovide_cursor_animate_command_line = false
vim.g.neovide_cursor_animate_in_insert_mode = false

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
    "bluz71/vim-moonfly-colors",
    config = function()
      vim.cmd([[colorscheme moonfly]])
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
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup()
      vim.keymap.set("n", "-", "<Cmd>Oil<CR>")
    end,
  })

  -- Enhance the writing experience.
  use({
    "preservim/vim-pencil",
    config = function()
      vim.keymap.set("n", "<space>pp", "<Cmd>PencilToggle<CR>")
      vim.keymap.set("n", "<space>ph", "<Cmd>PencilHard<CR>")
      vim.keymap.set("n", "<space>ps", "<Cmd>PencilSoft<CR>")
      vim.keymap.set("n", "<space>po", "<Cmd>PencilOff<CR>")

      -- Set autocommands for specific file types.
      local text_augroup = vim.api.nvim_create_augroup("PencilTextAugroup", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text" },
        callback = function()
          vim.fn["pencil#init"]({ wrap = "soft" })
        end,
        group = text_augroup,
      })
    end,
  })

  use({
    "folke/zen-mode.nvim",
    config = function()
      local zen_mode = require("zen-mode")
      vim.keymap.set("n", "<space>j", function()
        zen_mode.toggle({
          window = { width = 80 },
        })
      end)
      vim.keymap.set("n", "<space>k", zen_mode.toggle)
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
      vim.keymap.set("n", "<space>re", fzf.resume)

      -- Bind LSP actions to FZF.
      vim.keymap.set("n", "gD", fzf.lsp_typedefs)
      vim.keymap.set("n", "gd", fzf.lsp_definitions)
      vim.keymap.set("n", "gi", fzf.lsp_implementations)
      vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help)
      vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
      vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename)
      vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action)
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

  -- A very powerful Git plugin for Vim.
  -- See http://vimcasts.org/categories/git/ for a series of awesome tutorials on fugitive.
  use("tpope/vim-fugitive")

  -- Allow using readline mappings (C-d/C-e/C-f/etc) in the command line mode.
  use("tpope/vim-rsi")

  -- Below are the plugins to configure LSP and auto completion.
  --
  -- This configuration uses Neovim's native LSP API. You are encouraged to also check out
  -- coc.nvim, which was created before Neovim LSP was added, closed in the gap for Vim LSP support, and has maintained an active community till today.
  --
  -- I don't use snippets personally but Neovim LSP requires a snippet engine.
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
      })
    end,
  })

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

  -- Folding.
  use({
    "kevinhwang91/nvim-ufo",
    requires = "kevinhwang91/promise-async",
    config = function()
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      local ufo = require("ufo")
      vim.keymap.set("n", "zR", ufo.openAllFolds)
      vim.keymap.set("n", "zM", ufo.closeAllFolds)
      ufo.setup()
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
          typescript = { "prettierd", "prettier", stop_after_first = true },
        },
      })

      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
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
