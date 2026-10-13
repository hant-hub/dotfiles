local dir = debug.getinfo(1, "S").source:match("^@?(.*)/")
if dir then
	package.cpath = dir .. "/?.so;" .. package.cpath
end

local ok, ts = pcall(require, "ts")
if not ok then
	if vis then vis:info("vis-treesitter: native module not found") end
	return
end

if vis then vis.ts = ts end

local M = { ts = ts }

M.default_tags = {
	"whitespace",       "comment",          "string",
	"number",           "keyword",          "identifier",
	"operator",         "error",            "preprocessor",
	"constant",         "variable",         "function",
	"class",            "type",             "label",
	"regex",            "embedded",         "function.builtin",
	"constant.builtin", "function.method",  "tag",
	"attribute",        "variable.builtin", "heading",
	"bold",             "italic",           "underline",
	"code",             "link",             "reference",
	"annotation",       "list",
}

-- capture => tag mapping 
-- (this isnt the best way, but i guess the only 
-- available way without reworking vis's internals)

M.capture_to_tag = {}
M.aliases = {}

do
	local c = M.capture_to_tag

	local function set(tag, ...)
		for i = 1, select("#", ...) do c[select(i, ...)] = tag end
	end

	set("keyword",
        "keyword", "keyword.function", "keyword.return",
        "keyword.conditional", "keyword.repeat", "keyword.import",
        "keyword.exception", "keyword.modifier", "keyword.type",
        "keyword.coroutine", "keyword.storage.type",
        "keyword.control", "keyword.control.conditional",
        "keyword.control.repeat", "keyword.control.import",
        "type.qualifier")

	set("operator",
        "keyword.operator", "operator",
        "punctuation", "punctuation.bracket",
        "punctuation.delimiter", "punctuation.special",
        "tag.delimiter")

	set("preprocessor",
		"keyword.directive", "preprocessor", "define", "include")

	set("string",
        "string", "string.special", "character", "constant.character")

	set("comment",          "comment", "markup.quote")
	set("annotation",       "comment.documentation")
	set("number",           "number", "number.float", "constant.numeric")

	set("constant.builtin",
        "boolean", "character.special", "string.escape",
        "constant.builtin", "constant.builtin.boolean",
        "constant.character.escape")

	set("constant",         "constant", "constant.macro")

	set("function",
        "function", "function.call", "function.macro", "constructor")

	set("function.builtin", "function.builtin")
	set("function.method",  "function.method", "function.method.call")

	set("type",             "type", "type.builtin", "type.definition")
	set("class",            "class", "namespace", "module")

	set("variable",         "variable", "variable.parameter", "variable.member")
	set("variable.builtin", "variable.builtin")
	set("identifier",       "property")

	set("label",            "label")
	set("attribute",        "attribute", "tag.attribute")
	set("tag",              "tag")
	set("embedded",         "embedded")
	set("error",            "error")
	set("regex",            "string.regex")
	set("link",             "string.special.url", "markup.link", "markup.link.url")
	set("reference",        "markup.link.label")

	set("code",             "markup.raw", "markup.raw.block", "markup.raw.inline")
	set("italic",           "markup.italic")
	set("bold",             "markup.bold")
	set("underline",        "markup.underline")

	set("heading",
        "markup.heading", "markup.heading.marker",
        "markup.heading.1", "markup.heading.2", "markup.heading.3",
        "markup.heading.4", "markup.heading.5", "markup.heading.6")

	set("list",             "markup.list", "markup.list.checked", "markup.list.unchecked")
end


-- search paths, mix both local user-specifc paths (for user to compile his own)
-- and system global directory (for treesitters installed using package managers)

local grammar_paths = { "/usr/lib/tree-sitter/", "/usr/local/lib/tree-sitter/" }
local query_paths   = { "/usr/share/tree-sitter/queries/", "/usr/local/share/tree-sitter/queries/" }


do
	local home = os.getenv("HOME")
	if home then 
		table.insert(grammar_paths, 1, home .. "/.local/lib/tree-sitter/")
		table.insert(query_paths, 1, home .. "/.local/share/tree-sitter/queries/")
	end
end

local function ensure_ends_slash(p)
	return p:sub(-1) == "/" and p or p .. "/"
end

function M.add_grammar_path(p) table.insert(grammar_paths, 1, ensure_ends_slash(p)) end
function M.add_query_path(p)   table.insert(query_paths, 1, ensure_ends_slash(p))   end

local parsers, queries = {}, {}

function M.reset_caches() parsers, queries = {}, {} end

-- returns first hit for a given file
-- to look for in a set of paths
local function find_file(dirs, name)
	for _, d in ipairs(dirs) do
		local f = io.open(d .. name, "r")
		if f then f:close() return d .. name end
	end
end

function M.parser_for(lang)
	lang = M.aliases[lang] or lang
	if parsers[lang] ~= nil then return parsers[lang] or nil end

	local path = find_file(grammar_paths, lang .. ".so")
	if not path then parsers[lang] = false return nil end

	local load_ok, parser = pcall(ts.load, path, lang)
	if not load_ok or not parser or not parser.parse_string then
		parsers[lang] = false
		return nil
	end

	parsers[lang] = parser
	return parser
end

local function query_for(lang)
	lang = M.aliases[lang] or lang
	if queries[lang] ~= nil then return queries[lang] or nil end

	local path = find_file(query_paths, lang .. "/highlights.scm")
	local parser = M.parser_for(lang)
	if not path or not parser then queries[lang] = false return nil end

	local f   = io.open(path, "r")
	local src = f:read("*a")
	f:close()

	local qok, query = pcall(parser.query, parser, src)
	if not qok or not query then queries[lang] = false return nil end

	queries[lang] = query
	return query
end


-- takes a name to look for, like:
-- 'keyword.control.repeat' and a predicate function then,
-- it runs function on that value, if fn returns truthy val
-- it stops, and returns the used name at that point,
-- otherwise, it zooms out: chopping that last part of name,
-- and keeps trying until finding: a match OR nil
-- this is used to bridge the existing gap between:
-- treesitter's node labeling and vis'
local function walk_prefix(name, fn)
	local p = name
	while p do
		local result = fn(p)
		if result then return result end
		p = p:match("^(.+)%.[^.]+$")
	end
end

local function resolve_style(capture, tags)
	if capture:sub(1, 1) == "@" then capture = capture:sub(2) end
	tags = tags or M.default_tags
	if not tags then return nil end

	-- try direct match to vis' tags
	local id = walk_prefix(capture, function(prefix)
		for i, name in ipairs(tags) do
			if name == prefix then return i end
		end
	end)
	if id then return id end

	-- approximate using the translation table
	local tag_name = walk_prefix(capture, function(prefix)
		return M.capture_to_tag[prefix]
	end)
	if not tag_name then return nil end

	for i, name in ipairs(tags) do
		if name == tag_name then return i end
	end
end

-- NOTE: sole reason for this is because of treesitter's 
-- breaking API, nothing else to see here
local function node_bytes(node)
	if node.start_byte_offset then
		return node:start_byte_offset(), node:end_byte_offset()
	elseif node.start_byte then
		return node:start_byte(), node:end_byte()
	elseif node.start_index then
		return node:start_index() - 1, node:end_index()
	end
end

function M.highlight(win)
	local lang = win._ts_lang
	if not lang then return end

	local parser = M.parser_for(lang)
	local query  = query_for(lang)
	local vp     = win.viewport
	if not parser or not query or not vp or not vp.bytes then return end

	local horizon    = win.horizon or 32768 -- FIXME: is there a more incremental way than this?
	local vp_start   = vp.bytes.start
	local vp_end     = vp.bytes.finish
	local from       = math.max(0, vp_start - horizon)
	local to         = math.min(win.file.size, vp_end + horizon)

	local content = win.file:content(from, to - from)
	if not content or #content == 0 then return end

	local pok, tree = pcall(parser.parse_string, parser, content)
	if not pok or not tree then return end
	win._ts_tree = tree

	local root = tree:root()
	if not root then return end

	local tags = M.default_tags
	if vis and vis.lexers and vis.lexers.load then
		local lok, lexer = pcall(vis.lexers.load, win.syntax, nil, true)
		if lok and lexer and lexer._TAGS then tags = lexer._TAGS end
	end

	local cap_ok = pcall(function()
		for node, name in query:capture(root) do
			if not node or not name then goto next end

			local s, e = node_bytes(node)
			if not s then goto next end

			local abs_s = from + s
			local abs_e = from + e - 1

			if abs_e >= vp_start and abs_s <= vp_end then
				local style = resolve_style(name, tags)
				if style then win:style(style, abs_s, abs_e) end
			end

			::next::
		end
	end)

	if not cap_ok then win._ts_lang = nil end
end

function M.clear_cache(win)
	win._ts_tree = nil
end

if not vis then return M end

vis.treesitter = M

-- intercept lexer loader: prefers treesitter when BOTH grammar AND query exist
if vis.lexers and vis.lexers.load then
	local orig_load = vis.lexers.load -- keep vis' lexer as fallback here
	local stubs = {}

	vis.lexers.load = function(name, alt, cache)
		if name and M.parser_for(name) and query_for(name) then
			if not stubs[name] then
				local tags = {}
				for i, t in ipairs(M.default_tags) do tags[i] = t; tags[t] = i end
				-- return a dummy object lexer since vis require it, 
				-- even tho win.highlight is gonna do the job anyway
				stubs[name] = {
					_name  = name,
					_TAGS  = tags,
					-- XXX: for some reason vis needs at least one rule to not crash???
					_rules = { { "comment", "comment" }, comment = "comment" },
					lex    = function() return {} end,
				}
			end
			return stubs[name]
		end
		local lok, lex = pcall(orig_load, name, alt, cache) -- no ts, so use vis' default lexer
		return lok and lex or nil
	end
end

-- order is: syntax field (in 'win'), 
-- then filename (defined in 'ftdetect' tables),
-- then extension. and finally: just check if a parser exists for the extension
local function detect_lang(win)
	if win.syntax and M.parser_for(win.syntax) then
		return win.syntax
	end

	local file = win.file
	if not file or not file.name then return nil end
	local name = file.name:match("[^/]+$")
	if not name then return nil end

	local ft = vis.ftdetect
	if not ft then return nil end

	if ft.filenames and ft.filenames[name] then
		return ft.filenames[name]
	end

	local ext = name:match("%.([^.]+)$")
	if not ext then return nil end

	if ft.extensions and ft.extensions[ext] then
		return ft.extensions[ext]
	end

	return M.parser_for(ext) and ext or nil
end

local function map_tokens_to_styles(win)
	if not vis.lexers then return end
	for id, token in ipairs(M.default_tags) do
		local s = vis.lexers["STYLE_" .. token:upper():gsub("%.", "_")] or ""
		if type(s) == "table" then
			local parts = {}
			if s.attr then parts[#parts + 1] = tostring(s.attr) end
			if s.fore then parts[#parts + 1] = "fore:" .. tostring(s.fore) end
			if s.back then parts[#parts + 1] = "back:" .. tostring(s.back) end
			s = table.concat(parts, ",")
		end
		if s ~= "" then win:style_define(id, s) end
	end
end

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	local lang = detect_lang(win)
	if not lang or not M.parser_for(lang) then return end

	win._ts_lang = lang

	if not win.syntax then
		win.syntax = lang
		vis:info("")
		map_tokens_to_styles(win)
	end
end)

vis.events.subscribe(vis.events.WIN_HIGHLIGHT, function(win)
	if win._ts_lang then M.highlight(win) end
end)

return M
