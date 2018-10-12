return function (x, y, w, h, r, line_width, color)
  love.graphics.setLineStyle("smooth")
  love.graphics.setLineWidth(line_width)
  if color then love.graphics.setColor(color) end
  love.graphics.rectangle("line", x, y, w, h, r, r)
end
