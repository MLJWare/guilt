local font_writer = {}

local alignment = {
  ["top"   ] =  0;
  ["left"  ] =  0;
  ["middle"] = -0.5;
  ["center"] = -0.5;
  ["bottom"] = -1;
  ["right" ] = -1;
}

function font_writer.print_aligned(font, text, x, y, align_x, align_y)
  local line_count = (select(2, text:gsub('\n', '\n')) or 0) + 1
  local width  = font:getWidth(text)
  local height = font:getHeight()*line_count

  local dx = alignment[align_x or "left"] or 0
  local dy = alignment[align_y or "top" ] or 0

  love.graphics.setFont(font)
  love.graphics.print(text, x + dx*width, y + dy*height)
end

function font_writer.print(font, text, x, y, r, ox, oy, kx, ky)
  love.graphics.setFont(font)
  love.graphics.print(text, x, y, r, 1, 1, ox, oy, kx, ky)
end

return font_writer
