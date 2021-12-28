# f\_meta.nvim

Yet another function definition to describe anonymous ones.

## What's this?

***This is fully experimental.***

This solves the problem that mapped global (or module-local) functions have obscure names and I annoyed to debug.

```vim
"                                ↓ global funcs mapped by any mapping util
autocmd FileType perl call v:lua.__mapped_funcs[123]
"                                ↓ same as module-local ones
autocmd FileType perl call v:lua.require'some_neat_mapper'.funcs[234]
```

With `f_meta.nvim`, it shows like below.

```vim
"                               ↓ you can name any func in this module.
autocmd FileType perl call v:lua.require'f_meta'.set_perl5lib()

lua print(require'f_meta'.set_perl5lib)
" This shows such description as below.
" → anonymous function defined in /path/to/script.lua at line 345

"                               ↓ name any function automatically without name in definition.
autocmd FileType perl call v:lua.require'f_meta'.script_345_001()
```

## Usage

```lua
-- When you save this code in /path/to/foo.lua ……
local f = require'f_meta'

local some_func = f{function()
  print'foobar'
end}

some_func()  -- You can call this as the ordinary.
             --→ foobar

print(some_func.name)  --→ foo_4_001
                       -- 4 means line num.
                       -- 001 means the counter to avoid duplications.
print(some_func)  --→ anonymous function defined in /path/to/foo.lua at line 4

print(some_func:lua())  --→ require'f_meta'.foo_4_001
print(some_func:vim())  --→ v:lua.require'f_meta'.foo_4_001

-- You can use this in such vimscript as below
vim.cmd('autocmd FileType perl call '..some_func:vim()..'()')
--→ vim.cmd[[autocmd FileType perl call v:lua.require'f_meta'.foo_4_001()]]

-- You can name any func.
local named_func = f{'some name func', function()
  print'named!'
end}

local another_func = f{
  name = 'this is also available',
  fn = function() print'named!' end,
}

local another_another_func = f(
  'parens also ok',
  function() print'named!' end  -- Carefully! You cannot use , here.
)
```
