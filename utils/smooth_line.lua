return function (x1, y1, x2, y2, width, color)
  love.graphics.setLineStyle("smooth")
  love.graphics.setLineWidth(width)
  if color then love.graphics.setColor(color) end
  love.graphics.line(x1, y1, x2, y2)
end
