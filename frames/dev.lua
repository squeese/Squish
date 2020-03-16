
local Stream = Squish.Stream
local Node = Squish.Node
local media = Squish.media
local D = Squish.Data
local Q = Squish.Elems


local function RaidFrame_Test()
  Stream.events("SPELLS_CHANGED"):once():subscribe(function(...)
    Squish.Render(
      nil,
      Q.Header {
        {"SetPoint", "CENTER", 0, 0},
        {"SetBackdrop", media.square},
        {"SetBackdropColor", 0, 0, 0, 0.6},
        {"SetBackdropBorderColor", 0, 0, 0, 1},
        button = function(props)
          return Q.Frame {
            {"SetAllPoints"},
            {"SetBackdrop", media.square},
            {"SetBackdropColor", 1, 0, 0, 0.6},
            {"SetBackdropBorderColor", 0, 0, 0, 1},
            Q.Text {
              {"SetPoint", "TOP", 0, 0},
              {"SetText", D.UnitName:use(props.unit)},
            },
            Q.Text {
              {"SetPoint", "BOTTOM", 0, 0},
              {"SetText", props.unit},
            },
          }
        end,
      },
      Squish.Root)
  end)
end

local createElement = Squish.createElement
local createSet = Squish.createSet
local function CreateElement_Test()
  Stream.events("SPELLS_CHANGED"):once():subscribe(function(...)
    Squish.Render(
      nil,
      Squish.Node(function(props)
        local setBlue, blue = Squish.useState(false)
        local setRed, red = Squish.useState(false)
        return createElement(Q.Frame,
          createSet(Q.Set, "SetPoint", "CENTER", 0, 0),
          createSet(Q.Set, "SetSize", 300, 100),
          createSet(Q.Set, "SetBackdrop", media.square),
          createSet(Q.Set, "SetBackdropColor", 0, 0, 0, 0.6),
          createSet(Q.Set, "SetBackdropBorderColor", 0, 0, 0, 1),
          createElement(Q.Button,
            createSet(Q.Set, "SetPoint", "TOPLEFT", 0, 0),
            createSet(Q.Set, "SetSize", 50, 25),
            createSet(Q.Set, "SetText", "Blue"),
            createSet(Q.Set, "SetScript", "OnClick", function()
                setBlue(not blue)
            end)
          ),
          createElement(Q.Text,
            createSet(Q.Set, "SetPoint", "BOTTOMLEFT", 0, 0),
            createSet(Q.Set, "SetText", tostring(blue))
          ),
          createElement(Q.Button,
            createSet(Q.Set, "SetPoint", "TOPRIGHT", 0, 0),
            createSet(Q.Set, "SetSize", 50, 25),
            createSet(Q.Set, "SetText", "Red"),
            createSet(Q.Set, "SetScript", "OnClick", function()
                setRed(not red)
            end)
          ),
          createElement(Q.Text,
            createSet(Q.Set, "SetPoint", "BOTTOMRIGHT", 0, 0),
            createSet(Q.Set, "SetText", tostring(red))
          ),
          not blue and Squish.NULL or createElement(Q.Frame,
            createSet(Q.Set, "SetPoint", "LEFT", 10, -10),
            createSet(Q.Set, "SetSize", 32, 32),
            createSet(Q.Set, "SetBackdrop", media.square),
            createSet(Q.Set, "SetBackdropColor", 0, 0, 1, 0.6)
          ),
          not red and Squish.NULL or createElement(Q.Frame,
            createSet(Q.Set, "SetPoint", "RIGHT", 10, 10),
            createSet(Q.Set, "SetSize", 32, 32),
            createSet(Q.Set, "SetBackdrop", media.square),
            createSet(Q.Set, "SetBackdropColor", 1, 0, 0, 0.6)
          )
        )
      end),
      Squish.Root)
  end)
end


