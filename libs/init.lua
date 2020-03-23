setmetatable(select(2, ...), {
  __call = function(self, fn)
    fn()
  end
})
