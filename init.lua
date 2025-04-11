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

-- Bind leader key.
vim.g.mapleader = " "

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

-- Set status column.
local function get_fold_char(lnum)
    if not vim.o.number then
        return ""
    end

    if vim.fn.foldlevel(lnum) <= vim.fn.foldlevel(lnum - 1) then
        return " "
    else
        return vim.fn.foldclosed(lnum) == -1 and "⌄" or "▶"
    end
end

function _G.vimrc_statuscol(lnum)
    return get_fold_char(lnum) .. "%l%s"
end

vim.opt.statuscolumn = "%{%v:lua.vimrc_statuscol(v:lnum)%}"

-- Update shortmess: hide intro and search count.
vim.opt.shortmess:append("IS")

-- Split below and right.
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Set the fill char for diff.
vim.opt.fillchars = { diff = "╱" }

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
        vim.wo.number = false
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

-- Disable search highlight and clear command line.
vim.keymap.set("n", "<space>n", function()
    vim.cmd("nohlsearch")
    vim.cmd("echon")
end)

-- Rebind q (start/stop macro) to Ctrl-Q.
vim.keymap.set({ "n", "v" }, "q", "<NOP>")
vim.keymap.set({ "n", "v" }, "<C-q>", "q")

-- Lazy.nvim UI.
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>")
require("lazy").setup({
    spec = {
        {
            "willothy/flatten.nvim",
            priority = 1000,
            opts = { window = { open = "alternate" } },
        },
        {
            "rebelot/kanagawa.nvim",
            priority = 500,
            opts = {
                overrides = function(colors)
                    local theme = colors.theme
                    -- Disable fg color in DiffDelete to avoid overwriting syntax highlight.
                    return { DiffDelete = { fg = "none", bg = theme.diff.delete } }
                end,
            },
            config = function(_, opts)
                require("kanagawa").setup(opts)
                vim.cmd.colorscheme("kanagawa")

                -- Invert the diff colors of the left window in two-file diff mode.
                vim.api.nvim_create_autocmd("DiffUpdated", {
                    group = "vimrc",
                    callback = function()
                        -- Get the number of windows with diff on.
                        local diff_wins = {}
                        for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                            if vim.api.nvim_get_option_value("diff", { win = winid }) then
                                table.insert(diff_wins, { winid = winid, winnr = vim.api.nvim_win_get_number(winid) })
                            end
                        end
                        if #diff_wins ~= 2 then
                            return
                        end
                        -- Sort the windows by number (left/top < right/bottom).
                        table.sort(diff_wins, function(a, b)
                            return a.winnr < b.winnr
                        end)
                        vim.wo[diff_wins[1].winid].winhighlight = table.concat({
                            "DiffDelete:FloatBorder",
                            "DiffAdd:DiffDelete",
                            "DiffChange:DiffDelete",
                        }, ",")
                        vim.wo[diff_wins[2].winid].winhighlight = table.concat({
                            "DiffDelete:FloatBorder",
                            "DiffChange:DiffAdd",
                        }, ",")
                    end,
                })
            end,
        },
        {
            "nvim-tree/nvim-web-devicons",
            lazy = true,
        },
        {
            "nvim-lualine/lualine.nvim",
            opts = function()
                local special_fts = { "qf", "toggleterm", "oil", "trouble" }
                local bufname = {
                    {
                        "filetype",
                        icon_only = true,
                        separator = "",
                        padding = { left = 1, right = 0 },
                        cond = function()
                            return not vim.list_contains(special_fts, vim.bo.filetype)
                        end,
                    },
                    {
                        function()
                            local buf_path = vim.api.nvim_buf_get_name(0)
                            local file_name
                            if vim.startswith(buf_path, "gitsigns://") then
                                local tail = vim.split(buf_path, "//")[3]
                                local commit = tail:match("^(:?[^:]+):")
                                local rel_path = tail:match("^:?[^:]+:(.*)")
                                file_name = vim.fs.basename(rel_path) .. " [" .. commit .. "]"
                            else
                                file_name = vim.fs.basename(buf_path)
                            end
                            if vim.bo.modified then
                                file_name = file_name .. "  "
                            elseif not vim.bo.modifiable then
                                file_name = file_name .. " 󰌾 "
                            elseif file_name == "" then
                                file_name = "[No Name]"
                            end
                            return file_name
                        end,
                        cond = function()
                            return not vim.list_contains(special_fts, vim.bo.filetype)
                        end,
                    },
                    {
                        function()
                            return "ToggleTerm #" .. vim.b.toggle_number
                        end,
                        icon = { " ", color = { fg = 36 } },
                        cond = function()
                            return vim.bo.filetype == "toggleterm"
                        end,
                    },
                    {
                        function()
                            return vim.fn.fnamemodify(require("oil").get_current_dir(), ":~")
                        end,
                        icon = { " ", color = { fg = 75 } },
                        cond = function()
                            return vim.bo.filetype == "oil"
                        end,
                    },
                    {
                        function()
                            local trouble = vim.w.trouble
                            local words = vim.split(trouble.mode, "[%W]")
                            for i, word in ipairs(words) do
                                words[i] = word:sub(1, 1):upper() .. word:sub(2)
                            end
                            return table.concat(words, " ")
                        end,
                        icon = { " ", color = { fg = 74 } },
                        cond = function()
                            return vim.bo.filetype == "trouble"
                        end,
                    },
                    {
                        function()
                            if vim.fn.getwininfo(vim.fn.win_getid())[1].loclist > 0 then
                                return "Location  " .. vim.fn.getloclist(0, { title = 0 }).title
                            end
                            return "Quickfix  " .. vim.fn.getqflist({ title = 0 }).title
                        end,
                        icon = { " ", color = { fg = 74 } },
                        cond = function()
                            return vim.bo.filetype == "qf"
                        end,
                    },
                }
                local opts = {
                    options = {
                        theme = function()
                            local theme = require("kanagawa.colors").setup().theme
                            local kanagawa = require("lualine.themes.kanagawa")
                            kanagawa.normal.c = { bg = theme.ui.bg_p1, fg = theme.syn.comment }
                            kanagawa.inactive = {
                                a = { bg = theme.ui.bg_m3, fg = theme.syn.comment },
                                b = { bg = theme.ui.bg_m3, fg = theme.syn.comment },
                                c = { bg = theme.ui.bg_m3, fg = theme.syn.comment },
                            }
                            kanagawa.terminal = {
                                a = { bg = theme.syn.identifier, fg = theme.ui.bg },
                                b = { bg = theme.ui.bg, fg = theme.syn.identifier },
                            }
                            return kanagawa
                        end,
                    },
                    sections = {
                        lualine_a = {
                            {
                                "mode",
                                fmt = function(mode)
                                    if mode:find("-") ~= nil then
                                        return mode
                                    else
                                        return mode:sub(1, 1)
                                    end
                                end,
                            },
                        },
                        lualine_b = bufname,
                        lualine_c = {
                            {
                                "diagnostics",
                            },
                            "require('lsp-progress').progress()",
                        },
                        lualine_x = { "searchcount" },
                        lualine_y = {
                            {
                                "diff",
                                source = function()
                                    local status = vim.b.gitsigns_status_dict
                                    if status ~= nil then
                                        return {
                                            added = status.add,
                                            modified = status.changed,
                                            removed = status.removed,
                                        }
                                    end
                                end,
                                symbols = { added = "󰐖 ", modified = "󰏬 ", removed = "󰍵 " },
                            },
                            {
                                "b:gitsigns_head",
                                icon = "",
                                cond = function()
                                    return not vim.startswith(vim.api.nvim_buf_get_name(0), "gitsigns://")
                                end,
                            },
                            "string.format(' %-2d', vim.fn.charcol('.'))",
                        },
                        lualine_z = { "encoding", "fileformat" },
                    },
                    inactive_sections = {
                        lualine_c = bufname,
                        lualine_x = {},
                    },
                }
                opts.inactive_winbar = opts.winbar
                return opts
            end,
        },
        {
            "linrongbin16/lsp-progress.nvim",
            config = function()
                require("lsp-progress").setup({
                    format = function(client_messages)
                        if #client_messages > 0 then
                            return table.concat(client_messages, " ")
                        end
                        local api = require("lsp-progress.api")
                        if #api.lsp_clients() > 0 then
                            local client_names = {}
                            for _, client in ipairs(api.lsp_clients()) do
                                if client.name == "amazonq" then
                                    table.insert(client_names, "Q")
                                elseif client.name == "amazonq-completion" then
                                    -- Skip
                                else
                                    table.insert(client_names, client.name)
                                end
                            end
                            table.sort(client_names)
                            return "  " .. table.concat(client_names, " ")
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
                    ["<leader>r"] = { "actions.refresh", mode = "n" },
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

                        vim.keymap.set("n", "gO", "<cmd>Trouble symbols<cr>", { buffer = args.buf })
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
            "akinsho/toggleterm.nvim",
            version = "*",
            keys = {
                { "<C-/>", '<cmd>exe v:count1 . "ToggleTerm"<cr>' },
            },
            opts = {
                open_mapping = "<C-/>",
                shading_factor = -20,
                auto_scroll = false,
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
            opts = {},
        },
        {
            name = "amazonq",
            url = "ssh://git.amazon.com/pkg/AmazonQNVim",
            enabled = function()
                return vim.loop.fs_stat(vim.fn.expand("~/.midway/cookie"))
            end,
            lazy = false,
            keys = {
                { "q:", "<cmd>call feedkeys(':AmazonQ ', 'tn')<cr>", mode = { "n", "v" } },
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
