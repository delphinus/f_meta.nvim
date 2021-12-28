local M = {
  funcs = {},
  delim = package.config:sub(1, 1),
  my_name = (function()
    local file = debug.getinfo(1, 'S').source
    return file:match'([_a-z]+)%.lua$'
  end)()
}

-- https://stackoverflow.com/questions/7526223/how-do-i-know-if-a-table-is-an-array
local function is_array(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then return false end
  end
  return true
end

local function from_name(name)
  local count = -1
  return function()
    count = count + 1
    return count > 0 and ('%s_%03d'):format(name, count) or name
  end
end

local function from_info(info)
  local count = 0
  return function()
    count = count + 1
    local src = info.short_src
      :gsub('^.*'..M.delim, '')
      :gsub('%.lua$', '')
      :gsub('[^%a]', '_')
    return ('%s_%s_%03d'):format(src, info.currentline, count)
  end
end

function M.new(opts)
  if not opts.level then opts.level = 2 end
  local info = debug.getinfo(opts.level)
  local name_fn = opts.name and from_name(opts.name) or from_info(info)
  local name = nil
  while not name do
    local n = name_fn()
    if not M.funcs[n] then
      name = n
    end
  end
  local self = setmetatable({
    info = info,
    name = name,
    __fn = opts.fn,
  }, {
    __call = opts.fn,
    __index = M,
    __tostring = function()
      return ('anonymous function defined in %s:%d'):format(
        info.short_src,
        info.currentline
      )
    end,
  })
  M.funcs[name] = self
  return self
end

function M:vim()
  return ('v:lua.%s'):format(self:lua())
end

function M:lua()
  return ([[require'%s'.%s]]):format(self.my_name, self.name)
end

return setmetatable({}, {
  __call = function(self, opts, ...)
    local args = {...}
    if #args > 0 then opts = {opts, args[1]} end
    assert(
      type(opts) == 'function' or type(opts) == 'table',
      'opts must be a function or a table'
    )
    if type(opts) == 'function' then
      return M.new{fn = opts}
    end
    if is_array(opts) then
      assert(#opts == 1 or #opts == 2, [[{'some name', fn} or {fn} is acceptable]])
      if #opts == 1 then
        assert(type(opts[1]) == 'function', 'fn must be a function in {fn}')
        return M.new{fn = opts[1]}
      end
      assert(
        type(opts[1]) == 'string' and type(opts[2]) == 'function',
        'name must be a string and fn must be a function in {name, fn}'
      )
      return M.new{name = opts[1], fn = opts[2]}
    end
    assert(type(opts.fn) == 'function', 'opts.fn must be a function')
    assert(
      type(opts.name) == 'nil' or type(opts.name) == 'string',
      'opts.name must be nil or string'
    )
    return M.new(opts)
  end,
  __index = function(self, key) return M.funcs[key] end,
})
