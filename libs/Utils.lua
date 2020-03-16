local Squish = select(2, ...)

function Squish.childIterator(fn)
  local i = 0
  return function()
    i = i + 1
    return fn(i)
  end
end

function Squish.tableEquals(a, b)
  if #a ~= #b then return false end
  for i, v in ipairs(a) do
    if v ~= b[i] then
      return false
    end
  end
  return true
end

function Squish.tableFill(tbl, ...)
  for i = 1, select('#', ...) do
    tbl[i] = select(i, ...)
  end
  return tbl
end
