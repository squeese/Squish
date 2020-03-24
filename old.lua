
  --local function child(instance, index, keys, key, prototype, ...)
    --if key then
      --local sIndex = instance[key]
      --if sIndex then
        --instance[index] = render(instance, ARGS[sIndex], key, prototype, ...)
        --instance[key] = nil
        --ARGS[sIndex] = nil
      --else
        --instance[index] = render(instance, nil, key, prototype, ...)
      --end
      --return true
    --end
    --local nIndex = -(index - keys)
    --local sIndex = instance[nIndex]
    --if sIndex then
      --instance[index] = render(instance, ARGS[sIndex], key, prototype, ...)
      --instance[nIndex] = nil
      --ARGS[sIndex] = nil
    --else
      --instance[index] = render(instance, nil, key, prototype, ...)
    --end
  --end

  --local function children(instance, ...)
    --local sBeg = #ARGS
    --local sEnd = #ARGS + #instance
    --local sNum = 0
    --for index, child in ipairs(instance) do
      --local child = instance[index]
      --if child.key then
        --instance[child.key] = sBeg + index
      --else
        --sNum = sNum - 1
        --instance[sNum] = sBeg + index
      --end
      --ARGS[sBeg + index] = child
      --instance[index] = nil
    --end

    --local keys = 0
    --for index = 1, select("#", ...) do
      --local sIndex = select(index, ...)
      --local key = STACK[sIndex+1]
      --local pro = STACK[sIndex+2]


      ----if child(instance, index, keys, STACK:pop(select(index, ...))) then
        ----keys = keys + 1
      ----end
    --end

    --for i = sBeg+1, sEnd do
      --if ARGS[i] ~= nil then
        --if ARGS[i].key then
          --instance[ARGS[i].key] = nil
          --inc()
          --render(instance, ARGS[i], nil)
          --dec()
        --else
          --instance[sNum] = nil
          --sNum = sNum + 1
          --inc()
          --render(instance, ARGS[i], nil)
          --dec()
        --end
        --ARGS[i] = nil
      --end
    --end
  --end


    local index = next()

    for i = 1, STACK.index do
      print("STACK", i, STACK[i])
    end


    --if prototype == nil then
      --if instance ~= nil then 
        --for index = 1, #instance do
          --render(instance, instance[index], nil)
          --instance[index] = nil
        --end
        --getmetatable(instance):remove(instance)
        --instance.key = nil
        --setmetatable(instance, nil)
        --table.insert(POOL, instance)
      --end
      --return nil

    --elseif instance == nil then
      --instance = #POOL > 0 and table.remove(POOL) or {}
      --instance.key = key
      --setmetatable(instance, prototype)
      --prototype:mount(instance, parent, ...)

    --elseif getmetatable(instance) ~= prototype then
      --for index = 1, #instance do
        --render(instance, instance[index], nil)
        --instance[index] = nil
      --end
      --getmetatable(prototype):remove(instance)
      --instance.key = key
      --setmetatable(instance, prototype)
      --prototype:mount(instance, parent)
    --end

    -- move instance children to ARGS table
    --local sBeg, sEnd, sNum = #ARGS, #ARGS + #instance, 0
    --for index, child in ipairs(instance) do
      --if child.key then
        --instance[child.key] = sBeg + index
      --else
        --sNum = sNum - 1
        --instance[sNum] = sBeg + index
      --end
      --ARGS[sBeg + index] = child
      --instance[index] = nil
    --end

    --for i = 1, select("#", ...) do
      -- local index = select(i, ...)
      -- local childKey = STACK[index+1]
      -- local childProt = STACK[index+2]
      -- print(i, index, childKey, childProt)

      --render(instance, )
    --end

    --for i = sBeg+1, sEnd do
      --if ARGS[i] ~= nil then
        --if ARGS[i].key then
          --instance[ARGS[i].key] = nil
          --render(instance, ARGS[i], nil)
        --else
          --instance[sNum] = nil
          --sNum = sNum + 1
          --render(instance, ARGS[i], nil)
        --end
        --ARGS[i] = nil
      --end
    --end
    --
local Elems = Squish.Elems
local Set = Elems.Set

Elems("Base", nil, {
  upgrade = function(self, props)
    for index, child in ipairs(props) do
      if type(child) == "table" and child.__index == nil then
        props[index] = Set(child)
      end
    end
    return props
  end
})

Elems("Frame", "Base", {
  __pool = CreateFramePool("frame", UIParent, nil, nil),
  mount = function(self, parent)
    self.__super.mount(self, parent)
    self.__frame = self.__pool:Acquire()
    self.__frame:SetParent(self.__parent.__frame)
    self.__frame:ClearAllPoints()
    self.__frame:Show()
  end,
  copy = function(self, other, parent)
    self.__super.copy(self, other, parent)
    self.__frame:ClearAllPoints()
  end,
  remove = function(self)
    self.__pool:Release(self.__frame)
    self.__super.remove(self)
  end,
})

Elems("Text", "Base", {
  __pool = CreateFontStringPool(UIParent, nil, nil, 'GameFontNormal'),
  mount = function(self, parent)
    self.__super.mount(self, parent)
    self.__frame = self.__pool:Acquire()
    self.__frame:SetParent(self.__parent.__frame)
    self.__frame:ClearAllPoints()
    self.__frame:Show()
  end,
  copy = function(self, other, parent)
    self.__super.copy(self, other, parent)
    self.__frame:ClearAllPoints()
  end,
  remove = function(self)
    self.__pool:Release(self.__frame)
    self.__super.remove(self)
  end,
})

Elems("Button", "Base", {
  __pool = CreateFramePool("button", UIParent, 'UIPanelButtonTemplate', nil),
  mount = function(self, parent)
    self.__super.mount(self, parent)
    self.__frame = self.__pool:Acquire()
    self.__frame:SetParent(self.__parent.__frame)
    self.__frame:ClearAllPoints()
    self.__frame:Show()
  end,
  remove = function(self)
    self.__pool:Release(self.__frame)
    self.__super.remove(self)
  end,
})
