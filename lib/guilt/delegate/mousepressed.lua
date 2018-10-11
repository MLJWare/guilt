local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local ensure = require (subsubpath.."pleasure.ensure")

local contains, is_callable, try_invoke
do
  local pleasure = require (subsubpath.."pleasure")
  contains, is_callable, try_invoke = pleasure.contains, pleasure.is.callable, pleasure.try.invoke
end

return function (self, mx, my, button, isTouch)
  self.active = true

  local press_tag = "pressed"..button

  local x, y, width, height = self:bounds()
  mx, my = mx - x, my - y

  local scale = self.render_scale or 1
  mx, my = mx/scale, my/scale

  local gui = self._guilt_gui_
  local gui_tag_bag = ensure(gui.tags, press_tag)

  local not_found = true
  for i, child in ipairs(self.children) do
    child.active = nil
    if contains(child, mx, my) then
      gui_tag_bag[child] = true
      child[press_tag] = true
      if  not_found
      and is_callable(child.mousepressed) then
        child:mousepressed(mx, my, button, isTouch)
        not_found = false
      end
    end
  end

  if branch_element then
  end
end
