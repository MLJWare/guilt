local path = (...)
local sub1 = path:match("(.-)%.[^%.]+$")
local sub2 = sub1:match("(.-)%.[^%.]+$")
local sub3 = sub2:match("(.-)%.[^%.]+$")
local sub4 = sub3:match("(.-)%.[^%.]+$")

local roboto                  = require (sub1..".roboto")

local smooth_rectangle        = require (sub2..".utils.smooth_rectangle")

local guilt                   = require (sub3)
local font_writer             = require (sub3..".font_writer")
local pleasure                = require (sub3..".pleasure")
local NOP                     = require (sub3..".pleasure.NOP")

local rgb                     = require (sub4..".color.rgb")
local rgba                    = require (sub4..".color.rgba")

local namespace = guilt.namespace("material-design")

local Button = namespace:template("Button"):needs{
  text   = pleasure.need.string;
}

Button.back_color_normal  = rgb( 56, 158, 255)
Button.back_color_hover   = rgb( 42, 147, 247)
Button.back_color_pressed = rgb(  0, 116, 225)

Button.text_color         = rgb(255, 255, 255)

local min_width        = 64
local preferred_height = 36
local x_pad            = 16

function Button:init()
  self.preferred_width  = math.max(min_width, roboto.button:getWidth(self.text) + 2*x_pad)
  self.preferred_height = preferred_height
end

function Button:draw ()
  if self.pressed then
    self:draw_pressed()
  elseif self.hovered then
    self:draw_hover()
  else
    self:draw_normal()
  end
end

function Button:draw_normal()
  local x, y, width, height = self:bounds()
  local cx, cy = x + width/2, y + height/2

  local back_color = self.back_color_normal
  local text_color = self.text_color

  -- drop shadow
  smooth_rectangle(x, y, width, height, 2, rgba(0,0,0,0.62))
  -- button
  smooth_rectangle(x, y-1, width, height, 2, back_color)
  love.graphics.setColor(text_color)
  font_writer.print_aligned(roboto.button, self.text:upper(), cx, cy, "middle", "center")
end

function Button:draw_hover ()
  local x, y, width, height = self:bounds()
  local cx, cy = x + width/2, y + height/2

  local back_color = self.back_color_hover
  local text_color = self.text_color_hover or self.text_color

  -- drop shadow
  smooth_rectangle(x, y, width, height, 2, rgba(0,0,0,0.62))
  -- button
  smooth_rectangle(x, y-1, width, height, 2, back_color)
  love.graphics.setColor(text_color)
  font_writer.print_aligned(roboto.button, self.text:upper(), cx, cy, "middle", "center")
end

function Button:draw_pressed ()
  local x, y, width, height = self:bounds()
  local cx, cy = x + width/2, y + height/2

  local back_color = self.back_color_pressed
  local text_color = self.text_color_pressed or self.text_color

  smooth_rectangle(x, y, width, height, 2, back_color)
  love.graphics.setColor(text_color)
  font_writer.print_aligned(roboto.button, self.text:upper(), cx, cy, "middle", "center")
end

Button.mousepressed  = NOP
Button.mousereleased = NOP
Button.mouseclicked  = NOP

namespace:finalize_template(Button)
