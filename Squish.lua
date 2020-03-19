local Squish = select(2, ...)

Squish.Test(function(Section, Equals, Spy, DeepEquals)

  Section("basic inheritance", function()
    local Root = Squish.Node

    local AProp = {}
    local ANode = Root(AProp)
    Equals(ANode, AProp)
    Equals(ANode.__index, Root)

    local BProp = {}
    local BNode = ANode(BProp)
    Equals(BNode, BProp)
    Equals(BNode.__index, ANode)

    local CProp = {}
    local CNode = BNode(CProp)
    Equals(CNode, CProp)
    Equals(CNode.__index, BNode)

    local RSpy = Spy()
    local ASpy = Spy()
    local BSpy = Spy()
    local orig = Root.render
    Root.render = RSpy
    CNode:render()
    ANode.render = ASpy
    CNode:render()
    BNode.render = BSpy
    CNode:render()
    Equals(RSpy.count, 1)
    Equals(ASpy.count, 1)
    Equals(BSpy.count, 1)
    Root.render = orig
  end)

  Section("root node render call", function()
    local Root = Squish.Node
    local Orig = getmetatable(Root)
    local Node = Root{}
    local Meta = {}
    Meta.__index = Meta
    Meta.construct = Spy(function(self, key, a, b, c)
      Equals(self, Node)
      Equals(key, "key")
      Equals(a, 1)
      Equals(b, 2)
      Equals(c, 3)
    end)
    setmetatable(Squish.Node, Meta)
    Node("key", 1, 2, 3)
    setmetatable(Root, Orig)
  end)

  Section("simple mount/dismount", function()
    local Pool = {}
    local Renderer = Squish.CreateRenderer(Pool)
    local Update = Renderer(nil)
    local Node = Squish.Node{}
    Update(function()
      return Node(nil
        ,Node(nil)
        ,Node(nil)
      )
    end)
    Equals(#Pool, 0)
    Update(function()
      return nil
    end)
    Equals(#Pool, 3)
  end)

  Section("mount and dismount", function()
    local Pool = {}
    local Renderer = Squish.CreateRenderer(Pool)
    local Parent = {}
    setmetatable(Parent, Parent)
    local Update = Renderer(Parent)

    local Root = Squish.Node{}
    function Root:mount(node, parent)
      node.parent = parent
      node.parent.__call = function()
        local str = ""
        for _, child in ipairs(node) do
          str = str .. child.value
        end
        return str
      end
    end
    function Root:remove(node)
      node.parent.__call = nil
      node.parent = nil
    end

    local Set = Squish.Node{}
    function Set:render(node, value)
      node.value = value
    end
    function Set:remove(node)
      node.value = nil
    end

    Update(function()
      return Root(nil
        ,Set(nil, "A")
        ,Set(nil, "B")
        ,Set(nil, "C"))
    end)
    Equals(Parent(), "ABC")
    Equals(#Pool, 0)

    Update(function()
      return Root(nil
        ,Set(nil, "A")
        ,Set(nil, "B"))
    end)
    Equals(Parent(), "AB")
    Equals(#Pool, 1)

    Update(function()
      return Root(nil
        ,Set(nil, "B")
        ,Set(nil, "C"))
    end)
    Equals(Parent(), "BC")
    Equals(#Pool, 1)

    Update(function()
      return Root(nil
        ,Set(nil, "C")
        ,Set(nil, "B")
        ,Set(nil, "D")
        ,Set(nil, "A"))
    end)
    Equals(Parent(), "CBDA")
    Equals(#Pool, 0)

    Update(function()
      return nil
    end)
    Equals(Parent.__call, nil)
    Equals(#Pool, 5)

    for _, tbl in ipairs(Pool) do
      for key, value in pairs(tbl) do
        Equals(key, nil, "table in pool not cleaned, key: "..key)
      end
    end
  end)

  Section("mount and dismout, with keys", function()
    local Parent = {}
    setmetatable(Parent, Parent)
    local Update = Squish.CreateRenderer()(Parent)

    local Root = Squish.Node{}
    function Root:mount(node, parent)
      node.parent = parent
      node.parent.__call = function()
        local str = ""
        for _, child in ipairs(node) do
          str = child.value and str..child.value or str
        end
        return str
      end
    end

    local ANode = Squish.Node{}
    function ANode:render(node, value)
      node.value = value
    end

    local Range = Squish.Node{}
    function Range:render(node, ...)
      print("?", ...)
      return
    end

    local Tmp = Squish.Node(function(_, node, ...)
      print("?", node, ...)
      return ...
    end)

    Update(function()
      return Root(nil
        ,ANode(nil, "A")
        ,Tmp(nil
          ,ANode(nil, "a")
          ,ANode(nil, "b")
        )
        -- ,Range(nil, 1, 10, function(i) return BNode(i) end)
        ,ANode(nil, "B")
      )
    end)
    print(Parent())

    ViragDevTool_AddData(Parent, "ok")
  end)
end)
