local Q = select(2, ...)

Q.SetStatic = Q.Driver{
  acquire = Q.Driver.opaque,
  render = function(self, container, name, ...)
    container.frame[name](container.frame, ...)
  end,
}


do
  local function init(size)
    return bit.lshift(1, size) - 1
  end
  local function open(gate, index)
    return bit.bxor(gate, bit.lshift(1, index-1))
  end
  local function update(container)
    if container.gate ~= 0 then return end
    local frame = container.frame
    local name = container[3]
    frame[name](frame, unpack(container, 4, container.length+2))
  end
  Q.Set = Q.Driver{
    mount = function(self, container, parent, ...)
      container.frame = parent.frame
      local length = select("#", ...)
      container.gate = init(length)
      container.length = length
      for index = 1, length do
        local value = select(index, ...)
        if type(value) == "table" and getmetatable(value) == Stream then
          container[-index] = value:subscribe(function(value)
            container[index+2] = value
            container.gate = open(container.gate, index)
            update(container)
          end)
        else
          container.gate = open(container.gate, index)
          container[index+2] = value
        end
      end
      update(container)
    end,
    render = Q.noop,
    remove = function(self, container)
      container.frame = nil
      container.gate = nil
      for i = -1, -container.length, -1 do
        local value = container[i]
        if value then
          value()
        end
        container[i] = nil
      end
      for i = 3, container.length+2 do
        container[i] = nil
      end
      container.length = nil
    end,
  }
  --Set.__call = function(driver, key, ...)
    --return Driver.__call(Static, key, key, ...)
  --end
end
