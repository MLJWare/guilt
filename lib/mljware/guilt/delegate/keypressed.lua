local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")
local is_callable = require (subsubpath.."pleasure.is").callable

return function (self, key, scancode, isRepeat)
  for _, child in self:children() do
    if child.active and is_callable(child.keypressed) then
      child:keypressed(key, scancode, isRepeat)
    end
  end
end
