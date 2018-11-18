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

  local scale = self.render_scale or 1
  mx, my = mx/scale, my/scale

  local gui = self._guilt_gui_
  local gui_tag_bag = ensure(gui.tags, press_tag)

  local not_found = true
  for _, child, region_x, region_y, region_width, region_height in self:children() do
    local child_mx, child_my = mx - (region_x or 0), my - (region_y or 0)
    -- TODO ensure [mx, my] contained in region
    child.active = nil
    if  child_mx >= 0 and (region_width or math.huge) > child_mx
    and child_my >= 0 and (region_height or math.huge) > child_my
    and child:contains(child_mx, child_my) then
      gui_tag_bag[child] = true
      child[press_tag] = true
      child.pressed    = true
      if  not_found
      and is_callable(child.mousepressed) then
        child:mousepressed(child_mx, child_my, button, isTouch)
        not_found = false
      end
    end
  end
end
