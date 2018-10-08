return function (x, y, radius, color)
  love.graphics.setLineStyle("smooth")
  love.graphics.setLineWidth(1)
  if color then love.graphics.setColor(color) end
  love.graphics.circle("fill", x, y, radius)
  love.graphics.circle("line", x, y, radius)
end
