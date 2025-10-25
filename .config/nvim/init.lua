-------------------------------- Basic options --------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.number = true
vim.o.mouse = "a"
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "nosplit"
vim.o.cursorline = true
vim.o.scrolloff = 20
vim.o.confirm = true
vim.o.winborder = "rounded"

-- shedule after startup to not slow down editor
vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)

-------------------------------- Basic keymaps --------------------------------

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>fc", ":e ~/.config/nvim/init.lua<CR>", { desc = "Open nvim config" })

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

------------------------------- Package manager -------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end

--@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require("lazy").setup({
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
        },
    },

    {
        "folke/which-key.nvim",
        event = "VimEnter",
        opts = {
            preset = "helix",
            mappings = true,
            spec = {
                { "<leader>c", group = "[C]ode" },
                { "<leader>d", group = "[D]AP" },
                { "<leader>s", group = "[S]earch" },
                { "<leader>f", group = "[F]ile" },
                { "<leader>l", group = "[L]azygit" },
            },
        },
    },

    {
        "kdheepak/lazygit.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
        lazy = true,
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        config = function()
            require("telescope").load_extension("lazygit")
        end,
        keys = {
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
            { "<leader>lc", "<cmd>LazyGitConfig<cr>", desc = "LazyGit config" },
            { "<leader>lf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit current file" },
        },
    },

    {
        "nvim-telescope/telescope.nvim",
        event = "VimEnter",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "nvim-tree/nvim-web-devicons",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
        },
        config = function()
            require("telescope").setup({
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown(),
                    },
                },
            })

            pcall(require("telescope").load_extension, "fzf")
            pcall(require("telescope").load_extension, "ui-select")

            local builtin = require("telescope.builtin")

            local function set_keymap(binding, func, desc)
                vim.keymap.set("n", "<leader>" .. binding, func, { desc = desc })
            end
            set_keymap("sh", builtin.help_tags, "[S]earch [H]elp")
            set_keymap("sk", builtin.keymaps, "[S]earch [K]eymaps")
            set_keymap("sf", builtin.find_files, "[S]earch [F]iles")
            set_keymap("ss", builtin.builtin, "[S]earch [S]elect Telescope")
            set_keymap("sw", builtin.grep_string, "[S]earch current [W]ord")
            set_keymap("sg", builtin.live_grep, "[S]earch by [G]rep")
            set_keymap("sd", builtin.diagnostics, "[S]earch [D]iagnostics")
            set_keymap("sr", builtin.resume, "[S]earch [R]esume")
            set_keymap("s.", builtin.oldfiles, '[S]earch Recent Files ("." for repeat)')
            set_keymap("<leader>", builtin.buffers, "[ ] Find existing buffers")
            set_keymap("s/", function()
                builtin.live_grep({
                    grep_open_files = true,
                    prompt_title = "Live Grep in Open Files",
                })
            end, "[S]earch [/] in Open Files")
        end,
    },

    --------------------------------- LSP plugins ---------------------------------

    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "mason-org/mason-lspconfig.nvim",
            { "j-hui/fidget.nvim", opts = {} },
            "saghen/blink.cmp",
        },
        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc, mode)
                        mode = mode or "n"
                        vim.keymap.set(
                            mode,
                            keys,
                            func,
                            { buffer = event.buf, desc = "LSP: " .. desc }
                        )
                    end

                    local tel_builtin = require("telescope.builtin")
                    map("<leader>cr", vim.lsp.buf.rename, "[R]ename")
                    map("<leader>cgD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
                    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
                    map("<leader>cs", tel_builtin.lsp_document_symbols, "[C]ode [S]ymbols")
                    map("gr", tel_builtin.lsp_references, "[G]oto [R]eferences")
                    map("gi", tel_builtin.lsp_implementations, "[G]oto [I]mplementation")
                    map("gd", tel_builtin.lsp_definitions, "[G]oto [D]efinition")
                    map("gt", tel_builtin.lsp_type_definitions, "[G]oto [T]ype Definition")
                    map("gw", tel_builtin.lsp_dynamic_workspace_symbols, "[W]orkspace Symbols")

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if
                        client
                        and client:supports_method(
                            vim.lsp.protocol.Methods.textDocument_documentHighlight,
                            event.buf
                        )
                    then
                        local highlight_group =
                            vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = event.buf,
                            group = highlight_group,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = event.buf,
                            group = highlight_group,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd("LspDetach", {
                            group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds({
                                    group = "lsp-highlight",
                                    buffer = event2.buf,
                                })
                            end,
                        })
                    end

                    if
                        client
                        and (
                            client:supports_method(
                                vim.lsp.protocol.Methods.textDocument_inlayHint,
                                event.buf
                            )
                            or client.name == "omnisharp"
                        )
                    then
                        map("<leader>ch", function()
                            vim.lsp.inlay_hint.enable(
                                not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
                            )
                        end, "Toggle Inlay [H]ints")
                    end
                end,
            })

            vim.diagnostic.config({
                severity_sort = true,
                float = { border = "rounded", source = "if_many" },
                underline = { severity = vim.diagnostic.severity.ERROR },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "󰅚 ",
                        [vim.diagnostic.severity.WARN] = "󰀪 ",
                        [vim.diagnostic.severity.INFO] = "󰋽 ",
                        [vim.diagnostic.severity.HINT] = "󰌶 ",
                    },
                },
                virtual_text = {
                    source = "if_many",
                    spacing = 2,
                    -- format = function(diagnostic)
                    --     local diagnostic_message = {
                    --         [vim.diagnostic.severity.ERROR] = diagnostic.message,
                    --         [vim.diagnostic.severity.WARN] = diagnostic.message,
                    --         [vim.diagnostic.severity.INFO] = diagnostic.message,
                    --         [vim.diagnostic.severity.HINT] = diagnostic.message,
                    --     }
                    --     return diagnostic.message
                    -- end,
                },
            })

            local capabilities = require("blink.cmp").get_lsp_capabilities()

            -- if I want to override individual server settings, do it here
            local servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                },
                emmet_ls = {
                    filetypes = {
                        "css",
                        "html",
                        "javascriptreact",
                        "typescriptreact",
                    },
                    init_options = {
                        html = {
                            options = {
                                ["bem_enabled"] = true,
                            },
                        },
                    },
                },
            }

            -- only ensure that lua LSP and formatter are installed, everything else can get
            -- installed manually when I need it
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "stylua" },
                automatic_installation = false,
                automatic_enable = true,
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        server.capabilities = vim.tbl_deep_extend(
                            "force",
                            {},
                            capabilities,
                            server.capabilities or {}
                        )
                        vim.lsp.config(server_name, server)
                        vim.lsp.enable({ server_name })
                    end,
                },
            })
            if vim.fn.executable("gleam") == 1 then
                vim.lsp.enable("gleam")
            end
        end,
    },

    {
        "Mathijs-Bakker/godotdev.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "mfussenegger/nvim-dap",
            {
                "rcarriga/nvim-dap-ui",
                dependencies = { "nvim-neotest/nvim-nio" },
            },
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("godotdev").setup({
                csharp = false,
            })
        end,
    },

    {
        "saghen/blink.cmp",
        event = "VimEnter",
        version = "1.*",
        dependencies = {
            "folke/lazydev.nvim",
        },
        --- @module 'blink.cmp'
        --- @type blink.cmp.Config
        opts = {
            keymap = {
                preset = "default",
            },
            appearance = {
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "normal",
            },
            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 500 },
            },
            sources = {
                default = { "lsp", "path", "snippets", "lazydev" },
                providers = {
                    lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
                },
            },
            snippets = { preset = "default" },
            fuzzy = { implementation = "prefer_rust_with_warning" },
            signature = { enabled = true },
        },
    },

    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>cf",
                function()
                    require("conform").format({ async = true, lsp_format = "fallback" })
                end,
                mode = "",
                desc = "[F]ormat",
            },
        },
        opts = {
            notify_on_error = true,
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "fallback",
            },
            -- formatter configuration for filetype
            formatters_by_ft = {
                lua = { "stylua" },
                css = { "prettierd" },
                html = { "prettierd" },
                javascriptreact = { "prettierd" },
                typescriptreact = { "prettierd" },
                typst = { "typstyle" },
                markdown = { "prettierd" },
            },
        },
    },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "mocha",
        },
        config = function()
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    {
        "folke/todo-comments.nvim",
        event = "VimEnter",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = { signs = false },
    },

    {
        "echasnovski/mini.nvim",
        config = function()
            require("mini.ai").setup({ n_lines = 500 })
            require("mini.surround").setup()
            require("mini.move").setup()
            require("mini.notify").setup()
            require("mini.pairs").setup()

            require("mini.files").setup({
                mappings = {
                    go_in_plus = "<Enter>",
                },
                windows = {
                    preview = true,
                    width_preview = 50,
                },
            })
            vim.keymap.set("n", "<leader>e", MiniFiles.open, { desc = "Open files" })

            local statusline = require("mini.statusline")
            statusline.setup({ use_icons = true })
            ---@diagnostic disable-next-line: duplicate-set-field
            statusline.section_location = function()
                return "%2l:%-2v"
            end
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        opts = {
            auto_install = true,
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            },
        },
    },

    {
        "folke/trouble.nvim",
        opts = {},
        cmd = "Trouble",
        keys = {
            {
                "<leader>cX",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>cx",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cq",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    },

    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        config = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesActionRename",
                callback = function(event)
                    Snacks.rename.on_rename_file(event.data.from, event.data.to)
                end,
            })
            vim.keymap.set("n", "<leader>ft", Snacks.terminal.toggle, { desc = "Open terminal" })
            Snacks.setup({
                animate = { enabled = true },
                rename = { enabled = true },
                terminal = { enabled = true },
                bigfile = { enabled = true },
            })
        end,
    },

    {
        "windwp/nvim-ts-autotag",
        dependencies = "nvim-treesitter/nvim-treesitter",
        opts = {},
    },

    {
        "chomosuke/typst-preview.nvim",
        lazy = false,
        version = "1.*",
        opts = {
            dependencies_bin = {
                ["tinymist"] = "tinymist",
            },
        },
        cmd = {
            "TypstPreviewToggle",
            "TypstPreviewFollowCursorToggle",
        },
    },
})
