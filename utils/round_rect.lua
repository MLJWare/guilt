return function (x, y, w, h, r, color)
  love.graphics.setLineStyle("smooth")
  love.graphics.setLineWidth(1)
  if color then love.graphics.setColor(color) end
  love.graphics.rectangle("fill", x, y, w, h, r, r)
  love.graphics.rectangle("line", x, y, w, h, r, r)
end
