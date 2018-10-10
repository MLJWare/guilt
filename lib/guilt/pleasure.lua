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
  local x, y, width, height = element:bounds()

  return x <= mx and mx < x + width
     and y <= my and my < y + height
end

-- TODO merge the stacks into one!
local _stack_sx = {}
local _stack_sy = {}
local _stack_sw = {}
local _stack_sh = {}
local _stack_tx = {}
local _stack_ty = {}

local _tx, _ty = 0, 0

function pleasure.translate(dx, dy)
  love.graphics.translate(dx, dy)
  _tx, _ty = _tx + dx, _ty + dy
end

function pleasure.push_region(x, y, w, h)
  local sx, sy, sw, sh = love.graphics.getScissor()
  table.insert(_stack_sx, sx)
  table.insert(_stack_sy, sy)
  table.insert(_stack_sw, sw)
  table.insert(_stack_sh, sh)
  table.insert(_stack_tx, _tx)
  table.insert(_stack_ty, _ty)

  love.graphics.push()
  love.graphics.intersectScissor(_tx + x, _ty + y, w, h)
  pleasure.translate(x, y)
end

function pleasure.pop_region()
  local sx = table.remove(_stack_sx)
  local sy = table.remove(_stack_sy)
  local sw = table.remove(_stack_sw)
  local sh = table.remove(_stack_sh)

  _tx = table.remove(_stack_tx) or 0
  _ty = table.remove(_stack_ty) or 0

  love.graphics.pop()
  if sx and sy and sw and sh then
    love.graphics.setScissor(sx, sy, sw, sh)
  else
    love.graphics.setScissor()
  end
end

return pleasure
