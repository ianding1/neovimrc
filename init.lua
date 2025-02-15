-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

-- Bind leader keys.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

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
vim.opt.shortmess:append("I")

-- Split below and right.
vim.o.splitbelow = true
vim.o.splitright = true

-- Set the fill char for diff to blank.
vim.opt.fillchars = { diff = " " }

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
vim.opt.diffopt:append("linematch:60")
vim.opt.diffopt:append("context:999")

-- Allow returning to normal mode by just pressing <Esc> in terminal mode.
-- To send <Esc> to the terminal, press <M-Esc>.
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<M-Esc>", "<Esc>")

-- Set up diagnostic sign icons.
vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵 ", texthl = "DiagnosticSignHint" })

-- Window and tab key bindings.
for _, dir in ipairs({ "h", "j", "k", "l" }) do
  vim.keymap.set("n", "<C-" .. dir .. ">", "<C-w>" .. dir)
end

-- Key bindings to open and close tabpages.
vim.keymap.set("n", "<C-t>", "<cmd>tabnew<cr>")
vim.keymap.set("n", "<C-x>", "<cmd>tabclose<cr>")

-- Quickfix navigation.
vim.keymap.set("n", "]q", "<cmd>cnext<cr>")
vim.keymap.set("n", "[q", "<cmd>cprevious<cr>")

-- LSP key bindings.
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)

-- Lazy.nvim UI.
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>")

