

  -- ${name}.texture = target:CreateTexture(nil, 'OVERLAY')
  -- ${name}.texture:SetTexture([[Interface\\LFGFRAME\\BattlenetWorking0]])

  --[[
  target.texture:SetAllPoints()
  local targetSpring = CreateSpring(function(_, index)
    target:SetPoint("BOTTOMRIGHT", (index-1) * -70, 128)
  end, 170, 20, 0.001)
  local e = 0
  local current = nil

  target:SetScript('OnUpdate', function(_, elapsed)
    e = e + elapsed
    if e < 0.25 then return end
    local guid = UnitGUID("playertarget")
    if guid ~= current then
      current = guid
      local index = nil
      for i = 1, #self do
        self[i].handler(self[i], "CUST_BOSS_TARGET", current)
        if self[i].guid == current then
          index = i
        end
      end
      if index ~= nil then
        target:SetAlpha(1)
        targetSpring(index)
      else
        target:SetAlpha(0)
      end
    end
    e = 0
  end)
  ]]



    --local function CREATE(pool)
      --local frame = CreateFrame("frame", nil, self)
      --frame:SetSize(20, 20)
      --frame.texture = frame:CreateTexture(nil, 'OVERLAY')
      --frame.texture:SetAllPoints()
      --return frame
    --end
    --local function CLEAN(self, icon)
      --return icon
    --end
    -- local iconPool = CreateTexturePool(self)

    -- TODO - stop target onupdate when party isnt visible
    -- onattribute change

    --do -- boss target
      --function self:__tick()
      --end
    --end


    --local playerTargetFrame = BossTarget(self)
    --Ticker:Add(self)
    --function self:__tick()
    --end


    --playerTargetFrame.handler = function(_, guid)
      --if guid then
        --playerTargetAlpha(1)
      --else
        --playerTargetAlpha(0)
      --end
      --local index = nil
      --for i = 1, #self do
        --if self[i].guid == guid then
          --index = i
          --break
        --end
      --end
      --if index ~= nil then
        --playerTargetPosition(index)
      --end
    --end
