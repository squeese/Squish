local Q = select(2, ...)

Q.Context = Q.Driver{
  render = function(self, container, parent, key, ...)
    container.state = self
    return ...
  end,
  remove = function(self, container)
    container.state = nil
  end
}
