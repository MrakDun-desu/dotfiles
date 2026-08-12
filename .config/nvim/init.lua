-------------------------------- Basic options --------------------------------

vim.loader.enable()

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
vim.o.cursorline = true
vim.o.scrolloff = 15
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

vim.keymap.set("n", "<leader>fc", ":e ~/.config/nvim/init.lua<CR>", { desc = "Open [C]onfig" })

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- diagnostics
vim.diagnostic.config({
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
    underline = { severity = vim.diagnostic.severity.WARN },
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
    },
    jump = { float = true },
})

------------------------------- Package manager -------------------------------
do
    -- [[ Intro to `vim.pack` ]]
    -- `vim.pack` is a new plugin manager built into Neovim,
    --  which provides a Lua interface for installing and managing plugins.
    --
    --  See `:help vim.pack`, `:help vim.pack-examples` or the
    --  excellent blog post from the creator of vim.pack and mini.nvim:
    --  https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
    --
    --  To inspect plugin state and pending updates, run
    --    :lua vim.pack.update(nil, { offline = true })
    --
    --  To update plugins, run
    --    :lua vim.pack.update()

    local function run_build(name, cmd, cwd)
        local result = vim.system(cmd, { cwd = cwd }):wait()
        if result.code ~= 0 then
            local stderr = result.stderr or ""
            local stdout = result.stdout or ""
            local output = stderr ~= "" and stderr or stdout
            if output == "" then
                output = "No output from build command."
            end
            vim.notify(("Build failed for %s:\n%s"):format(name, output), vim.log.levels.ERROR)
        end
    end

    -- This autocommand runs after a plugin is installed or updated and
    --  runs the appropriate build command for that plugin if necessary.
    --
    -- See `:help vim.pack-events`
    vim.api.nvim_create_autocmd("PackChanged", {
        callback = function(ev)
            local name = ev.data.spec.name
            local kind = ev.data.kind
            if kind ~= "install" and kind ~= "update" then
                return
            end

            if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
                run_build(name, { "make" }, ev.data.path)
                return
            end

            if name == "LuaSnip" then
                if vim.fn.has("win32") ~= 1 and vim.fn.executable("make") == 1 then
                    run_build(name, { "make", "install_jsregexp" }, ev.data.path)
                end
                return
            end

            if name == "nvim-treesitter" then
                if not ev.data.active then
                    vim.cmd.packadd("nvim-treesitter")
                end
                vim.cmd("TSUpdate")
                return
            end
        end,
    })
end

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo)
    return "https://github.com/" .. repo
end

local function set_keymap(binding, func, desc)
    vim.keymap.set("n", "<leader>" .. binding, func, { desc = desc })
end

do
    vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
    require("gitsigns").setup({
        signs = {
            add = { text = "+" }, ---@diagnostic disable-line: missing-fields
            change = { text = "~" }, ---@diagnostic disable-line: missing-fields
            delete = { text = "_" }, ---@diagnostic disable-line: missing-fields
            topdelete = { text = "‾" }, ---@diagnostic disable-line: missing-fields
            changedelete = { text = "~" }, ---@diagnostic disable-line: missing-fields
        },
    })

    vim.pack.add({ gh("catppuccin/nvim") })
    require("catppuccin").setup({
        flavour = "mocha",
    })
    vim.cmd.colorscheme("catppuccin")

    vim.pack.add({ gh("folke/which-key.nvim") })
    require("which-key").setup({
        -- Delay between pressing a key and opening which-key (milliseconds)
        delay = 0,
        preset = "helix",
        icons = { mappings = true },
        -- Document existing key chains
        spec = {
            { "<leader>c", group = "[C]ode", mode = { "n", "v" } },
            { "<leader>s", group = "[S]earch", mode = { "n", "v" } },
            { "<leader>t", group = "[T]oggle" },
            { "<leader>f", group = "[F]iles" },
            { "<leader>l", group = "[L]azygit", mode = { "n", "v" } },
        },
    })

    vim.pack.add({ gh("folke/todo-comments.nvim") })
    require("todo-comments").setup({ signs = false })

    vim.pack.add({ gh("nvim-mini/mini.nvim") })
    require("mini.icons").setup()
    MiniIcons.mock_nvim_web_devicons()

    require("mini.notify").setup()
    require("mini.pairs").setup()
    require("mini.ai").setup({
        mappings = {
            around_next = "aa",
            inside_next = "ii",
        },
        n_lines = 500,
    })

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require("mini.surround").setup()

    require("mini.files").setup({
        mappings = {
            go_in_plus = "<Enter>",
        },
        windows = {
            preview = true,
            width_preview = 80,
        },
    })
    vim.keymap.set("n", "<leader>fe", require("mini.files").open, { desc = "[F]ile [E]xplorer" })

    local statusline = require("mini.statusline")
    statusline.setup({ use_icons = true })