local function ToggleFrames_Test()
  local Square = Squish.Node(function(props)
    local setValue, value = Squish.useState(math.random())
    return Q.Frame {
      {"SetPoint", props.side, 0, 0},
      {"SetSize", 32, 32},
      {"SetBackdrop", media.square},
      {"SetBackdropColor", props.r or 0, 0, props.b or 0, 0.6},
      {"SetScript", "OnMouseDown", function()
          setValue(value + math.random())
      end},
      Q.Text {
        {"SetPoint", "CENTER", 0, 0},
        {"SetText", tostring(value)},
      },
    }
  end)
  local App = Squish.Node(function(props)
    local setBlue, blue = Squish.useState(true)
    local setRed, red = Squish.useState(true)
    local setNum, num = Squish.useState(0)
    local setOpen, open = Squish.useState(true)
    if not open then return nil end
    return Q.Frame {
      {"SetPoint", "CENTER", 0, 0},
      {"SetSize", 500, 100},
      {"SetBackdrop", media.square},
      {"SetBackdropColor", 0, 0, 0, 0.6},
      {"SetBackdropBorderColor", 0, 0, 0, 1},
      Q.Button {
        {"SetPoint", "TOPLEFT", 0, 0},
        {"SetSize", 50, 25},
        {"SetText", "Blue"},
        {"SetScript", "OnClick", function()
            setBlue(not blue)
        end}
      },
      Q.Button {
        {"SetPoint", "TOP", 0, 30},
        {"SetSize", 50, 25},
        {"SetText", "X"},
        {"SetScript", "OnClick", function()
            setOpen(false)
        end}
      },
      Q.Button {
        {"SetPoint", "TOP", -60, 0},
        {"SetSize", 50, 25},
        {"SetText", "-"},
        {"SetScript", "OnClick", function()
            setNum(math.max(0, num-1))
        end}
      },
      Q.Text {
        {"SetPoint", "TOP", 0, 0},
        {"SetText", tostring(num)},
      },
      Q.Button {
        {"SetPoint", "TOP", 60, 0},
        {"SetSize", 50, 25},
        {"SetText", "+"},
        {"SetScript", "OnClick", function()
            setNum(math.min(6, num+1))
        end}
      },
      Q.Button {
        {"SetPoint", "TOPRIGHT", 0, 0},
        {"SetSize", 50, 25},
        {"SetText", "Red"},
        {"SetScript", "OnClick", function()
            setRed(not red)
        end}
      },
      not blue and Squish.NULL or Square { b = 1, side = "LEFT" },
      not red and Squish.NULL or Square { r = 1, side = "RIGHT" },
      Q.Text {
        {"SetPoint", "BOTTOMLEFT", 0, 0},
        {"SetText", tostring(blue)},
      },
      Q.Text {
        {"SetPoint", "BOTTOMRIGHT", 0, 0},
        {"SetText", tostring(red)},
      },
      function(i)
        if i <= num then
          return Q.Frame {
            key = i,
            {"SetPoint", "CENTER", (i-1) * 30 - (num-1)*30/2, 0},
            {"SetSize", 30, 30},
            {"SetBackdrop", media.square},
            {"SetBackdropColor", 0, 0, 0, 0.6},
            {"SetBackdropBorderColor", 0, 0, 0, 1},
          }
        end
      end
    }
  end)

  Stream.events("SPELLS_CHANGED"):once():subscribe(function(...)
    Squish.Render(nil, App, Squish.Root)
    Squish.POOL_REPORT()
  end)
end

