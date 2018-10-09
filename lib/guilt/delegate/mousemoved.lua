local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local ensure = require (subsubpath.."pleasure.ensure")

local contains, is_callable, try_invoke
do
  local pleasure = require (subsubpath.."pleasure")
  contains, is_callable, try_invoke = pleasure.contains, pleasure.is.callable, pleasure.try.invoke
end

return function (self, mx, my, dx, dy)
  --TODO mouse enter/exit
  mx, my = mx - self.x + self.width/2, my - self.y + self.height/2

  local gui = self._guilt_gui_
  local gui_pressed1_bag = gui.tags.pressed1
  local gui_pressed2_bag = gui.tags.pressed2

  local not_found = true
  for i, child in ipairs(self.children) do
    if  not_found
    and contains(child, mx, my)
    and is_callable(child.mousemoved) then
      child:mousemoved(mx, my, button, isTouch)
      not_found = false
    end

    local pressed1 = gui_pressed1_bag and gui_pressed1_bag[child] or false
    local pressed2 = gui_pressed2_bag and gui_pressed2_bag[child] or false
    if pressed1 or pressed2 then
      try_invoke(child, "mousedragged", mx, my, dx, dy, pressed1, pressed2)
    end
  end
end