end

do
    ---@type (string|vim.pack.Spec)[]
    local telescope_plugins = {
        gh("nvim-lua/plenary.nvim"),
        gh("nvim-telescope/telescope.nvim"),
        gh("nvim-telescope/telescope-ui-select.nvim"),
    }
    if vim.fn.executable("make") == 1 then
        table.insert(telescope_plugins, gh("nvim-telescope/telescope-fzf-native.nvim"))
    end

    -- NOTE: You can install multiple plugins at once
    vim.pack.add(telescope_plugins)

    require("telescope").setup({
        extensions = {
            ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
    })

    -- Enable Telescope extensions if they are installed
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")

    -- See `:help telescope.builtin`
    local builtin = require("telescope.builtin")

    set_keymap("sh", builtin.help_tags, "[S]earch [H]elp")
    set_keymap("sk", builtin.keymaps, "[S]earch [K]eymaps")
    set_keymap("sf", builtin.find_files, "[S]earch [F]iles")
    set_keymap("ss", builtin.builtin, "[S]earch [S]elect Telescope")
    set_keymap("sg", builtin.live_grep, "[S]earch by [G]rep")
    set_keymap("sd", builtin.diagnostics, "[S]earch [D]iagnostics")
    set_keymap("sr", builtin.resume, "[S]earch [R]esume")
    set_keymap("sc", builtin.commands, "[S]earch [C]ommands")
    set_keymap("s.", builtin.oldfiles, '[S]earch Recent Files ("." for repeat)')
    set_keymap("<leader>", builtin.buffers, "[ ] Find existing buffers")
    vim.keymap.set(
        { "n", "v" },
        "<leader>sw",
        builtin.grep_string,
        { desc = "[S]earch current [W]ord" }
    )

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
        callback = function(event)
            local buf = event.buf

            vim.keymap.set(
                "n",
                "gr",
                builtin.lsp_references,
                { buffer = buf, desc = "[G]oto [R]eferences" }
            )

            vim.keymap.set(
                "n",
                "gi",
                builtin.lsp_implementations,
                { buffer = buf, desc = "[G]oto [I]mplementation" }
            )

            vim.keymap.set(
                "n",
                "gd",
                builtin.lsp_definitions,
                { buffer = buf, desc = "[G]oto [D]efinition" }
            )

            vim.keymap.set(
                "n",
                "gt",
                builtin.lsp_type_definitions,
                { buffer = buf, desc = "[G]oto [T]ype Definition" }
            )

            vim.keymap.set(
                "n",
                "<leader>cs",
                builtin.lsp_document_symbols,
                { buffer = buf, desc = "[C]ode [S]ymbols" }
            )

            vim.keymap.set(
                "n",
                "<leader>cw",
                builtin.lsp_dynamic_workspace_symbols,
                { buffer = buf, desc = "[C]ode [W]orkspace Symbols" }
            )
        end,
    })

    -- Override default behavior and theme when searching
    vim.keymap.set("n", "<leader>/", function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
        }))
    end, { desc = "[/] Fuzzily search in current buffer" })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
            grep_open_files = true,
            prompt_title = "Live Grep in Open Files",
        })
    end, { desc = "[S]earch [/] in Open Files" })
end

