local subpath = (...):match("(.-)[^%.]+$")
local is_callable = require (subpath.."is").callable

local try = {}

function try.call(t, k, ...)
  if not (t and k) then return false end
  local fn = t[k] if not is_callable(fn) then return false end
  return true, fn(...)
end

function try.invoke(t, k, ...)
  if not (t and k) then return false end
  local fn = t[k] if not is_callable(fn) then return false end
  return true, fn(t, ...)
end

return try
