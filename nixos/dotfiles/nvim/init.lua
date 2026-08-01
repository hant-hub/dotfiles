vim.g.mapleader = ' '

vim.g.c_syntax_for_h = true

--vim.g.terminal_emulator='zsh'
vim.opt.shell = 'zsh'
--vim.env.shell = 'zsh'

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
    { src = "https://github.com/lervag/vimtex" },
    { src = "https://github.com/neovim/nvim-lspconfig.git" },
    { src = 'https://github.com/saghen/blink.lib' },
    { src = "https://github.com/saghen/blink.cmp" },
    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim.git" },
    { src = "https://github.com/tpope/vim-fugitive" },
    { src = "https://github.com/nvim-lua/plenary.nvim.git" },
    { src = "https://github.com/ej-shafran/compile-mode.nvim.git" },
    { src = "https://github.com/m00qek/baleia.nvim.git" },
})

vim.g.baleia = require("baleia").setup {}

require("mini.icons").setup()
require('nvim-treesitter').setup {}

require('nvim-treesitter').install {
    "c", "lua", "vim", "nix",
    "vimdoc", "latex", "comment",
    "elixir", "heex", "javascript",
    "html", "python" }

vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function()
        pcall(function() vim.treesitter.start() end)
    end

})


vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_latexmk = {
         ['executable'] = 'latexmk',
         ['options'] = {
           '-xelatex',
           '-file-line-error',
           '-synctex=1',
           '-interaction=nonstopmode',
         },
        }

require('oil').setup {
    view_options = {
        show_hidden = true
    },
}


local cmp = require("blink.cmp")
cmp.build():pwait()
cmp.setup {
    keymap = {
        preset = 'default',
        ['<Tab>'] = {},
        ['<S-Tab>'] = {}
    },

    enabled = true,

    -- (Default) Only show the documentation popup when manually triggered
    completion = { },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    snippets = { preset = 'luasnip' },
}

require("luasnip").setup {
    history = true,
    delete_check_events = "TextChanged",
    region_check_events = "CursorMoved",
}
require("luasnip.loaders.from_snipmate").lazy_load()

vim.g.compile_mode = {
    focus_compilation_buffer = true,
    baleia_setup = true,
}

vim.keymap.set("n", "<leader>c", ':below Compile ')
vim.keymap.set("n", "<leader>cc", ':below Recompile<CR>')

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
            return
        end

        if client:supports_method('textDocument/completion') then
            --vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
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
                    library = { vim.env.VIMRUNTIME },
                    checkThirdParty = false,
                },
            }
        }
    },
    ["clangd"] = {
        cmd = {
            "clangd",
            "--header-insertion=never",
        }
    },
    ["glslls"] = {},
    ["hls"] = {},
    ["pyright"] = {},
    ["nixd"] = {
        nixpkgs = {
            expr = "import <nixpkgs> {}",
        },
    },
    ["ts_ls"] = {},
    ["qmlls"] = {
        root_markers = { ".", ".git", ".qmlls.ini" },
        filetypes = { 'qml' },
    },
}

for server_name, config in pairs(servers) do
    local capabilities = require('blink.cmp').get_lsp_capabilities(config)
    config.capabilities = capabilities
    vim.lsp.config(server_name, config)
    vim.lsp.enable(server_name)
end


vim.keymap.set("n", "<leader>pv", vim.cmd.Oil)
vim.keymap.set('n', "<leader>lf", vim.lsp.buf.format)

vim.keymap.set("n", "<leader>pf", ":Pick files<CR>")
vim.keymap.set("n", "<leader>h", ":Pick help<CR>")

vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y<CR>')
vim.keymap.set({ "n", "v", "x" }, "<leader>d", '"+d<CR>')

local prev_buf = false
local function on_jump(diagnostic, bufnr)
    if not diagnostic then return end
    if prev_buf then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= "" then
                vim.api.nvim_win_close(win, false)
            end
        end
        prev_buf = false
    end
    local _, result = vim.diagnostic.open_float {
        bufnr = bufnr,
        pos = diagnostic.lnum,
    }

    if result then
        prev_buf = true
    end
end

vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump {
        count = 1,
        on_jump = on_jump
    }
end)

vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump {
        count = -1,
        on_jump = on_jump
    }
end)

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
