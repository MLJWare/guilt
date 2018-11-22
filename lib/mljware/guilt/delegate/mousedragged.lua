local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local is_callable
do
  local pleasure = require (subsubpath.."pleasure")
  is_callable = pleasure.is.callable
end

return function (self, mx, my, dx, dy, pressed1, pressed2, pressed3)
  local x, y = self:bounds()
  mx, my = mx - x, my - y

  for _, child in self:children() do
    if ((pressed1 and child.pressed1)
     or (pressed2 and child.pressed2)
     or (pressed3 and child.pressed3))
    and is_callable(child.mousedragged) then
      child:mousedragged(mx, my, dx, dy, pressed1, pressed2, pressed3)
      return true
    end
  end
end
