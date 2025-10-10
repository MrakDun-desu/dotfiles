-------------------------------- Basic options --------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.number = true
vim.o.mouse = "a"
vim.o.showmode = false

-- shedule after startup to not slow down editor
vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)

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

-------------------------------- Basic keymaps --------------------------------

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

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
    "nmac427/guess-indent.nvim",

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
                { "<leader>s", group = "[S]earch" },
                { "<leader>c", group = "[C]ode" },
                { "<leader>f", group = "[F]ile" },
                { "<leader>g", group = "[G]oto" },
                { "<leader>t", group = "[T]odo" },
                { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
            },
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

            vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
            vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
            vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
            vim.keymap.set(
                "n",
                "<leader>ss",
                builtin.builtin,
                { desc = "[S]earch [S]elect Telescope" }
            )
            vim.keymap.set(
                "n",
                "<leader>sw",
                builtin.grep_string,
                { desc = "[S]earch current [W]ord" }
            )
            vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
            vim.keymap.set(
                "n",
                "<leader>sd",
                builtin.diagnostics,
                { desc = "[S]earch [D]iagnostics" }
            )
            vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
            vim.keymap.set(
                "n",
                "<leader>s.",
                builtin.oldfiles,
                { desc = '[S]earch Recent Files ("." for repeat)' }
            )
            vim.keymap.set(
                "n",
                "<leader><leader>",
                builtin.buffers,
                { desc = "[ ] Find existing buffers" }
            )

            vim.keymap.set("n", "<leader>s/", function()
                builtin.live_grep({
                    grep_open_files = true,
                    prompt_title = "Live Grep in Open Files",
                })
            end, { desc = "[S]earch [/] in Open Files" })
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
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            { "j-hui/fidget.nvim", opts = {} },
            "hrsh7th/cmp-nvim-lsp",
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
                    format = function(diagnostic)
                        local diagnostic_message = {
                            [vim.diagnostic.severity.ERROR] = diagnostic.message,
                            [vim.diagnostic.severity.WARN] = diagnostic.message,
                            [vim.diagnostic.severity.INFO] = diagnostic.message,
                            [vim.diagnostic.severity.HINT] = diagnostic.message,
                        }
                        return diagnostic_message[diagnostic.severity]
                    end,
                },
            })

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend(
                "force",
                capabilities,
                require("cmp_nvim_lsp").default_capabilities()
            )

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
            }

            -- only ensure that lua LSP and formatter are installed, everything else can get
            -- installed manually when I need it
            require("mason-tool-installer").setup({ ensure_installed = { "lua_ls", "stylua" } })
            require("mason-lspconfig").setup({
                ensure_installed = {},
                automatic_installation = false,
                automatic_enable = true,
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        if server_name == "emmet_ls" then
                            require("lspconfig")[server_name].setup({
                                capabilities = capabilities,
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
                            })
                            return
                        end
                        server.capabilities = vim.tbl_deep_extend(
                            "force",
                            {},
                            capabilities,
                            server.capabilities or {}
                        )
                        require("lspconfig")[server_name].setup(server)
                    end,
                },
            })
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
            if vim.fn.executable("gleam") == 1 then
                require("lspconfig").gleam.setup({})
            end
            require("godotdev").setup({
                csharp = false,
            })
        end,
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
            },
        },
    },

    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                build = (function()
                    if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
                        return
                    end
                    return "make install_jsregexp"
                end)(),
                dependencies = {
                    {
                        "rafamadriz/friendly-snippets",
                        config = function()
                            require("luasnip.loaders.from_vscode").lazy_load()
                        end,
                    },
                },
            },
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "onsails/lspkind.nvim",
        },
        config = function()
            -- See `:help cmp`
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")
            luasnip.config.setup({})

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                completion = { completeopt = "menu,menuone,noinsert" },

                -- For an understanding of why these mappings were
                -- chosen, you will need to read `:help ins-completion`
                --
                -- No, but seriously. Please read `:help ins-completion`, it is really good!
                mapping = cmp.mapping.preset.insert({
                    -- Select the [n]ext item
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    -- Select the [p]revious item
                    ["<C-p>"] = cmp.mapping.select_prev_item(),

                    -- Scroll the documentation window [b]ack / [f]orward
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),

                    -- Accept ([y]es) the completion.
                    --  This will auto-import if your LSP supports it.
                    --  This will expand snippets if the LSP sent a snippet.
                    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping.confirm({ select = true }),

                    -- If you prefer more traditional completion keymaps,
                    -- you can uncomment the following lines
                    --['<CR>'] = cmp.mapping.confirm { select = true },
                    --['<Tab>'] = cmp.mapping.select_next_item(),
                    --['<S-Tab>'] = cmp.mapping.select_prev_item(),

                    -- Manually trigger a completion from nvim-cmp.
                    --  Generally you don't need this, because nvim-cmp will display
                    --  completions whenever it has completion options available.
                    ["<C-Space>"] = cmp.mapping.complete({}),

                    -- Think of <c-l> as moving to the right of your snippet expansion.
                    --  So if you have a snippet that's like:
                    --  function $name($args)
                    --    $body
                    --  end
                    --
                    -- <c-l> will move you to the right of each of the expansion locations.
                    -- <c-h> is similar, except moving you backwards.
                    ["<C-l>"] = cmp.mapping(function()
                        if luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        end
                    end, { "i", "s" }),
                    ["<C-h>"] = cmp.mapping(function()
                        if luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        end
                    end, { "i", "s" }),

                    -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
                    --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
                }),
                sources = {
                    {
                        name = "lazydev",
                        -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
                        group_index = 0,
                    },
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                    { name = "nvim_lsp_signature_help" },
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = lspkind.cmp_format({
                        mode = "symbol",
                        maxwidth = 50,
                        ellipsis_char = "…",
                        before = function(entry, vim_item)
                            vim_item.menu = ({
                                nvim_lsp = "[LSP]",
                                luasnip = "[Snippet]",
                                buffer = "[Buffer]",
                                path = "[Path]",
                            })[entry.source.name]
                            return vim_item
                        end,
                    }),
                },
            })
        end,
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
                lazygit = { enabled = true },
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
})
