vim.g.mapleader = ' '

vim.g.c_syntax_for_h = true
vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.o.winborder = "rounded"

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

vim.keymap.set('t', "<Esc>", "<C-\\><C-n>")

vim.g.maplocalleader = ","

vim.pack.add({
    { src = 'https://github.com/stevearc/oil.nvim', },
    { src = 'https://github.com/echasnovski/mini.icons' },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = 'https://github.com/dasupradyumna/midnight.nvim' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = "https://github.com/lervag/vimtex" },
    { src = "https://github.com/saghen/blink.cmp" },
    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim.git" },
})

require("mini.icons").setup()
require('nvim-treesitter.configs').setup {
    ensure_installed = { "c", "lua", "vim", "vimdoc", "latex", "comment", "elixir", "heex", "javascript", "html" },
    ignore_install = {''},
    modules = {},
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        disable = {'latex'}
    },
    indent = { enable = true },
}

vim.g.vimtex_view_method = "zathura"

require('oil').setup {
    view_options = {
        show_hidden = true
    },
}

require("blink.cmp").setup {
    keymap = { 
        preset = 'default',
        ['<Tab>'] = {},
        ['<S-Tab>'] = {}
    },
    appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
    },

    -- (Default) Only show the documentation popup when manually triggered
    completion = { documentation = { auto_show = false } },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "lua" },
    snippets = { preset = 'luasnip' },
}

require("luasnip").setup{
    history = true,
    delete_check_events = "TextChanged",
    region_check_events = "CursorMoved",
}
require("luasnip.loaders.from_snipmate").lazy_load()


vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
            return
        end

        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
        --local opts = { noremap = true, silent = true }
    end,
})

vim.cmd("set completeopt+=noselect")
vim.cmd.colorscheme('midnight')

vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'none' })
vim.api.nvim_set_hl(0, 'signcolumn', { bg = 'none' })
vim.api.nvim_set_hl(0, 'tabline', { bg = 'none' })
vim.api.nvim_set_hl(0, 'statusline', { bg = 'none' })

vim.api.nvim_set_hl(0, "@comment.TODO", { fg = "#ff0000", bold = true })

local servers = {
    ["lua_ls"] = {
        settings = {
            Lua = {
                workspace = {
                    -- Make the server aware of Neovim runtime files and plugins
                    library = vim.api.nvim_list_runtime_paths(),
                    checkThirdParty = false,
                },
            }
        },
    },
    ["clangd"] = {},
    ["pyright"] = {},
    ["nixd"] = {},
}

for server_name, config in pairs(servers) do
    local capabilities = require('blink.cmp').get_lsp_capabilities(config)
    require('lspconfig')[server_name].setup(capabilities)
    vim.lsp.enable(server_name)
end


vim.keymap.set("n", "<leader>pv", vim.cmd.Oil)
vim.keymap.set('n', "<leader>lf", vim.lsp.buf.format)

vim.keymap.set("n", "<leader>pf", ":Pick files<CR>")
vim.keymap.set("n", "<leader>h", ":Pick help<CR>")

vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y<CR>')
vim.keymap.set({ "n", "v", "x" }, "<leader>d", '"+d<CR>')

vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump {
        count = 1,
        float = true,
    }
end)
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump {
        count = -1,
        float = true,
    }
end)

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)


