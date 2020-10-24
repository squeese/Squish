local MEDIA = {}
do
  local bgFlat = [[Interface\\Addons\\Squish\\media\\backdrop.tga]]
  local barFlat = [[Interface\\Addons\\Squish\\media\\flat.tga]]
  local vixar = [[interface\\addons\\squish\\media\\vixar.ttf]]
  function MEDIA:BACKDROP()
    return {
      bgFile = bgFlat,
      edgeSize = 1,
      insets = {
        left = -1, right = -1, top = -1, bottom = -1
      }
    }
  end
  function MEDIA:STATUSBAR()
    return barFlat
  end
  function MEDIA:FONT()
    return vixar
  end
end
