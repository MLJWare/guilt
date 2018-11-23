local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local try_invoke              = require (subsubpath.."pleasure.try").invoke

return function (self, parent_width, parent_height)
  self.preferred_width  = parent_width
  self.preferred_height = parent_height
  for _, child in self:children() do
    try_invoke(child, "resize", parent_width, parent_height)
  end
end
