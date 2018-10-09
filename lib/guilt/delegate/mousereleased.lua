local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")
local contains, is_callable, try_invoke
do
  local pleasure = require (subsubpath.."pleasure")
  contains, is_callable, try_invoke = pleasure.contains, pleasure.is.callable, pleasure.try.invoke
end

return function (self, mx, my, button, isTouch)
  local press_tag = "pressed"..button

  mx, my = mx - self.x + self.width/2, my - self.y + self.height/2

  local branch_element
  for i, child in ipairs(self.children) do
    if not branch_element
    and contains(child, mx, my)
    and is_callable(child.mousereleased) then
      branch_element = child
    end

    if child[press_tag] then
      if contains(child, mx, my) then
        try_invoke(child, "mouseclicked", mx, my, button)
      end
      child[press_tag] = nil
    end
  end

  if branch_element then
    return branch_element:mousereleased(mx, my, button, isTouch)
  end
end
