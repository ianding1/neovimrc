-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

-- Do not show mode change.
vim.opt.showmode = false

-- Use spaces instead of tabs.
vim.opt.expandtab = true

-- Enable line break.
vim.opt.linebreak = true

-- Use 4 spaces by default.
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Show a visual line under the cursor.
vim.opt.cursorline = true

-- Ignore case by default.
vim.opt.ignorecase = true

-- Disable write backup and swap files.
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Enable mouse in the terminal.
vim.opt.mouse = "a"

-- Always show 5 lines above or below the cursor.
vim.opt.scrolloff = 5

-- Show line numbers.
vim.opt.number = true

-- Show relative line number.
vim.opt.relativenumber = true

-- Set sign column.
vim.opt.signcolumn = "yes:1"

-- Set status column
vim.opt.statuscolumn = "%l%s%C"

-- Hide intro at Vim startup.
vim.opt.shortmess:append("I")

-- Split below and right.
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Set the fill char for diff to blank.
vim.opt.fillchars = { diff = "╱", foldopen = "⌄", foldclose = "▶", foldsep = " " }

-- Allow virtual editing in Visual block mode.
vim.opt.virtualedit:append("block")

-- Disable wrapping.
vim.opt.wrap = false

-- Persist the undo records on the disk.
if vim.fn.has("persistent_undo") == 1 then
    vim.fn.system("mkdir -p $HOME/.cache/vim-undo")
    vim.o.undodir = os.getenv("HOME") .. "/.cache/vim-undo"
    vim.o.undofile = true
end

-- Start diff mode with vertical splits.
vim.opt.diffopt:append("vertical")

-- Set fold column to 1 in diff mode..
vim.opt.diffopt:append("foldcolumn:1")

-- Enable text highlight for fold mode.
vim.opt.foldtext = ""

-- Create an autocmd group for the vim config.
vim.api.nvim_create_augroup("vimrc", { clear = true })

-- Disable the status column in help buffers.
vim.api.nvim_create_autocmd("BufRead", {
    group = "vimrc",
    callback = function()
        if vim.bo.buftype == "help" then
            vim.wo.number = false
            vim.wo.relativenumber = false
            vim.wo.signcolumn = "no"
        end
    end,
})

-- Disable relative number and sign column in the quickfix window.
vim.api.nvim_create_autocmd("FileType", {
    group = "vimrc",
    pattern = "qf",
    callback = function()
        vim.wo.relativenumber = false
        vim.wo.signcolumn = "no"
    end,
})

-- To send <Esc> to the terminal, press <M-Esc>.
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<M-Esc>", "<Esc>")

-- Set up diagnostic sign icons.
vim.diagnostic.config({
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
        },
    },
    virtual_text = true,
    virtual_lines = false,
})

-- Toggle virtual text/line style diagnostics with <leader>e
vim.keymap.set("n", "<leader>e", function()
    local orig_config = vim.diagnostic.config() or {
        virtual_text = true,
        virtual_lines = false,
    }
    vim.diagnostic.config(vim.tbl_deep_extend("force", orig_config, {
        virtual_text = not orig_config.virtual_text,
        virtual_lines = not orig_config.virtual_lines,
    }))
end)

-- Window and tab key bindings.
for _, dir in ipairs({ "h", "j", "k", "l" }) do
    vim.keymap.set("n", "<C-" .. dir .. ">", "<C-w>" .. dir)
    vim.keymap.set("t", "<C-" .. dir .. ">", "<C-\\><C-n><C-w>" .. dir)
end

-- Better movement keys.
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Disable search highlight.
vim.keymap.set("n", "<leader>n", "<cmd>nohlsearch<cr>")

