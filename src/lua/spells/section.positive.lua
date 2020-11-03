local Section_Positive = { title = "Positive", icon = 134468 }
do
  function Section_Positive:Load(gui)
    print("load positive")
    gui.header:SetText("Positive spells")
  end

  function Section_Positive:Unload(gui)
    print("unload positive")
  end
end
