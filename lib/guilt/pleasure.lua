local path = (...)
local is                      = require (path..".is")
local need                    = require (path..".need")

local pleasure = {
  is    = is;
  need  = need;
}

function pleasure.contains(element, mx, my)
  return math.abs(element.x - mx) <= element.width/2
     and math.abs(element.y - my) <= element.height/2
end

function pleasure.try_call(t, k, ...)
  if not (t and k) then return end
  local fn = t[k] if not is.callable(fn) then return end
  return fn(...)
end

function pleasure.try_invoke(t, k, ...)
  if not (t and k) then return end
  local fn = t[k] if not is.callable(fn) then return end
  return fn(t, ...)
end

return pleasure
