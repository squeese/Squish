local Q = select(2, ...)

function Q.Index(root, call)
  root.__call = call or function(self, next)
    next.__index = self
    next.__call = self.__call
    return setmetatable(next, next)
  end
  return setmetatable(root, root)
end
