local Media = {
  BACKDROP_FLAT  = [[Interface\\Addons\\SquishUI\\media\\backdrop.tga]],
  BACKDROP_EDGE  = [[Interface\\Addons\\SquishUI\\media\\edgeFile.tga]],
  STATUSBAR_FLAT = [[Interface\\Addons\\SquishUI\\media\\flat.tga]],
  STATUSBAR_MIN  = [[Interface\\Addons\\SquishUI\\media\\minimalist.tga]],
  FONT_VIXAR     = [[interface\\addons\\squishUI\\media\\vixar.ttf]],
  insets = {},
}
function Media:CreateBackdrop(bgFile, edgeFile, edgeSize, insetLeft, insetRight, insetTop, insetBottom)
  if bgFile and type(bgFile) == "boolean" then
    self.bgFile = self.BACKDROP_FLAT
  else
    self.bgFile = bgFile
  end
  if edgeFile and type(edgeFile) == "boolean" then
    self.edgeFile = self.BACKDROP_EDGE
  else
    self.edgeFile = edgeFile
  end
  self.edgeSize = edgeSize or 0
  self.insets.left = insetLeft
  self.insets.right = (insetRight or insetLeft)
  self.insets.top = (insetTop or insetLeft)
  self.insets.bottom = (insetBottom or insetLeft)
  return self
end
