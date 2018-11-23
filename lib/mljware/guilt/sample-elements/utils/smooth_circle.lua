return function (x, y, radius, color)
  love.graphics.setLineStyle("smooth")
  love.graphics.setLineWidth(1)
  if color then love.graphics.setColor(color) end
  local segments = radius*4
  love.graphics.circle("fill", x, y, radius, segments)
  love.graphics.circle("line", x, y, radius, segments)
end
