local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local ensure = require (subsubpath.."pleasure.ensure")

local is_callable
do
  local pleasure = require (subsubpath.."pleasure")
  is_callable = pleasure.is.callable
end

return function (self, mx, my, button, isTouch)
  local press_tag = "pressed"..button

  local x, y = self:bounds()
  mx, my = mx - x, my - y

  local gui = self._guilt_gui_
  local gui_tags = gui.tags
  local gui_tag_bag = ensure(gui_tags, press_tag)

  local no_release = true
  local no_click   = true
  for _, child in self:children() do
    -- TODO ensure [mx, my] contained in region
    if  child:contains(mx, my) then
      if no_release and is_callable(child.mousereleased) then
        child:mousereleased(mx, my, button, isTouch)
        no_release = false
      end

      if no_click and gui_tag_bag[child] and is_callable(child.mouseclicked) then
        child:mouseclicked(mx, my, button)
        no_click = false
      end
    end
  end

  return not no_release
end