-- Lazy.nvim UI.
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>")
require("lazy").setup({
    spec = {
        {
            "willothy/flatten.nvim",
            priority = 1000,
            opts = function()
                local saved_terminal
                return {
                    window = {
                        open = "alternate",
                    },
                    hooks = {
                        pre_open = function()
                            local term = require("toggleterm.terminal")
                            local termid = term.get_focused_id()
                            saved_terminal = term.get(termid)
                        end,
                        post_open = function(ctx)
                            if ctx.is_blocking then
                                if saved_terminal then
                                    saved_terminal:close()
                                end
                                vim.api.nvim_create_autocmd("BufWritePost", {
                                    buffer = ctx.bufnr,
                                    once = true,
                                    callback = vim.schedule_wrap(function()
                                        vim.api.nvim_buf_delete(ctx.bufnr, {})
                                    end),
                                })
                            end
                        end,
                        block_end = function()
                            vim.schedule(function()
                                if saved_terminal then
                                    saved_terminal:open()
                                    saved_terminal = nil
                                end
                            end)
                        end,
                    },
                }
            end,
        },
        {
            "rebelot/kanagawa.nvim",
            priority = 500,
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
                local filepath = {
                    {
                        "filetype",
                        icon_only = true,
                        separator = "",
                        padding = { left = 1, right = 0 },
                    },
                    {
                        "filename",
                        path = 1,
                        newfile_status = true,
                        symbols = {
                            modified = " ",
                            readonly = "󰌾 ",
                            unnamed = "[No Name]",
                            newfile = " ",
                        },
                    },
                }
                return {
                    extensions = { "quickfix", "trouble", "oil" },
                    sections = {
                        lualine_a = {
                            {
                                "mode",
                                fmt = function(str)
                                    if string.find(str, "-") then
                                        return str -- Do not shorten "V-BLOCK", "V-LINE", etc
                                    else
                                        return str:sub(1, 1)
                                    end
                                end,
                            },
                        },
                        lualine_b = filepath,
                        lualine_c = { "require('lsp-progress').progress()" },
                        lualine_x = { "diagnostics" },
                        lualine_y = { { "b:gitsigns_head", icon = "" } },
                        lualine_z = { "progress", "location" },
                    },
                    inactive_sections = {
                        lualine_b = {
                            function()
                                return "  " -- Placeholder
                            end,
                        },
                        lualine_c = filepath,
                        lualine_x = { "progress", "location" },
                    },
                }
            end,
        },
        {
            "linrongbin16/lsp-progress.nvim",
            config = function()
                require("lsp-progress").setup({
                    format = function(client_messages)
                        if #client_messages > 0 then
                            return table.concat(client_messages, "  ")
                        end
                        return ""
                    end,
                })
                vim.api.nvim_create_autocmd("User", {
                    group = "vimrc",
                    pattern = "LspProgressStatusUpdated",
                    callback = require("lualine").refresh,
                })
            end,
        },
        {
            "mbbill/undotree",
            keys = { { "<leader>u", "<cmd>UndotreeToggle<bar>UndotreeFocus<cr>" } },
        },
        {
            "stevearc/oil.nvim",
            lazy = false,
            keys = {
                { "-", "<cmd>Oil<cr>" },
            },
            opts = {
                keymaps = {
                    ["<cr>"] = "actions.select",
                    ["<C-v>"] = { "actions.select", opts = { vertical = true } },
                    ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
                    ["<C-t>"] = { "actions.select", opts = { tab = true } },
                    ["-"] = { "actions.parent", mode = "n" },
                    ["gq"] = { "actions.close", mode = "n" },
                    ["g?"] = { "actions.show_help", mode = "n" },
                    ["g."] = { "actions.toggle_hidden", mode = "n" },
                    ["<localleader>cd"] = { "actions.cd", mode = "n" },
                    ["sf"] = {
                        callback = function()
                            require("fzf-lua").files({ cwd = require("oil").get_current_dir() })
                        end,
                        desc = "Search files in directory",
                    },
                    ["sg"] = {
                        callback = function()
                            require("fzf-lua").live_grep_glob({ cwd = require("oil").get_current_dir() })
                        end,
                        desc = "Search file content in directory",
                    },
                },
                use_default_keymaps = false,
                win_options = {
                    signcolumn = "yes:1",
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
                -- Disable default behavior for s.
                { "s", "<nop>" },

                -- File, buffer, greps.
                { "sf", "<cmd>FzfLua files<cr>" },
                { "sb", "<cmd>FzfLua buffers<cr>" },
                { "sg", "<cmd>FzfLua live_grep_glob<cr>" },
                { "sl", "<cmd>FzfLua blines<cr>" },
                { "sh", "<cmd>FzfLua helptags<cr>" },
                { "ss", "<cmd>FzfLua git_status<cr>" },
                { "s*", "<cmd>FzfLua grep_cword<cr>" },
                { "s:", "<cmd>call feedkeys(':FzfLua ', 'tn')<cr>" },

                -- LSP actions.
                { "grr", "<cmd>FzfLua lsp_references<cr>" },
                { "gri", "<cmd>FzfLua lsp_implementations<cr>" },
                { "gra", "<cmd>FzfLua lsp_code_actions<cr>" },
            },
            opts = function()
                local actions = require("fzf-lua").actions
                return {
                    defaults = {
                        no_header = true,
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
            "saghen/blink.cmp",
            version = "*",
            build = "cargo build --release",
            opts = {
                appearance = { nerd_font_variant = "normal" },
                keymap = { preset = "super-tab" },
                cmdline = {
                    keymap = { ["<Tab>"] = { "show", "accept" } },
                    completion = { menu = { auto_show = true } },
                },
                completion = {
                    documentation = {
                        auto_show = true,
                        auto_show_delay_ms = 500,
                    },
                    trigger = { show_in_snippet = false },
                },
                signature = { enabled = true },
            },
        },
        {
            "neovim/nvim-lspconfig",
            dependencies = { "saghen/blink.cmp" },
            config = function()
                -- Enable inlay hints if the LSP client supports it.
                vim.api.nvim_create_autocmd("LspAttach", {
                    callback = function(args)
                        local client = vim.lsp.get_client_by_id(args.data.client_id)
                        if client and client.server_capabilities.inlayHintProvider then
                            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
                        end

                        vim.keymap.set("n", "gO", "<cmd>Trouble symbols toggle focus=false<cr>", { buffer = args.buf })
                    end,
                })
                local capabilities = require("blink.cmp").get_lsp_capabilities()
                local lspconfig = require("lspconfig")

                -- Lua
                lspconfig.lua_ls.setup({
                    capabilities = capabilities,
                    on_init = function(client)
                        if client.workspace_folders then
                            local path = client.workspace_folders[1].name
                            if
                                path ~= vim.fn.stdpath("config")
                                and (
                                    vim.loop.fs_stat(path .. "/.luarc.json")
                                    or vim.loop.fs_stat(path .. "/.luarc.jsonc")
                                )
                            then
                                return
                            end
                        end

                        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                            runtime = {
                                version = "LuaJIT",
                            },
                            workspace = {
                                checkThirdParty = false,
                                library = {
                                    vim.env.VIMRUNTIME,
                                    "${3rd}/luv/library",
                                    "${3rd}/busted/library",
                                },
                            },
                        })
                    end,
                    settings = {
                        Lua = {},
                    },
                })

                -- C/C++
                lspconfig.clangd.setup({
                    capabilities = capabilities,
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        -- Disable function argument auto-completion
                        "--function-arg-placeholders=0",
                    },
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
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            event = "VeryLazy",
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
                    vue = { "prettierd" },
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
                { "g:", "<cmd>call feedkeys(':Gitsigns ', 'tn')<cr>" },
            },
            opts = {
                preview_config = {
                    border = "rounded",
                },
            },
        },
        {
            "akinsho/toggleterm.nvim",
            version = "*",
            keys = {
                { "<C-/>", '<cmd>exe v:count1 . "ToggleTerm"<cr>' },
            },
            opts = {
                open_mapping = "<C-/>",
                shading_factor = -20,
                size = function()
                    return vim.o.lines * 0.4
                end,
            },
        },
        {
            "folke/trouble.nvim",
            keys = {
                { "d:", "<cmd>call feedkeys(':Trouble ', 'tn')<cr>" },
            },
            cmd = "Trouble",
        },
        {
            name = "amazonq",
            url = "ssh://git.amazon.com/pkg/AmazonQNVim",
            lazy = false,
            keys = {
                { "q:", "<cmd>call feedkeys(':AmazonQ ', 'tn')<cr>" },
            },
            opts = {
                ssoStartUrl = "https://amzn.awsapps.com/start",
            },
            config = function(_, opts)
                require("amazonq").setup(opts)

                -- Disable the sign column in the Amazon Q chat.
                vim.api.nvim_create_autocmd("FileType", {
                    group = "vimrc",
                    callback = function()
                        if vim.b.amazonq then
                            vim.wo.signcolumn = "no"
                        end
                    end,
                })
            end,
        },
    },
    checker = {
        enabled = false,
    },
})
