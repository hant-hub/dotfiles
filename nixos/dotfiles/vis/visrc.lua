require('vis')


vis.events.subscribe(vis.events.INIT, function()
	-- Your global configuration options
    vis:command("set theme dracula")
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	-- Your per window configuration options e.g.
    vis:command("set tabwidth 4")
    vis:command("set numbers true")
end)
