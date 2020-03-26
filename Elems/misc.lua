local Q = select(2, ...)
local iterate = Q.iterate

--local Iterator
--local Range
--do
  --local tmp = {}
  --Q.Iterator = Q.Driver{
    --acquire = Q.Driver.opaque,
    --render = function(self, container, fn)
      --local i = 0
      --repeat
        --i = i + 1
        --tmp[i] = fn(i)
      --until not tmp[i]
      --return unpack(tmp, 1, i-1)
    --end
  --}

  --Q.Range = Q.Driver{
    --acquire = Q.Driver.opaque,
    --render = function(self, container, b, e, fn)
      --for i = 1, 100 do
        --tmp[i] = nil
      --end
      --for i = b, e do
        --tmp[i] = fn(i)
      --end
      --return unpack(tmp, b, e)
    --end
  --}
--end

Q.Tmp = Q.Driver{
  RENDER = function(self, container, parent, key, source, driver)
    container.state = parent.state
    container.frame = parent.frame or UIParent
    container.driver = driver
    container.unsubscribe = source:subscribe(function(iterator)
      self:tmp(container, iterator)
    end, container.state)
  end,
  UPDATE = function(self, container, iterator)
    return iterate(iterator, container.driver)
  end,
  REMOVE = function(self, container)
    container.state = nil
    container.driver = nil
    container.frame = nil
    container.unsubscribe()
    container.unsubscribe = nil
  end,
}
