_, PS = ...
PS.Utils = {}

function PS.Utils.identity(...)
  return ...
end

function PS.Utils.noop()
end

function PS.Utils.indexOf(tbl, val)
  for i = 1, #tbl do
    if tbl[i] == val then
      return i
    end
  end
  return nil
end

function PS.Utils.isProperty(key, val)
  return type(key) == 'string' and string.sub(key, 1, 2) ~= '__' and type(val) ~= 'function'
end

function PS.Utils.isStream(value)
  return type(value) == 'table' and type(value.subscribe) == 'function'
end

function PS.Utils.isNode(value)
  return type(value) == 'table' and type(value.__call) == 'function'
end

function PS.Utils.insert(t, ...)
  for i = 1, select('#', ...) do
    t[i] = select(i, ...)
  end
  return t
end

function PS.Utils.Packer_init(t, offset, size)
  t.__packer_active = false
  t.__packer_pen_s = offset
  t.__packer_pen_e = offset + size - 1
  t.__packer_ind_s = offset + size
  t.__packer_ind_e = offset + size * 2
  for i = t.__packer_pen_s, t.__packer_pen_e do
    t[i] = true
  end
  for i = t.__packer_ind_s, t.__packer_ind_e do
    t[i] = i + size + 1
  end
end

function PS.Utils.Packer_pending(t)
  for i = t.__packer_pen_s, t.__packer_pen_e do
    if t[i] then
      return false
    end
  end
  t.__packer_active = true
  return true
end

function PS.Utils.Packer_write(t, index, ...)
  local length = select('#', ...)
  local curr = t.__packer_ind_s + index - 1
  local next = t.__packer_ind_s + index
  local padd = length - (t[next] - t[curr])
  if padd ~= 0 then
    if padd > 0 then
      for i = t[t.__packer_ind_e], t[next], -1 do
        t[i+padd] = t[i]
      end
    elseif padd < 0 then
      for i = t[next], t[t.__packer_ind_e] do
        t[i+padd] = t[i]
        t[i] = nil
      end
    end
    for i = next, t.__packer_ind_e do
      t[i] = t[i] + padd
    end
  end
  for i = 1, length do
    t[t[curr] + i - 1] = select(i, ...)
  end
  t[t.__packer_pen_s + index - 1] = false
  return t.__packer_active or PS.Utils.Packer_pending(t)
end