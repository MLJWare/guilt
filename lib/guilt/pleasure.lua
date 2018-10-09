local path = (...)
local is                      = require (path..".is")
local try                     = require (path..".try")
local need                    = require (path..".need")

local pleasure = {
  is    = is;
  try   = try;
  need  = need;
}

function pleasure.contains(element, mx, my)
  return math.abs(element.x - mx) <= element.width/2
     and math.abs(element.y - my) <= element.height/2
end

-- TODO merge the stacks into one!
local _stack_x = {}
local _stack_y = {}
local _stack_w = {}
local _stack_h = {}
function pleasure.push_region(x, y, w, h)
  local sx, sy, sw, sh = love.graphics.getScissor()
  table.insert(_stack_x, sx)
  table.insert(_stack_y, sy)
  table.insert(_stack_w, sw)
  table.insert(_stack_h, sh)

  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.intersectScissor((sx or 0) + x, (sy or 0) + y, w, h)
end

function pleasure.pop_region()
  local sx = table.remove(_stack_x)
  local sy = table.remove(_stack_y)
  local sw = table.remove(_stack_w)
  local sh = table.remove(_stack_h)

  love.graphics.pop()
  if sx and sy and sw and sh then
    love.graphics.setScissor(sx, sy, sw, sh)
  else
    love.graphics.setScissor()
  end
end

return pleasure
