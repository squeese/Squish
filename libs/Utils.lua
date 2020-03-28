local Q = select(2, ...)

function Q.Index(root, call)
  root.__call = call or function(self, next)
    next.__index = self
    next.__call = self.__call
    return setmetatable(next, next)
  end
  return setmetatable(root, root)
end

local function unwind(tbl, min, max, ...)
  for i = min, max do
    tbl[i] = nil
  end
  return ...
end

local function write(t, ...)
  local l = select("#", ...) 
  for i = 1, l do
    t[i] = select(i, ...)
  end
  for i = l+1, #t do
    t[i] = nil
  end
end

Q.unwind = unwind
Q.write = write

do
  local remove = table.remove
  local insert = table.insert
  local pool = {}
  local function release(tbl, ...)
    for i = 1, #tbl do
      tbl[i] = nil
    end
    return ...
  end
  function Q.iterator(fn)
    return function()
      local tbl = remove(pool) or {}
      local index = 0
      repeat
        index = index + 1
        tbl[index] = fn(index)
      until not tbl[index]
      return release(tbl, 1, index, unpack(tbl))
    end
  end
  function Q.range(b, e, fn)
    if not fn then
      fn, e, b = e, b, 1
    end
    return function()
      local tbl = remove(pool) or {}
      for i = b, e do
        tbl[i] = fn(i)
      end
      return release(tbl, unpack(tbl))
    end
  end

  local function apply(fn, tbl, index, ...)
    if select("#", ...) > 0 then
      tbl[index] = fn(index, ...)
      return false
    end
    return true
  end
  function Q.iterate(iterator, fn)
    local tbl, index = remove(pool) or {}, 0
    repeat index = index + 1
    until apply(fn, tbl, index, iterator(index))
    return release(tbl, unpack(tbl))
  end
  function Q.map(fn, ...)
    local tbl = remove(pool) or {}
    for i = 1, select("#", ...) do
      local a = select(i, ...)
      local b = fn(i, a)
      if b then insert(tbl, b) end
    end
    return release(tbl, unpack(tbl))
  end
end
