return function (t, k)
  local tk = t[k]
  if not tk then
    tk = {}
    t[k] = tk
  end
  return tk
end
