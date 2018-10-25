local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local ensure = require (subsubpath.."pleasure.ensure")

local is_callable, try_invoke
do
  local pleasure = require (subsubpath.."pleasure")
  is_callable, try_invoke = pleasure.is.callable, pleasure.try.invoke
end

return function (self, mx, my, dx, dy)
  --TODO mouse enter/exit

  local x, y, width, height = self:bounds()
  mx, my = mx - x, my - y

  local scale = self.render_scale or 1
  mx, my = mx/scale, my/scale
  dx, dy = dx/scale, dy/scale

  local gui = self._guilt_gui_
  local gui_pressed1_bag = gui.tags.pressed1
  local gui_pressed2_bag = gui.tags.pressed2

  local not_found = true
  for _, child, region_x, region_y, region_width, region_height in self:children() do
    local mx, my = mx - (region_x or 0), my - (region_y or 0)
    -- TODO ensure [mx, my] contained in region
    if  not_found
    and mx >= 0 and (region_width or math.huge) > mx
    and my >= 0 and (region_height or math.huge) > my
    and child:contains(mx, my)
    and is_callable(child.mousemoved) then
      child:mousemoved(mx, my, dx, dy)
      not_found = false
    end

    local pressed1 = gui_pressed1_bag and gui_pressed1_bag[child] or false
    local pressed2 = gui_pressed2_bag and gui_pressed2_bag[child] or false
    if pressed1 or pressed2 then
      try_invoke(child, "mousedragged", mx, my, dx, dy, pressed1, pressed2)
    end
  end
end
