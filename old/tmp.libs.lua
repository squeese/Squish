function Squish.CreateWeakTable()
  local tbl = setmetatable({}, {
    __mode = 'v',
    __call = function(self, value)
      if value ~= nil then
        table.insert(self, value)
      else
        collectgarbage("collect")
        for key in pairs(self) do
          print("WeakMap:", key, self[key])
        end
        return #self
      end
    end,
  })
  getmetatable(tbl).__index = getmetatable(tbl)
  return tbl
end

function Squish.Props()
  local dirty = false
  local props = {}
  local props_RO = setmetatable({}, {
    __index = props,
    __newindex = function(self, key, value)
    end,
  })
  return function(...)
    if dirty then
      for key in pairs(props) do
        props[key] = nil
      end
    end
    local offset = 1
    for i = 1, select("#", ...), 2 do
      local value = select(i, ...)
      if type(value) == "string" then
        dirty = true
        props[value] = select(i+1, ...)
        offset = i+2
      end
    end
    return props_RO, select(offset, ...)
  end
end

do
  Squish.matchTables = match
end



  function PASSIVE:driver(next, ...)
  end
  function PASSIVE:__call(...)
    return self:driver(...)
  end

  function ACTIVE:driver(...)
    return STACK:push(self, ...)
  end
  function ACTIVE:__call(...)
    return self:driver(...)
  end
  function ACTIVE:render(node, ...)
    return ...
  end


  --function ACTIVE:mount(super, container)
  --end
  --function ACTIVE:render(super, container)
  --end

  --local MTABLE = Squish.indextable({})
  --function MTABLE:driver(container, ...)
    ---- print("driver")
    ---- print("self/super", self)
    ---- print("container", container, 'args', ...)
  --end
  --function MTABLE:mount(container, ...)
    ---- return container:instance(self, self.key)
  --end
  --function MTABLE:render(instance)
    ---- return unpack(self)
  --end
  --


