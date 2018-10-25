local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local ensure = require (subsubpath.."pleasure.ensure")

local is_callable, try_invoke
do
  local pleasure = require (subsubpath.."pleasure")
  is_callable, try_invoke = pleasure.is.callable, pleasure.try.invoke
end

return function (self, mx, my, wheel_dx, wheel_dy)
  local x, y, width, height = self:bounds()
  mx, my = mx - x, my - y

  local scale = self.render_scale or 1
  mx, my = mx/scale, my/scale

  for _, child, region_x, region_y, region_width, region_height in self:children() do
    local mx, my = mx - (region_x or 0), my - (region_y or 0)
    -- TODO ensure [mx, my] contained in region
    if  mx >= 0 and (region_width or math.huge) > mx
    and my >= 0 and (region_height or math.huge) > my
    and child:contains(mx, my)
    and is_callable(child.mousewheelmoved) then
      child:mousewheelmoved(mx, my, wheel_dx, wheel_dy)
      break
    end
  end
end
