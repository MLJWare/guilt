local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")
local is_callable = require (subsubpath.."pleasure.is").callable

return function (self, key)
  for i, child in self:children() do
    if child.active and is_callable(child.keyreleased) then
      child:keyreleased(key)
    end
  end
end