local function UnitFrame_Test()
  local Tile = Q.Base {}
  function Tile:render(prev)
    local offset = 0
    local height = self.__frame:GetHeight()
    local weights = 0
    for _, child in ipairs(self) do
      weights = weights + (child.weight or 1)
    end
    for index, child in ipairs(self) do
      local chunk = ((child.weight or 1) / weights) * height
      table.insert(child, Q.Set{'ClearAllPoints'})
      table.insert(child, Q.Set{'SetPoint', 'TOPLEFT', 0, -offset})
      table.insert(child, Q.Set{'SetPoint', 'BOTTOMRIGHT', self.__frame, 'TOPRIGHT', 0, -offset + -chunk})
      offset = offset + chunk
    end
    return self
  end

  local UnitFrame = Q.Base(function(props)
    return Q.UnitButton {
      unit = props.unit,
      {"SetSize", 200, 64},
      {"SetBackdrop", media.square},
      {"SetBackdropColor", 0, 0, 0, 0.6},
      {"SetBackdropBorderColor", 0, 0, 0, 1},
      props:children(),
      Tile {
        Q.Bar {
          {'SetStatusBarTexture', media.flat},
          {'SetStatusBarColor', 0.3, 0.05, 0.6, 0.75},
          {'SetMinMaxValues', 0, 1},
          {'SetValue', 1},
          Q.Text {
            {"SetPoint", "CENTER", 0, 0},
            {"SetText", UnitName(props.unit)},
          },
        },
        Q.Bar {
          weight = 0.2,
          {'SetStatusBarTexture', media.flat},
          {'SetStatusBarColor', 0.8, 0.05, 0.6, 0.75},
          {'SetMinMaxValues', 0, 1 },
          {'SetValue', 1},
          Q.Text {
            {"SetPoint", "CENTER", 0, 0},
            {"SetText", UnitName(props.unit)},
          },
        }
      }
    }
  end)

  local UI = Node {
    UnitFrame {
      unit = 'player',
      {"SetPoint", "CENTER", -105, 0},
    },
    UnitFrame {
      unit = 'target',
      {"SetPoint", "CENTER", 105, 0},
    },
  }

  Stream.events("SPELLS_CHANGED"):once():subscribe(function(...)
    print("initial render")
    Squish.Render(nil, UI, Squish.Root)
  end)
end

local function Aura_Test()
  local Auras = Q("Auras", {
    copy = function(self, prev, parent)
    end,
    render = function(self)

    end
  })

  

  --C_Timer.NewTicker(1, function()
    --print("num:", pool.numActiveObjects)
    --print("   :", #pool.activeObjects)
    --print("   :", #pool.inactiveObjects)
  --end, 10)

  local App_A = Squish.Node(function(props)
    local power, max, _, kind = Squish.useStream(D.UnitPower, 'player')
    -- print(power, max, kind)
    return node(Q.Frame, "unit", "player",
      set("SetSize", 200, 64),
      set("SetPoint", "CENTER", 0, 0),
      set("SetBackdrop", media.square),
      set("SetBackdropColor", 0, 0, 0, 0.6),
      set("SetBackdropBorderColor", 0, 0, 0, 1),
      node(Q.Text,
        set("SetPoint", "TOP", 0, 0),
        -- set("SetText", D.UnitPower)
        set("SetText", power)
      ),
      node(Q.Text,
        set("SetPoint", "CENTER", 0, 0),
        -- set("SetText", D.UnitPower:select(2))
        set("SetText", max)
      ),
      node(Q.Text,
        set("SetPoint", "BOTTOM", 0, 0),
        -- set("SetText", D.UnitPower:select(4))
        set("SetText", kind)
      )
    )
  end)

  local App_B = Squish.Node(function(props)
    local power, max, _, kind = Squish.useStream(D.UnitPower, 'player')
    -- print(power, max, kind)
    return Q.Frame {
      unit = "player",
      Q.Set{"SetSize", 200, 64},
      Q.Set{"SetPoint", "CENTER", 0, 0},
      Q.Set{"SetBackdrop", media.square},
      Q.Set{"SetBackdropColor", 0, 0, 0, 0.6},
      Q.Set{"SetBackdropBorderColor", 0, 0, 0, 1},
      Q.Text{
        Q.Set{"SetPoint", "TOP", 0, 0},
        -- set("SetText", D.UnitPower)
        Q.Set{"SetText", power},
      },
      Q.Text{
        Q.Set{"SetPoint", "CENTER", 0, 0},
        -- set("SetText", D.UnitPower:select(2))
        Q.Set{"SetText", max},
      },
      Q.Text{
        Q.Set{"SetPoint", "BOTTOM", 0, 0},
        -- set("SetText", D.UnitPower:select(4))
        Q.Set{"SetText", kind},
      },
    }
  end)
  Stream.events("SPELLS_CHANGED"):once():subscribe(function()
    local app = nil
    app = Squish.Render(app, App_A, Squish.Root)
    -- app = Squish.Render(app, App, Squish.Root)
  end)
end

-- RaidFrame_Test()
-- ToggleFrames_Test()
-- UnitFrame_Test()
-- CreateElement_Test()
Aura_Test()
