local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local is_callable
do
  local pleasure = require (subsubpath.."pleasure")
  is_callable = pleasure.is.callable
end

return function (self, mx, my, wheel_dx, wheel_dy)
  local x, y = self:bounds()
  mx, my = mx - x, my - y

  for _, child in self:children() do
    -- TODO ensure [mx, my] contained in region
    if  child:contains(mx, my)
    and is_callable(child.mousewheelmoved) then
      child:mousewheelmoved(mx, my, wheel_dx, wheel_dy)
      return true
    end
  end
end