do
    vim.pack.add({ gh("j-hui/fidget.nvim") })
    require("fidget").setup({})

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
            local map = function(keys, func, desc, mode)
                mode = mode or "n"
                vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
            end

            map("<leader>cr", vim.lsp.buf.rename, "[R]ename")
            map("<leader>ca", vim.lsp.buf.code_action, "Code [A]ction", { "n", "x" })
            map("<leader>cgD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client:supports_method("textDocument/documentHighlight", event.buf) then
                local highlight_augroup =
                    vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
                vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                    buffer = event.buf,
                    group = highlight_augroup,
                    callback = vim.lsp.buf.document_highlight,
                })

                vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                    buffer = event.buf,
                    group = highlight_augroup,
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

            if client and client:supports_method("textDocument/inlayHint", event.buf) then
                map("<leader>th", function()
                    vim.lsp.inlay_hint.enable(
                        not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
                    )
                end, "[T]oggle Inlay [H]ints")
            end
        end,
    })

    ---@type table<string, vim.lsp.Config>
    local servers = {
        stylua = {},

        lua_ls = {
            on_init = function(client)
                client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

                if client.workspace_folders then
                    local path = client.workspace_folders[1].name
                    if
                        path ~= vim.fn.stdpath("config")
                        and (
                            vim.uv.fs_stat(path .. "/.luarc.json")
                            or vim.uv.fs_stat(path .. "/.luarc.jsonc")
                        )
                    then
                        return
                    end
                end

                local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
                client.config.settings.Lua = vim.tbl_deep_extend("force", current_settings.Lua, {
                    runtime = {
                        version = "LuaJIT",
                        path = { "lua/?.lua", "lua/?/init.lua" },
                    },
                    workspace = {
                        checkThirdParty = false,
                        -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
                        --  See https://github.com/neovim/nvim-lspconfig/issues/3189
                        library = vim.api.nvim_get_runtime_file("", true),
                    },
                })
            end,
            ---@type lspconfig.settings.lua_ls
            settings = {
                Lua = {
                    format = { enable = false }, -- Disable formatting (formatting is done by stylua)
                    runtime = {
                        version = "LuaJIT",
                        path = { "lua/?.lua", "lua/?/init.lua" },
                    },
                    workspace = {
                        checkThirdParty = false,
                        library = vim.list_extend(vim.api.nvim_get_runtime_file("", true), {
                            "${3rd}/luv/library",
                            "${3rd}/busted/library",
                        }),
                    },
                    diagnostics = {
                        globals = { "vim" },
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
                "svelte",
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

    vim.pack.add({
        gh("neovim/nvim-lspconfig"),
        gh("mason-org/mason.nvim"),
        gh("mason-org/mason-lspconfig.nvim"),
        gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
    })

    -- Automatically install LSPs and related tools to stdpath for Neovim
    require("mason").setup({})

    -- Translates between nvim-lspconfig server names and mason.nvim package names (e.g. lua_ls <-> lua-language-server)
    require("mason-lspconfig").setup({
        automatic_enable = false,
    })

    local ensure_installed = vim.tbl_keys(servers or {})

    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

    for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
    end

    vim.pack.add({ gh("kdheepak/lazygit.nvim") })
    require("telescope").load_extension("lazygit")

    vim.pack.add({ gh("folke/trouble.nvim") })
    require("trouble").setup({})
    set_keymap("cX", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics (Trouble)")
    set_keymap(
        "cx",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        "Buffer Diagnostics (Trouble)"
    )
    set_keymap("cq", "Trouble qflist toggle<cr>", "Quickfix List (Trouble)")
end

do
    -- [[ Formatting ]]
    vim.pack.add({ gh("stevearc/conform.nvim") })
    require("conform").setup({
        notify_on_error = true,
        format_on_save = function(bufnr)
            local enabled_filetypes = {
                lua = true,
            }
            if enabled_filetypes[vim.bo[bufnr].filetype] then
                return { timeout_ms = 500 }
            else
                return nil
            end
        end,
        default_format_opts = {
            lsp_format = "fallback",
        },
        formatters_by_ft = {
            css = { "prettierd" },
            html = { "prettierd" },
            javascriptreact = { "prettierd" },
            typescriptreact = { "prettierd" },
            typst = { "typstyle" },
            markdown = { "prettierd" },
            json = { "biome" },
        },
    })

    vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        require("conform").format({ async = true })
    end, { desc = "[C]ode [F]ormat" })
end

do
    vim.pack.add({ { src = gh("L3MON4D3/LuaSnip"), version = vim.version.range("2.*") } })
    require("luasnip").setup({})

    vim.pack.add({ { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") } })
    require("blink.cmp").setup({
        keymap = {
            preset = "super-tab",
        },
        appearance = {
            nerd_font_variant = "normal",
        },
        completion = {
            documentation = { auto_show = true, auto_show_delay_ms = 500 },
        },
        sources = {
            default = { "lsp", "path", "snippets" },
        },
        snippets = { preset = "luasnip" },
        fuzzy = { implementation = "prefer_rust" },
        signature = { enabled = true },
    })
end

do
    vim.pack.add({ { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" } })

    local parsers = {
        "bash",
        "c",
        "diff",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "vim",
        "vimdoc",
    }
    require("nvim-treesitter").install(parsers)

    ---@param buf integer
    ---@param language string
    local function treesitter_try_attach(buf, language)
        if not vim.treesitter.language.add(language) then
            return
        end
        vim.treesitter.start(buf, language)

        local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

        if has_indent_query then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end

    local available_parsers = require("nvim-treesitter").get_available()
    vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
            local buf, filetype = args.buf, args.match

            local language = vim.treesitter.language.get_lang(filetype)
            if not language then
                return
            end

            local installed_parsers = require("nvim-treesitter").get_installed("parsers")

            if vim.tbl_contains(installed_parsers, language) then
                -- Enable the parser if it is already installed
                treesitter_try_attach(buf, language)
            elseif vim.tbl_contains(available_parsers, language) then
                -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
                require("nvim-treesitter").install(language):await(function()
                    treesitter_try_attach(buf, language)
                end)
            else
                -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
                treesitter_try_attach(buf, language)
            end
        end,
    })
end
