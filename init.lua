-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

-- Bind leader keys.
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Use 24-bit colors in the terminal.
vim.o.termguicolors = true

-- Use spaces instead of tabs.
vim.o.expandtab = true

-- Use 4 spaces by default.
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

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
vim.o.scrolloff = 5

-- Show line numbers.
vim.o.number = true

-- Hide intro at Vim startup.
vim.opt.shortmess:append("I")

-- Split below and right.
vim.o.splitbelow = true
vim.o.splitright = true

-- Set the fill char for diff to blank.
vim.opt.fillchars = { diff = "╱", foldopen = "⌄", foldclose = "▶", foldsep = " " }

-- Show relative line number.
vim.opt.relativenumber = true

-- Set sign column.
vim.opt.signcolumn = "yes:1"

-- Never show tablines.
vim.opt.showtabline = 0

-- Always show a global status line.
vim.opt.laststatus = 3

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

-- Start diff mode with vertical splits.
vim.opt.diffopt:append("vertical")

-- Set fold column to 1.
vim.opt.diffopt:append("foldcolumn:1")
vim.opt.foldcolumn = "1"

-- Enable text highlight for fold mode.
vim.opt.foldtext = ""

-- Disable sign column and fold column in help buffers.
vim.api.nvim_create_augroup("helpbuf_augroup", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = "helpbuf_augroup",
    pattern = "help",
    callback = function()
        vim.wo.signcolumn = "no"
        vim.wo.foldcolumn = "0"
    end,
})

-- Use H/L to switch tab pages.
vim.keymap.set("n", "H", "<cmd>tabprevious<cr>")
vim.keymap.set("n", "L", "<cmd>tabnext<cr>")

-- Allow returning to normal mode by just pressing <Esc> in terminal mode.
-- To send <Esc> to the terminal, press <M-Esc>.
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<M-Esc>", "<Esc>")

-- Set up diagnostic sign icons.
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
        },
    },
})

-- Window and tab key bindings.
for _, dir in ipairs({ "h", "j", "k", "l" }) do
    vim.keymap.set("n", "<C-" .. dir .. ">", "<C-w>" .. dir)
end

vim.keymap.set("n", "<leader>x", "<cmd>tabclose<cr>")

-- Quickfix navigation.
local function quickfix_next()
    local count = vim.v.count == 0 and 1 or vim.v.count
    for _ = 1, count do
        local ok, msg = pcall(vim.cmd, "cbelow")
        if not ok and (string.find(msg, "E553:") or string.find(msg, "E42:")) then
            ok, msg = pcall(vim.cmd, "cnext")
            if not ok and string.find(msg, "E553:") then
                vim.cmd("cfirst")
            elseif not ok and string.find(msg, "E42:") then
                vim.print("Empty quickfix list")
            elseif not ok then
                vim.api.nvim_err_writeln(msg)
            end
        elseif not ok then
            vim.api.nvim_err_writeln(msg)
        end
    end
end

local function quickfix_previous()
    local count = vim.v.count == 0 and 1 or vim.v.count
    for _ = 1, count do
        local ok, msg = pcall(vim.cmd, "cabove")
        if not ok and (string.find(msg, "E553:") or string.find(msg, "E42:")) then
            ok, msg = pcall(vim.cmd, "cprevious")
            if not ok and string.find(msg, "E553:") then
                vim.cmd("clast")
            elseif not ok and string.find(msg, "E42:") then
                vim.print("Empty quickfix list")
            elseif not ok then
                vim.api.nvim_err_writeln(msg)
            end
        elseif not ok then
            vim.api.nvim_err_writeln(msg)
        end
    end
end

vim.keymap.set("n", "}", quickfix_next)
vim.keymap.set("n", "{", quickfix_previous)

vim.api.nvim_create_augroup("qf_augroup", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = "qf_augroup",
    pattern = "qf",
    callback = function()
        -- Disable unnecessary status column components.
        vim.wo.relativenumber = false
        vim.wo.signcolumn = "no"

        -- Close quickfix window with q.
        vim.keymap.set("n", "q", "<C-w>q", { buffer = true })
    end,
})

-- LSP key bindings.
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename)

-- Lazy.nvim UI.
vim.keymap.set("n", "<leader>ol", "<cmd>Lazy<cr>")

