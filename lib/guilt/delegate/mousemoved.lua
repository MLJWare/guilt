local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")
local contains, is_callable, try_invoke
do
  local pleasure = require (subsubpath.."pleasure")
  contains, is_callable, try_invoke = pleasure.contains, pleasure.is.callable, pleasure.try.invoke
end

return function (self, mx, my, dx, dy)
  --TODO mouse enter/exit
  mx, my = mx - self.x + self.width/2, my - self.y + self.height/2

  local branch_element
  for i, child in ipairs(self.children) do
    if not branch_element
    and contains(child, mx, my)
    and is_callable(child.mousemoved) then
      branch_element = child
    end

    local pressed1, pressed2 = child.pressed1, child.pressed2
    if pressed1 or pressed2 then
      try_invoke(child, "mousedragged", mx, my, pressed1, pressed2)
    end
  end

  if branch_element then
    return branch_element:mousemoved(mx, my, button, isTouch)
  end
end
