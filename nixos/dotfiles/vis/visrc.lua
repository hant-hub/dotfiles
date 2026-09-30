require('vis')


vis.events.subscribe(vis.events.INIT, function()
	-- Your global configuration options
    vis:command("set theme dracula")
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	-- Your per window configuration options e.g.
    vis:command("set tabwidth 4")
    vis:command("set numbers true")
    vis:command("set autoindent true")
    vis:command("set showspaces false")
    vis:command("set showtabs false")
    vis:command("set expandtab off")
end)


local lsp = require('plugins/vis-lspc')

lsp.ls_map.lua = {
    name = 'lua-language-server',
    cmd = 'lua-language-server',
    settings = {
        Lua = {
            diagnostics = { globals = { 'vis' } },
            telemetry = { enable = false },
        },
    },
    formatting_options = {
        tabSize = 4,
        insertSpaces = false,
    },
}
