do
  local SectionNegative = { title = "Negative", icon = 134466 }
  function SectionNegative.init(section)
    print("init", section.title)
    return section
  end
  table.insert(Sections, SectionNegative)
end
