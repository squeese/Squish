local Q = select(2, ...)

local Iterator
local Range
do
  local tmp = {}
  Q.Iterator = Q.Driver{
    acquire = Driver.opaque,
    render = function(self, container, fn)
      local i = 0
      repeat
        i = i + 1
        tmp[i] = fn(i)
      until not tmp[i]
      return unpack(tmp, 1, i-1)
    end
  }

  Q.Range = Q.Driver{
    acquire = Driver.opaque,
    render = function(self, container, b, e, fn)
      for i = 1, 100 do
        tmp[i] = nil
      end
      for i = b, e do
        tmp[i] = fn(i)
      end
      return unpack(tmp, b, e)
    end
  }
end
