local this_file = debug.getinfo(1, 'S').short_src
local my_name = this_file:match'([_a-z]+)_spec%.lua$'
local f = require(my_name)
local fn_name = my_name..'_spec'

local function here() return debug.getinfo(2).currentline end
local function fn() print'foo' end

describe(my_name, function()

  describe('Calling f(fn) form', function()

    local line = here()
    local foo1 = f(fn)
    local foo2 = f(fn)

    it('returns a valid func name', function()
      assert.equals(('%s_%d_001'):format(fn_name, line + 1), foo1.name)
      assert.equals(('%s_%d_001'):format(fn_name, line + 2), foo2.name)
    end)

    it('is stringified validly', function()
      assert.equals(('anonymous function defined in %s:%d'):format(
        this_file, line + 1
      ), tostring(foo1))
      assert.equals(('anonymous function defined in %s:%d'):format(
        this_file, line + 2
      ), tostring(foo2))
    end)
  end)

  describe('Calling f(name, fn) form', function()

    local name = 'foobar'
    local foo1 = f(name, fn)
    local foo2 = f(name, fn)

    it('returns a valid func name', function()
      assert.equals(name, foo1.name)
      assert.equals(('%s_001'):format(name), foo2.name)
    end)
  end)

  describe('Calling f{name, fn} form', function()

    local name = 'barfoo'
    local foo1 = f{name, fn}
    local foo2 = f{name, fn}

    it('returns a valid func name', function()
      assert.equals(name, foo1.name)
      assert.equals(('%s_001'):format(name), foo2.name)
    end)
  end)

  describe('Calling f{fn} form', function()

    local line = here()
    local foo1 = f{fn}
    local foo2 = f{fn}

    it('returns a valid func name', function()
      assert.equals(('%s_%d_001'):format(fn_name, line + 1), foo1.name)
      assert.equals(('%s_%d_001'):format(fn_name, line + 2), foo2.name)
    end)
  end)

  describe('Calling f{name = name, fn = fn} form', function()

    local name = 'foobarfoo'
    local foo1 = f{name = name, fn = fn}
    local foo2 = f{name = name, fn = fn}

    it('returns a valid func name', function()
      assert.equals(name, foo1.name)
      assert.equals(('%s_001'):format(name), foo2.name)
    end)
  end)
end)
