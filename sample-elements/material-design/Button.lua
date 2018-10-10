local subpath = (...):match("(.-)[^%.]+$")
local roboto                  = require (subpath.."roboto")

local smooth_rectangle        = require "utils.smooth_rectangle"
local font_writer             = require "utils.font_writer"

local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"

local Button = guilt.template("Button"):needs{
  text   = pleasure.need.string;
}

local min_width = 64
local height    = 36
local x_pad     = 16

function Button:init()
  self.width  = math.max(min_width, roboto.button:getWidth(self.text) + 2*x_pad)
  self.height = height
end


function Button:draw ()
  if self.pressed1 then
    self:draw_pressed()
  else
    self:draw_normal()
  end
end

function Button:draw_normal()
  local x, y, width, height = self:bounds()
  local cx, cy = x + width/2, y + height/2

  -- drop shadow
  smooth_rectangle(x, y, width, height, 2, rgba(0,0,0,0.62))
  -- button
  smooth_rectangle(x, y-1, width, height, 2, rgb(56, 158, 255))
  love.graphics.setColor(1, 1, 1)
  font_writer.print_aligned(roboto.button, self.text:upper(), cx, cy, "middle", "center")
end

function Button:draw_hover ()
  local x, y, width, height = self:bounds()
  local cx, cy = x + width/2, y + height/2

  -- drop shadow
  smooth_rectangle(x, y+1, width, height, 2, rgba(0,0,0,0.62))
  -- button
  smooth_rectangle(x, y, width, height, 2, rgb(42, 147, 247))
  love.graphics.setColor(1, 1, 1)
  font_writer.print_aligned(roboto.button, self.text:upper(), cx, cy, "middle", "center")
end

function Button:draw_pressed ()
  local x, y, width, height = self:bounds()
  local cx, cy = x + width/2, y + height/2

  smooth_rectangle(x, y, width, height, 2, rgb(0, 116, 225))
  love.graphics.setColor(1,1,1)
  font_writer.print_aligned(roboto.button, self.text:upper(), cx, cy, "middle", "center")
end

guilt.finalize_template(Button)
