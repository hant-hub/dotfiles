# vis-treesitter

A standalone tree-sitter plugin for [vis](https://github.com/martanne/vis).
This little plugin brings the tree-sitter integration out of vis's core so that you can install it as a standard plugin, remaining compatible with older or baseline `vis` installations.

## Installation

1. Clone this repository into your vis plugins directory (`~/.config/vis/plugins/vis-treesitter`).

2. Figure out which Lua version your `vis` is linked against, using your platform's dynamic linker tools (`ldd`, `otool`, etc.), or if vis is statically linked, add `vis:info(_VERSION)` to your `visrc.lua` temporarily and check the status bar.
3. Make sure you have [`tree-sitter`](https://repology.org/project/tree-sitter/versions) and the **matching** [`lua`](https://repology.org/project/lua/versions) development headers installed on your system.
   For example, if vis is linked against Lua 5.3:
```sh
   # Arch, btw
   pacman -S lua53
```
4. Build the native module, passing your Lua version:
```sh
   cd ~/.config/vis/plugins/vis-treesitter
   chmod +x build && LUA_VERSION=5.3 ./build
```
5. Load the plugin in your `visrc.lua`:
```lua
   require('plugins/vis-treesitter')
```

## Usage

For this plugin to work for a certain language, you need two things:
- Tree sitter query files (.scm)
- Compiled grammar (`.so`, usually compiled using **PIC support** like: `gcc -shared -fPIC -Isrc src/parser.c src/scanner.c -o zig.so`)

These are usually provided by your package managers under one package, so you can use your OS package manager as following:
```sh
sudo pacman -S tree-sitter-c tree-sitter-python
```
Once installed, `vis-treesitter` will automatically detect the parser in `/usr/lib/` and its `highlights.scm` query file in `/usr/share/tree-sitter/queries/`.

For a language that's not in your package manager scope, you can manually put it's compiled `<LANG>.so` under one of the following directories:
+ `~/.local/lib/tree-sitter/`
+ `/usr/lib/tree-sitter/`
+ `/usr/local/lib/tree-sitter/`

and it's `.scm` file under:
+ `~/.local/share/tree-sitter/queries/<LANG>/highlights.scm`
+ `/usr/share/tree-sitter/queries/<LANG>/highlights.scm`
+ `/usr/local/share/tree-sitter/queries/<LANG>/highlights.scm`

### Example of adding missing languages

As we said before, if your package manager does not provide a specific language, you can easily build and install it yourself. 

For example, here's how you would go around adding [Zig](https://github.com/tree-sitter-grammars/tree-sitter-zig):

```sh
# clone the grammar repo
git clone --depth 1 https://github.com/tree-sitter-grammars/tree-sitter-zig
cd tree-sitter-zig

# compile the parser into a `.so`
cc -shared -o zig.so -fPIC src/parser.c

# move the compiled parser to the grammar search path
mkdir -p ~/.local/lib/tree-sitter
mv zig.so ~/.local/lib/tree-sitter/

# and finally copy the queries so the plugin can find them
mkdir -p ~/.local/share/tree-sitter/queries/zig
cp queries/highlights.scm ~/.local/share/tree-sitter/queries/zig/
```

### API

The `vis-treesitter` plugin exposes a small API that allows you to configure search paths for grammars and queries, as well as manage the internal parser caches.

To use the API, make sure to require the module in your `visrc.lua`:

```lua
local ts = require("vis-treesitter")
```

By default, `vis-treesitter` searches standard system directories and your local `~/.local/lib/tree-sitter/` for parsers (`<LANG>.so`).

The two following functions allow you to *prepend* custom search paths to both queries and grammars:

`ts.add_grammar_path(path)`

Adds a custom directory to the list of paths searched for compiled tree-sitter grammars (`.so` files). 

```lua
ts.add_grammar_path("/opt/my-parsers/")
```
*NOTE*: The path will automatically have a **trailing slash** appended if it doesn't already have one.

`ts.add_query_path(path)`

Adds a custom directory to the list of paths searched for tree-sitter highlight queries (`.scm` files). 

```lua
ts.add_query_path("/home/moi/.local/my-queries/")
```

#### Other niceties

`vis-treesitter` internally caches loaded grammars, compiled queries, and active syntax trees for performance, the following functions allow you to clear those caches:

`ts.reset_caches()`

Fully clears the global parser and query caches (all windows)

```lua
ts.reset_caches()
```
*NOTE*: You may use this if you are actively developing a tree-sitter grammar or tweaking query files and need to force `vis-treesitter` to reload them from disk without restarting the editor.

`ts.clear_cache(win)`

Clear the cached syntax tree for a **specific** window instance.

```lua
ts.clear_cache(vis.win)
```
*NOTE*: Please note that this forces the window to completely re-parse its content from scratch on the next highlight cycle, it does not, however, unload the parser and query cache from memory, but rather destroys the nodes tree for it to be rebuilt on the next highlight cycle,.

## Troubleshooting

### "Unknown syntax definition" errors

When opening a file you may encounter an error like:

```
Unknown syntax definition: `dosini'
```

Which means `vis` is looking for a syntax named `dosini`, but neither `vis-treesitter` nor vis's built-in lexers can find it.

The common cause for this is **vim modelines.** `vis` partially supports vim modelines (through plugins), so a comment like `# vim: ft=dosini` at the top or bottom of a file will set `win.syntax` to `dosini`: which is a name that vis and tree-sitter don't recognize, so check the file for modelines and remove or adjust them (or check the workaround for the next cause).

Another cause is: **ftdetect name mismatch.**, meaning the syntax name `vis` assigns to a filetype (via its `ftdetect` tables) may not match the tree-sitter grammar name.

To find out what name `vis` uses for each file extension, add this snippet temporarily to your `visrc.lua` and restart vis:

```lua
vis.events.subscribe(vis.events.INIT, function()
    local f = io.open("/tmp/vis-ftdetect.txt", "w")
    for syntax, ft in pairs(vis.ftdetect.filetypes) do
        local exts = ft.ext and table.concat(ft.ext, ", ") or ""
        f:write(syntax .. " -> " .. exts .. "\n")
    end
    f:close()
end)
```

Then check `/tmp/vis-ftdetect.txt`, if the syntax name there differs from your tree-sitter grammar name, add an alias in your `visrc.lua`:

```lua
local ts = require('plugins/vis-treesitter')
ts.aliases["dosini"] = "ini"
```

*NOTE*: Please note that symlinking `dosini.so -> ini.so` will **not** work since tree-sitter looks for a C symbol named `tree_sitter_<lang>()` inside the library, regardless of the filename!

## TODO

Currently, `vis-treesitter` only uses `highlights.scm` to provide syntax highlighting.
A main feature planned for future implementation is: `injections.scm`, which adds support for parsing and highlighting embedded languages (for instance, JavaScript inside HTML, or SQL inside Python strings).

*(**NOTE**: Other standard tree-sitter queries like `folds.scm`, `indents.scm`, and `locals.scm` are NOT currently into consideration. I think that `vis` natively handles indentation well enough, as for folding/definition tracking, it currently lacks the necessary APIs to easily integrate them ).*

