local move_line = function(dir)
	return function()
		local line = vis.win.selection.line
		local file = vis.win.file
		local col = vis.win.selection.col

		local tmp = file.lines[line]
		file.lines[line] = file.lines[line + dir]
		file.lines[line + dir] = tmp

		vis.win.selection:to(line + dir, col)
	end
end


return { move_line = move_line }
