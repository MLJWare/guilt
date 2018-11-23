return function (x, y, radius, line_width, color)
  love.graphics.setLineStyle("smooth")
  love.graphics.setLineWidth(line_width)
  if color then love.graphics.setColor(color) end
  love.graphics.circle("line", x, y, radius, radius*4)
end
