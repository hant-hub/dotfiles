require('vis')
local util = require('utils')


vis.events.subscribe(vis.events.INIT, function()
	-- Your global configuration options
    vis:command("set theme dracula")
    vis:map(vis.modes.NORMAL, "<C-h>", "<C-w>h")
    vis:map(vis.modes.NORMAL, "<C-j>", "<C-w>j")
    vis:map(vis.modes.NORMAL, "<C-k>", "<C-w>k")
    vis:map(vis.modes.NORMAL, "<C-l>", "<C-w>l")

	vis:map(vis.modes.NORMAL, " pf", ":fzf")

	vis:map(vis.modes.VISUAL_LINE, "J", util.move_line(1))
	vis:map(vis.modes.VISUAL_LINE, "K", util.move_line(-1))

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
    Lua = {diagnostics = {globals = {'vis'}}, telemetry = {enable = false}},
  },
  formatting_options = {tabSize = 2, insertSpaces = true},
};


local ts = require('plugins/vis-treesitter')
