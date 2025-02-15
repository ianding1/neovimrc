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

-- Use [q and ]q to navigate in the quickfix list.
vim.keymap.set("n", "]q", "<Cmd>cnext<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "[q", "<Cmd>cprevious<CR>", { silent = true, noremap = true })

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
      vim.keymap.set("n", "U", "<Cmd>UndotreeToggle<CR>")
    end,
  })

  -- File manager.
  use({
    "stevearc/oil.nvim",
    config = function()
      local oil = require("oil")
      oil.setup({
        keymaps = {
          ["<CR>"] = "actions.select",
          ["<C-v>"] = { "actions.select", opts = { vertical = true } },
          ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
          ["<C-t>"] = { "actions.select", opts = { tab = true } },
          ["<C-c>"] = { "actions.close", mode = "n" },
          ["<Esc>"] = { "actions.close", mode = "n" },
          ["g?"] = { "actions.show_help", mode = "n" },
          ["-"] = { "actions.parent", mode = "n" },
          ["_"] = { "actions.open_cwd", mode = "n" },
          ["<M-h>"] = { "actions.toggle_hidden", mode = "n" },
        },
        view_options = {
          show_hidden = true,
        },
        float = {
          max_width = 0.80,
          max_height = 0.85,
        },
      })
      vim.keymap.set("n", "-", function()
        oil.open_float(".")
      end)
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
        files = {
          cwd_prompt = false,
        },
        keymap = {
          builtin = {
            ["<C-f>"] = "preview-page-down",
            ["<C-b>"] = "preview-page-up",
          },
          fzf = {
            ["ctrl-f"] = "half-page-down",
            ["ctrl-b"] = "half-page-up",
            ["ctrl-a"] = "beginning-of-line",
            ["ctrl-e"] = "end-of-line",
            ["alt-a"] = "toggle-all",
          },
        },
        actions = {
          files = {
            ["enter"] = fzf.actions.file_edit_or_qf,
            ["ctrl-s"] = fzf.actions.file_split,
            ["ctrl-v"] = fzf.actions.file_vsplit,
            ["ctrl-t"] = fzf.actions.file_tabedit,
            ["alt-i"] = fzf.actions.toggle_ignore,
            ["alt-h"] = fzf.actions.toggle_hidden,
            ["alt-f"] = fzf.actions.toggle_follow,
          },
        },
      })

      -- File/buffer/glob fuzzy search.
      vim.keymap.set("n", "<C-f>", fzf.files)
      vim.keymap.set("n", "<C-b>", fzf.buffers)
      vim.keymap.set("n", "<C-g>", fzf.live_grep_glob)

      -- Bind LSP actions to FZF.
      vim.keymap.set("n", "gd", fzf.lsp_definitions)
      vim.keymap.set("n", "gr", fzf.lsp_references)
      vim.keymap.set("n", "gI", fzf.lsp_implementations)
      vim.keymap.set("n", "gy", fzf.lsp_typedefs)
      vim.keymap.set("n", "gD", fzf.lsp_declarations)
      vim.keymap.set("n", "<M-d>", vim.diagnostic.open_float)
      vim.keymap.set({ "n", "i" }, "<M-CR>", fzf.lsp_code_actions)
      vim.keymap.set({ "n", "i" }, "gR", vim.lsp.buf.rename)
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
  use({
    "saghen/blink.cmp",
    run = "cargo build --release",
    config = function()
      require("blink.cmp").setup({
        keymap = { preset = "super-tab" },
        completion = {
          documentation = { auto_show = true, auto_show_delay_ms = 500 },
          trigger = { show_in_snippet = false },
        },
        signature = { enabled = true },
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

      local capabilities = require("blink.cmp").get_lsp_capabilities()

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
      vim.keymap.set("n", "<space>gs", "<Cmd>DiffviewOpen<CR>")
      vim.keymap.set("n", "<space>gh", "<Cmd>DiffviewFileHistory<CR>")
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