require("lazy").setup({
    spec = {
        {
            "rebelot/kanagawa.nvim",
            priority = 1000,
            config = function()
                vim.cmd.colorscheme("kanagawa")
            end,
        },
        {
            "nvim-tree/nvim-web-devicons",
            lazy = true,
        },
        {
            "nvim-lualine/lualine.nvim",
            opts = function()
                local symbols = {
                    modified = " ",
                    readonly = "󰌾 ",
                    unnamed = "[No Name]",
                    newfile = " ",
                }
                return {
                    extensions = { "quickfix" },
                    sections = {
                        lualine_a = { "mode" },
                        lualine_b = {
                            {
                                "󱂬 [%{tabpagenr()}/%{tabpagenr('$')}]",
                                type = "stl",
                                cond = function()
                                    return vim.fn.tabpagenr("$") > 1
                                end,
                            },
                            "branch",
                            "diff",
                        },
                        lualine_c = {
                            function()
                                return require("lsp-progress").progress()
                            end,
                        },
                        lualine_x = {
                            "diagnostics",
                        },
                        lualine_y = { "encoding", "fileformat", "filetype" },
                        lualine_z = { "progress", "location" },
                    },
                    winbar = {
                        lualine_a = {},
                        lualine_b = {
                            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                            { "filename", path = 1, symbols = symbols, shorting_target = 3 },
                        },
                        lualine_c = {},
                        lualine_x = {},
                        lualine_y = {},
                        lualine_z = {},
                    },
                    inactive_winbar = {
                        lualine_a = {},
                        lualine_b = {},
                        lualine_c = {
                            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
                            { "filename", path = 1, symbols = symbols, shorting_target = 3 },
                        },
                        lualine_x = {},
                        lualine_y = {},
                        lualine_z = {},
                    },
                }
            end,
        },
        {
            "luukvbaal/statuscol.nvim",
            opts = function()
                local builtin = require("statuscol.builtin")
                return {
                    relculright = true,
                    segments = {
                        {
                            text = { builtin.lnumfunc },
                            click = "v:lua.ScLa",
                        },
                        {
                            text = { "%s" },
                            condition = {
                                function(args)
                                    return args.buf
                                end,
                            },
                            click = "v:lua.ScLa",
                        },
                        { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
                    },
                }
            end,
        },
        {
            "mbbill/undotree",
            keys = {
                { "<leader>u", "<cmd>UndotreeToggle<bar>UndotreeFocus<cr>" },
            },
        },
        {
            "stevearc/oil.nvim",
            keys = {
                { "-", "<cmd>Oil<cr>" },
            },
            opts = {
                keymaps = {
                    ["<cr>"] = "actions.select",
                    ["<C-v>"] = { "actions.select", opts = { vertical = true } },
                    ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
                    ["<C-t>"] = { "actions.select", opts = { tab = true } },
                    ["gq"] = { "actions.close", mode = "n" },
                    ["g?"] = { "actions.show_help", mode = "n" },
                    ["<localleader>r"] = { "actions.refresh", mode = "n" },
                    ["<localleader>h"] = { "actions.toggle_hidden", mode = "n" },
                    ["<localleader>s"] = {
                        function()
                            require("grug-far").open({ prefills = { paths = require("oil").get_current_dir() } })
                        end,
                        mode = "n",
                        desc = "Search in directory",
                    },
                    ["-"] = { "actions.parent", mode = "n" },
                },
                use_default_keymaps = false,
                win_options = {
                    foldcolumn = "1",
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
                { "<C-f>", "<cmd>FzfLua files<cr>" },
                { "<C-b>", "<cmd>FzfLua blines<cr>" },
                { "<C-g>", "<cmd>FzfLua live_grep_glob<cr>" },
                { "<leader>t", "<cmd>FzfLua tabs<cr>" },
                { "<leader>f", "<cmd>call feedkeys(':FzfLua ', 'tn')<cr>" },

                -- LSP actions.
                { "gd", "<cmd>FzfLua lsp_definitions<cr>" },
                { "gr", "<cmd>FzfLua lsp_references<cr>" },
                { "gI", "<cmd>FzfLua lsp_implementations<cr>" },
                { "gy", "<cmd>FzfLua lsp_typedefs<cr>" },
                { "gD", "<cmd>FzfLua lsp_declarations<cr>" },
                { "<leader>ca", "<cmd>FzfLua lsp_code_actions<cr>" },
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
                            ["ctrl-q"] = "toggle-all",
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
                -- Disable closing single quotes on ocaml and rust files.
                autopairs.get_rule("'")[1].not_filetypes = { "ocaml", "rust" }
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
                appearance = {
                    nerd_font_variant = "normal",
                },
                keymap = {
                    preset = "super-tab",
                },
                cmdline = {
                    keymap = {
                        ["<Tab>"] = { "show", "accept" },
                    },
                    completion = { menu = { auto_show = true } },
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
                { "<leader>om", "<cmd>Mason<cr>" },
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
            opts = {
                server = {
                    on_attach = function(_, bufnr)
                        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    end,
                    default_settings = {
                        ["rust-analyzer"] = {
                            completion = {
                                callable = {
                                    snippets = "add_parentheses",
                                },
                            },
                        },
                    },
                },
            },
            config = function(_, opts)
                vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
            end,
        },
        {
            "linrongbin16/lsp-progress.nvim",
            event = "VeryLazy",
            opts = {
                format = function(client_messages)
                    local ready_sign = " lsp"
                    local busy_sign = "󰔚 "
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
                ensure_installed = {
                    "c",
                    "diff",
                    "gitcommit",
                    "gitignore",
                    "json",
                    "lua",
                    "vim",
                    "vimdoc",
                    "markdown",
                    "markdown_inline",
                },
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
                vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.opt.foldmethod = "expr"
                -- Expand all folds by default.
                vim.opt.foldlevel = 999
            end,
        },
        {
            "stevearc/conform.nvim",
            event = "VeryLazy",
            opts = {
                default_format_opts = {
                    timeout_ms = 3000,
                    async = false,
                    quiet = false,
                    lsp_format = "fallback",
                },
                format_on_save = {
                    enabled = true,
                },
                formatters_by_ft = {
                    lua = { "stylua" },
                    python = { "black" },
                    rust = { "rustfmt" },
                    typescript = { "prettierd" },
                },
            },
            config = function(_, opts)
                require("conform").setup(opts)
                vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
            end,
        },
        {
            "lewis6991/gitsigns.nvim",
            event = "VeryLazy",
            keys = {
                { "<leader>hq", "<cmd>Gitsigns setqflist<cr>" },
                { "<leader>hs", "<cmd>Gitsigns stage_hunk<cr>" },
                {
                    "<leader>hs",
                    function()
                        require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end,
                    mode = "v",
                },
                { "<leader>hS", "<cmd>Gitsigns stage_buffer<cr>" },
                { "<leader>hx", "<cmd>Gitsigns reset_hunk<cr>" },
                {
                    "<leader>hx",
                    function()
                        require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end,
                    mode = "v",
                },
                { "<leader>hX", "<cmd>Gitsigns reset_buffer<cr>" },
                { "<leader>hp", "<cmd>Gitsigns preview_hunk<cr>" },
                { "<leader>hb", "<cmd>Gitsigns blame<cr>" },
                { "[h", "<cmd>Gitsigns nav_hunk prev<cr>" },
                { "]h", "<cmd>Gitsigns nav_hunk next<cr>" },
            },
            opts = {
                preview_config = {
                    border = "rounded",
                },
            },
        },
        {
            "tpope/vim-fugitive",
            event = "VeryLazy",
            keys = {
                { "<leader>g", "<cmd>tab Git<cr>" },
            },
            config = function()
                vim.api.nvim_create_augroup("fugitive_commit_augroup", { clear = true })
                vim.api.nvim_create_autocmd("User", {
                    group = "fugitive_commit_augroup",
                    pattern = "FugitiveCommit",
                    callback = function()
                        vim.wo.foldmethod = "syntax"
                    end,
                })
            end,
        },
        {
            "MagicDuck/grug-far.nvim",
            keys = {
                {
                    "<leader>sf",
                    function()
                        require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
                    end,
                },
                {
                    "<leader>ss",
                    function()
                        require("grug-far").open()
                    end,
                },
            },
            opts = {
                icons = {
                    resultsChangeIndicator = "▉",
                    resultsAddedIndicator = "▉",
                    resultsRemovedIndicator = "▉",
                    resultsDiffSeparatorIndicator = "┊",
                },
            },
        },
    },
    checker = {
        enabled = false,
    },
})
