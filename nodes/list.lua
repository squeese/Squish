local PS = select(2, ...)
local Nodes = PS.Nodes

Nodes.List = Nodes.Base {
  __kind = 'List',

  -- cant have any child nodes, they are generated from data
  cloneNodes = PS.Utils.noop,

  createStream = function(self, send, done, parent)
    self.__propStream = self.__parent.__propStream
    local active = 0
    return self.data
      :tap(function(...)
        local length = select('#', ...)
        for index = 1, length do
          if not rawget(self, index) then
            self[index] = self.node {}
            self[index].__list_value = PS.Stream.subject()
            self[index].__list_index = PS.Stream.of(index)
          end
          if not self[index].__list_unsub then
            self[index].__list_unsub = self[index]:subscribe(send, done, self)
            active = active + 1
          end
          local value = select(index, ...)
          self[index].__list_value:send(value)
        end
        for index = active, (length + 1), -1 do
          self[index].__list_unsub()
          self[index].__list_unsub = nil
          active = active - 1
        end
      end)
      :after(function(fn, ...)
        for index = #self, 1, -1 do
          if self[index].__list_unsub then
            self[index].__list_unsub(...)
          end
          self[index] = nil
        end
        return fn(...)
      end)
  end
}

function PS.Stream:List(node)
  return Nodes.List {
    data = self,
    node = node
  }
end