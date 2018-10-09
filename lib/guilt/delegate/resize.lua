local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")
local is_callable = require (subsubpath.."pleasure.is").callable

return function (self, display_width, display_height)
  for i, child in ipairs(self.children) do
    if is_callable(child.resize) then
      child:resize(display_width, display_height)
    end
  end
end
