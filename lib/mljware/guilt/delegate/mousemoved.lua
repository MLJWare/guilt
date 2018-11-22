local subsubpath = (...):match("(.-)[^%.]+%.[^%.]+$")

local ensure = require (subsubpath.."pleasure.ensure")

local is_callable
do
  local pleasure = require (subsubpath.."pleasure")
  is_callable = pleasure.is.callable
end

return function (self, mx, my, dx, dy)
  --TODO mouse enter/exit

  local x, y = self:bounds()
  mx, my = mx - x, my - y

  local gui = self._guilt_gui_
  local gui_hovered_bag  = ensure(gui.tags, "hovered")

  local not_found = true
  for _, child in self:children() do
    -- TODO ensure [mx, my] contained in region
    if  not_found
    and child:contains(mx, my) then
      gui_hovered_bag[child] = true
      if  not child.hovered
      and is_callable(child.mouseenter) then
        child:mouseenter(mx, my, dx, dy)
      end
      child.hovered = true
      if is_callable(child.mousemoved) then
        child:mousemoved(mx, my, dx, dy)
        not_found = false
      end
    else
      gui_hovered_bag[child] = nil
      if  child.hovered
      and is_callable(child.mouseleave) then
        child:mouseleave(mx, my, dx, dy)
      end
      child.hovered = nil
    end
  end

  return not not_found
end
