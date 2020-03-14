local Subject = {}
Subject.__index = Subject

if require then
  return Subject
else
  select(2, ...).Subject = Subject
end