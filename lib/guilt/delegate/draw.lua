local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local pleasure                = require (subsubpath.."pleasure")

local contains    = pleasure.contains
local is_callable = pleasure.is.callable
local try_invoke  = pleasure.try.invoke

return function (self)
  pleasure.push_region(self:bounds())
  for _, child, region_x, region_y, region_width, region_height in self:children() do
    -- TODO scale the offsets?
    pleasure.push_region(region_x, region_y, region_width, region_height)
    try_invoke(child, "draw")
    pleasure.pop_region()
  end
  pleasure.pop_region()
end
