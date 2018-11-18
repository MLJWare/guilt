local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")
local is_callable = require (subsubpath.."pleasure.is").callable

return function (self, input)
  for _, child in self:children() do
    if child.active and is_callable(child.textinput) then
      child:textinput(input)
    end
  end
end
