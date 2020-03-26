local Q = select(2, ...)

Q.Context = Q.Driver{
  RENDER = function(self, container, parent, key, ...)
    container.state = self
    return ...
  end,
  REMOVE = function(self, container)
    container.state = nil
  end
}
