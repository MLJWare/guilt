local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local ensure = require (subsubpath.."pleasure.ensure")

local contains, is_callable, try_invoke
do
  local pleasure = require (subsubpath.."pleasure")
  contains, is_callable, try_invoke = pleasure.contains, pleasure.is.callable, pleasure.try.invoke
end

return function (self, mx, my, button, isTouch)
  local press_tag = "pressed"..button

  local x, y, width, height = self:bounds()
  mx, my = mx - x, my - y

  local scale = self.render_scale or 1
  mx, my = mx/scale, my/scale

  local gui = self._guilt_gui_
  local gui_tag_bag = ensure(gui.tags, press_tag)

  local not_found = true
  for i, child in self:children() do
    if  not_found
    and contains(child, mx, my)
    and is_callable(child.mousereleased) then
      child:mousereleased(mx, my, button, isTouch)
      not_found = false
    end

    if gui_tag_bag[child] then
      if contains(child, mx, my) then
        try_invoke(child, "mouseclicked", mx, my, button)
      end
    end
  end

  if gui == self then
    for child in pairs(gui_tag_bag) do
      child[press_tag]   = nil
      gui_tag_bag[child] = nil
    end
  end
end
