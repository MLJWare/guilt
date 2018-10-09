local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")
local contains, is_callable, try_invoke
do
  local pleasure = require (subsubpath.."pleasure")
  contains, is_callable, try_invoke = pleasure.contains, pleasure.is.callable, pleasure.try.invoke
end

return function (self, mx, my, button, isTouch)
  self.active = true

  local press_tag = "pressed"..button

  mx, my = mx - self.x + self.width/2, my - self.y + self.height/2

  local branch_element
  for i, child in ipairs(self.children) do
    child.active = nil
    if contains(child, mx, my) then
      child[press_tag] = true
      if not branch_element and is_callable(child.mousepressed) then
        branch_element = child
      end
    end
  end

  if branch_element then
    return branch_element:mousepressed(mx, my, button, isTouch)
  end
end
