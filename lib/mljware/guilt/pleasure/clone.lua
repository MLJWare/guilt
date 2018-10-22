local function _clone(data)
  if type(data) ~= "table" then
    return data
  end
  local _meta = getmetatable(data)
  if type(_meta) == "table" and _meta.__immutable then
     --don't clone 'immutable' tables
    return data
  end
  -- deep cloning of 'mutable' tables
  local new = {}
  for k, v in pairs(data) do
    new[k] = _clone(v)
  end
  return setmetatable(new, _meta)
end

return _clone
