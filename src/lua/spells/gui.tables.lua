do
  local function CreateTable(pool)
    return {}
  end
  local function ResetTable(pool, tbl)
    for k in pairs(tbl) do
      tbl[k] = nil
    end
  end
  self.tablePool = CreateObjectPool(CreateTable, ResetTable)
end
