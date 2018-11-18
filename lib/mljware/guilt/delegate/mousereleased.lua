local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local ensure = require (subsubpath.."pleasure.ensure")

local is_callable, try_invoke
do
  local pleasure = require (subsubpath.."pleasure")
  is_callable, try_invoke = pleasure.is.callable, pleasure.try.invoke
end

return function (self, mx, my, button, isTouch)
  local press_tag = "pressed"..button

  local x, y = self:bounds()
  mx, my = mx - x, my - y

  local scale = self.render_scale or 1
  mx, my = mx/scale, my/scale

  local gui = self._guilt_gui_
  local gui_tags = gui.tags
  local gui_tag_bag = ensure(gui_tags, press_tag)

  local not_found = true
  for _, child, region_x, region_y, region_width, region_height in self:children() do
    local mx, my = mx - (region_x or 0), my - (region_y or 0)
    -- TODO ensure [mx, my] contained in region
    if  not_found
    and mx >= 0 and (region_width or math.huge) > mx
    and my >= 0 and (region_height or math.huge) > my
    and child:contains(mx, my)
    and is_callable(child.mousereleased) then
      child:mousereleased(mx, my, button, isTouch)
      not_found = false
    end

    if gui_tag_bag[child] then
      if child:contains(mx, my) then
        try_invoke(child, "mouseclicked", mx, my, button)
      end
    end
  end

  if gui == self then
    local pressed1 = ensure(gui_tags, "pressed1")
    local pressed2 = ensure(gui_tags, "pressed2")
    local pressed3 = ensure(gui_tags, "pressed3")

    for child in pairs(gui_tag_bag) do
      child[press_tag]   = nil
      gui_tag_bag[child] = nil

      child.pressed = pressed1[child]
                   or pressed2[child]
                   or pressed3[child]
                   or nil
    end
  end
end
