local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local pleasure                = require (subsubpath.."pleasure")

local try_invoke  = pleasure.try.invoke

return function (self)
  pleasure.push_region(self:bounds())
  for _, child, region_x, region_y, region_width, region_height in self:reverse_children() do
    -- TODO scale the offsets?
    pleasure.push_region(region_x, region_y, region_width, region_height)
    try_invoke(child, "draw")
    pleasure.pop_region()
  end
  pleasure.pop_region()
end
