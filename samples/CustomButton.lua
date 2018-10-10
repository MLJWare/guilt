local roboto                  = require ("sample-elements.material-design.roboto")

local smooth_rectangle        = require "utils.smooth_rectangle"
local font_writer             = require "utils.font_writer"

local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"

-- Example showing how to extend/override existing UI elements using the
-- `Template:from` method.

local StyleButton = guilt.template("StyleButton"):from("Button"):needs{
  color_normal  = pleasure.need.table;
  color_pressed = pleasure.need.table;
}

function StyleButton:draw_normal()
  local x, y, width, height = self:bounds()
  local cx, cy = x + width/2, y + height/2

  -- drop shadow
  smooth_rectangle(x, y, width, height, 2, rgba(0,0,0,0.62))
  -- button
  smooth_rectangle(x, y-1, width, height, 2, self.color_normal)
  love.graphics.setColor(1, 1, 1)
  font_writer.print_aligned(roboto.button, self.text:upper(), cx, cy, "middle", "center")
end

function StyleButton:draw_pressed ()
  local x, y, width, height = self:bounds()
  local cx, cy = x + width/2, y + height/2

  smooth_rectangle(x, y, width, height, 2, self.color_pressed)
  love.graphics.setColor(1,1,1)
  font_writer.print_aligned(roboto.button, self.text:upper(), cx, cy, "middle", "center")
end

guilt.finalize_template(StyleButton)