require("lazy").setup({
  spec = {
    {
      "rebelot/kanagawa.nvim",
      priority = 1000,
      config = function()
        vim.cmd.colorscheme("kanagawa")
      end,
    },
    -- {
    --   "nvim-lua/plenary.nvim",
    --   lazy = true,
    -- },
    {
      "nvim-tree/nvim-web-devicons",
      lazy = true,
    },
    {
      "nvim-lualine/lualine.nvim",
      opts = function()
        local symbols = {
          modified = "",
          readonly = "󰌾",
          unnamed = "[No Name]",
          newfile = "",
        }
        return {
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
        }
      end,
    },
    {
      "mbbill/undotree",
      keys = {
        { "<leader>u", "<cmd>UndotreeToggle<cr>" },
      },
    },
    {
      "stevearc/oil.nvim",
      keys = {
        {
          "-",
          function()
            require("oil").open_float(".")
          end,
        },
      },
      opts = {
        keymaps = {
          ["<cr>"] = "actions.select",
          ["<C-v>"] = { "actions.select", opts = { vertical = true } },
          ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
          ["<C-t>"] = { "actions.select", opts = { tab = true } },
          ["<C-c>"] = { "actions.close", mode = "n" },
          ["<esc>"] = { "actions.close", mode = "n" },
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
      },
    },
    {
      "ibhagwan/fzf-lua",
      dependencies = {
        "junegunn/fzf",
        build = "./install --bin",
      },
      keys = {
        -- File, buffer, greps.
        { "<C-f>",  "<cmd>FzfLua files<cr>" },
        { "<C-b>",  "<cmd>FzfLua buffers<cr>" },
        { "<C-g>",  "<cmd>FzfLua live_grep_glob<cr>" },

        -- LSP actions.
        { "gd",     "<cmd>FzfLua lsp_definitions<cr>" },
        { "gr",     "<cmd>FzfLua lsp_references<cr>" },
        { "gI",     "<cmd>FzfLua lsp_implementations<cr>" },
        { "gy",     "<cmd>FzfLua lsp_typedefs<cr>" },
        { "gD",     "<cmd>FzfLua lsp_declarations<cr>" },
        { "<M-cr>", "<cmd>FzfLua lsp_code_actions<cr>" },
      },
      opts = function()
        local actions = require("fzf-lua").actions
        return {
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
              ["ctrl-d"] = "half-page-down",
              ["ctrl-u"] = "half-page-up",
              ["ctrl-a"] = "beginning-of-line",
              ["ctrl-e"] = "end-of-line",
              ["alt-a"] = "toggle-all",
            },
          },
          actions = {
            files = {
              ["enter"] = actions.file_edit_or_qf,
              ["ctrl-s"] = actions.file_split,
              ["ctrl-v"] = actions.file_vsplit,
              ["ctrl-t"] = actions.file_tabedit,
              ["alt-i"] = actions.toggle_ignore,
              ["alt-h"] = actions.toggle_hidden,
              ["alt-f"] = actions.toggle_follow,
            },
          },
        }
      end,
    },
    {
      "windwp/nvim-autopairs",
      event = "VeryLazy",
      opts = {},
      config = function(_, opts)
        local autopairs = require("nvim-autopairs")
        autopairs.setup(opts)
        -- Disable closing single quotes on ocaml files.
        autopairs.get_rule("'")[1].not_filetypes = { "ocaml" }
      end,
    },
    {
      -- Allow using readline mappings (C-d/C-e/C-f/etc) in the command line mode.
      "tpope/vim-rsi",
      event = "VeryLazy",
    },
    {
      "saghen/blink.cmp",
      version = "*",
      build = "cargo build --release",
      opts = {
        keymap = {
          preset = "super-tab",
        },
        completion = {
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
          },
          trigger = {
            show_in_snippet = false,
          },
        },
        signature = {
          enabled = true,
        },
      },
    },
    {
      "williamboman/mason.nvim",
      keys = {
        { "<leader>m", "<cmd>Mason<cr>" },
      },
      build = ":MasonUpdate",
      opts = {},
    },
    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = {
        "williamboman/mason.nvim",
        "neovim/nvim-lspconfig",
        "saghen/blink.cmp",
      },
      opts = {
        ensure_installed = { "lua_ls" },
        automatic_installation = false,
      },
      config = function(_, opts)
        local mason_lspconfig = require("mason-lspconfig")
        mason_lspconfig.setup(opts)

        local lspconfig = require("lspconfig")
        mason_lspconfig.setup_handlers({
          -- Default set up handler.
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = require("blink.cmp").get_lsp_capabilities(),
            })
          end,
          lua_ls = function()
            lspconfig.lua_ls.setup({
              capabilities = require("blink.cmp").get_lsp_capabilities(),
              settings = {
                Lua = {
                  runtime = {
                    version = "LuaJIT",
                  },
                  diagnostics = {
                    globals = { "vim", "vim.g", "vim.b" },
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
    },
    {
      "mrcjkb/rustaceanvim",
      ft = { "rust" },
    },
    {
      "linrongbin16/lsp-progress.nvim",
      event = "VeryLazy",
      opts = {
        format = function(client_messages)
          local ready_sign = " lsp"
          local busy_sign = "󰔚 lsp"
          if #client_messages > 0 then
            return busy_sign .. " " .. table.concat(client_messages, " ")
          end
          local api = require("lsp-progress.api")
          if #api.lsp_clients() > 0 then
            return ready_sign
          end
          return ""
        end,
      },
      config = function(_, opts)
        require("lsp-progress").setup(opts)
        vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
        vim.api.nvim_create_autocmd("User", {
          group = "lualine_augroup",
          pattern = "LspProgressStatusUpdated",
          callback = require("lualine").refresh,
        })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      opts = {
        ensure_installed = { "c", "lua", "vim", "vimdoc", "markdown", "markdown_inline" },
        sync_install = false,
        auto_install = true,
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "+",
            node_incremental = "+",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
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
      },
      config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
      end,
    },
    {
      "stevearc/conform.nvim",
      event = "VeryLazy",
      opts = {
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
      },
      config = function(_, opts)
        require("conform").setup(opts)
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      end,
    },
    {
      "sindrets/diffview.nvim",
      keys = {
        { "<space>gs", "<cmd>DiffviewOpen<cr>" },
        { "<space>gh", "<cmd>DiffviewFileHistory<cr>" },
      },
    },
    {
      "lewis6991/gitsigns.nvim",
      event = "VeryLazy",
      opts = {},
    },
  },
  checker = {
    -- Check for update every day.
    enabled = true,
    frequency = 60 * 60 * 24,
  },
})
