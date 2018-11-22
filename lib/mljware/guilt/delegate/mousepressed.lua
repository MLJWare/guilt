local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local ensure = require (subsubpath.."pleasure.ensure")

local is_callable
do
  local pleasure = require (subsubpath.."pleasure")
  is_callable = pleasure.is.callable
end

return function (self, mx, my, button, isTouch)
  self.active = true

  local press_tag = "pressed"..button

  local x, y = self:bounds()
  mx, my = mx - x, my - y

  local gui = self._guilt_gui_
  local gui_tag_bag = ensure(gui.tags, press_tag)

  local no_press = true

  for _, child in self:children() do
    -- TODO ensure [mx, my] contained in region
    child.active = nil
    if  no_press
    and child:contains(mx, my) then
      gui_tag_bag[child] = true
      child[press_tag] = true
      child.pressed    = true
      if is_callable(child.mousepressed) then
        child:mousepressed(mx, my, button, isTouch)
        no_press = false
      end
    end
  end

  if no_press then
    self:deactivate()
  end

  return not no_press
end
