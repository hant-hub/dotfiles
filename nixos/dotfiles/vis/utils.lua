require("vis")


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

module = {}
module.fzf_path = "fzf"
module.fzf_args = ""

vis:command_register("fzf", function(argv, force, win, selection, range)
    local command = module.fzf_path .. " " .. module.fzf_args .. " " .. table.concat(argv, " ")

    local file = io.popen(command)


    if file == nil then
        vis:info("Failed to open fzf command")
        return false;
    end

    local output = file:read()
    local success, msg, status = file:close()

    if status == 0 then
        -- vis:command(string.format("e '%s'", output))
        vis:feedkeys(string.format(":e '%s'", output))
    elseif status == 1 then
        vis:info(string.format("fzf-open: No match. Command %s exited with return value %i." , command, status))
    elseif status == 2 then
        vis:info(string.format("fzf-open: Error. Command %s exited with return value %i." , command, status))
    elseif status == 130 then
        vis:info(string.format("fzf-open: Interrupted. Command %s exited with return value %i" , command, status))
    else
        vis:info(string.format("fzf-open: Unknown exit status %i. command %s exited with return value %i" , status, command, status, status))
    end

    vis:feedkeys("<vis-redraw>")

    return true;
end)

return { move_line = move_line }
