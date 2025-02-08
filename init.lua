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
vim.opt.diffopt = vim.opt.diffopt + "linematch:60" + "context:999"

-- Allow returning to normal mode by just pressing <Esc> in terminal mode.
-- To send <Esc> to the terminal, press <C-v><Esc>.
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { silent = true, noremap = true })
vim.keymap.set("t", "<C-v><Esc>", "<Esc>", { silent = true, noremap = true })

-- Set up diagnostic sign icons.
vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵 ", texthl = "DiagnosticSignHint" })

-- Window and tab key bindings.
for _, dir in pairs({ "h", "j", "k", "l" }) do
  vim.keymap.set("n", "<C-" .. dir .. ">", "<C-w>" .. dir, { silent = true, noremap = true })
end

vim.keymap.set("n", "<C-t>", "<Cmd>tabnew<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-x>", "<Cmd>tabclose<CR>", { silent = true, noremap = true })

-- Remap + and _ to ctrl-a and ctrl-x to allow us to map the tmux prefix key to ctrl-a.
vim.keymap.set({ "n", "v" }, "+", "<C-a>", { silent = true, noremap = true })
vim.keymap.set({ "n", "v" }, "_", "<C-x>", { silent = true, noremap = true })

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

  -- Status line.
  use({
    "nvim-lualine/lualine.nvim",
    config = function()
      local symbols = {
        modified = "",
        readonly = "󰌾",
        unnamed = "[No Name]",
        newfile = "",
      }

      require("lualine").setup({
        tabline = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "tabs", mode = 2, show_modified_status = false } },
          lualine_x = {
            function()
              return require("lsp-progress").progress()
            end,
          },
          lualine_y = { "encoding", "fileformat", "filetype" },
          lualine_z = { "progress", "location" },
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { "filename", path = 1, symbols = symbols } },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { "filename", path = 1, symbols = symbols } },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  })

  -- Undotree UI. Visualize the undo history as a tree.
  use({
    "mbbill/undotree",
    config = function()
      vim.keymap.set("n", "U", "<Cmd>UndotreeToggle<CR>", {
        desc = "Toggle Undo tree",
      })
    end,
  })

  -- File manager.
  use({
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup({
        keymaps = {
          ["<CR>"] = "actions.select",
          ["<C-v>"] = { "actions.select", opts = { vertical = true } },
          ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
          ["<C-t>"] = { "actions.select", opts = { tab = true } },
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = { "actions.close", mode = "n" },
          ["<M-k>"] = { "actions.show_help", mode = "n" },
          ["<M-r>"] = "actions.refresh",
          ["-"] = { "actions.parent", mode = "n" },
          ["_"] = { "actions.open_cwd", mode = "n" },
          ["`"] = { "actions.cd", mode = "n" },
          ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
          ["<M-.>"] = { "actions.toggle_hidden", mode = "n" },
        },
      })
      vim.keymap.set("n", "-", "<Cmd>Oil<CR>", {
        desc = "Open parent directory",
      })
    end,
  })

  -- Quick navigation between commonly accessed files.
  use({
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      vim.keymap.set("n", "M", function()
        harpoon:list():add()
      end)
      vim.keymap.set("n", "H", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      for i = 1, 5 do
        vim.keymap.set("n", "]" .. i, function()
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
      fzf.setup({})

      -- File/buffer/glob fuzzy search.
      vim.keymap.set("n", "<C-f>", fzf.files)
      vim.keymap.set("n", "<C-b>", fzf.buffers)
      vim.keymap.set("n", "<C-s>", fzf.live_grep_glob)

      -- Bind LSP actions to FZF.
      vim.keymap.set("n", "gD", fzf.lsp_typedefs)
      vim.keymap.set("n", "gd", fzf.lsp_definitions)
      vim.keymap.set("n", "gi", fzf.lsp_implementations)
      vim.keymap.set("n", "gr", fzf.lsp_references)
      vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help)
      vim.keymap.set("n", "<M-d>", vim.diagnostic.open_float)
      vim.keymap.set("n", "<M-CR>", fzf.lsp_code_actions)
      vim.keymap.set("n", "<M-r>", vim.lsp.buf.rename)
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
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use("hrsh7th/cmp-cmdline")
  use("L3MON4D3/LuaSnip")
  use("saadparwaiz1/cmp_luasnip")
  use({
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<C-y>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
          ["<C-e>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
          ["<C-n>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
            else
              cmp.complete()
            end
          end, { "i", "c" }),
          ["<C-p>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
            else
              cmp.complete()
            end
          end, { "i", "c" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "c" }),
          ["<C-c>"] = cmp.mapping(cmp.mapping.abort(), { "i", "c" }),
        },
        window = {
          completion = {
            col_offset = -2,
            side_padding = 1,
          },
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = require("lspkind").cmp_format({ mode = "symbol", maxwidth = 50, ellipsis_char = "..." }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        window = {
          completion = {
            col_offset = -1,
            side_padding = 1,
          },
        },
        formatting = {
          fields = { "abbr", "menu" },
          format = require("lspkind").cmp_format({ maxwidth = 50, ellipsis_char = "..." }),
        },
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        window = {
          completion = {
            col_offset = -1,
            side_padding = 1,
          },
        },
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
      })
    end,
  })
  use({
    "onsails/lspkind.nvim",
    config = function()
      require("lspkind").setup({
        preset = "codicons",
      })
    end,
  })

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

  -- Show LSP progress on lualine.
  use({
    "linrongbin16/lsp-progress.nvim",
    config = function()
      local api = require("lsp-progress.api")
      require("lsp-progress").setup({
        format = function(client_messages)
          local ready_sign = " lsp"
          local busy_sign = "󰔚 lsp"
          if #client_messages > 0 then
            return busy_sign .. " " .. table.concat(client_messages, " ")
          end
          if #api.lsp_clients() > 0 then
            return ready_sign
          end
          return ""
        end,
      })

      vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = "lualine_augroup",
        pattern = "LspProgressStatusUpdated",
        callback = require("lualine").refresh,
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
      vim.keymap.set("n", "<C-g>", "<Cmd>DiffviewOpen<CR>", {
        desc = "Show Git diff view",
      })
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
