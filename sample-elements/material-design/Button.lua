local subpath = (...):match("(.-)[^%.]+$")
local roboto                  = require (subpath.."roboto")

local smooth_rectangle              = require "utils.smooth_rectangle"
local font_writer             = require "utils.font_writer"

local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"

local Button = guilt.template("Button"):needs{
  x      = pleasure.need.number;
  y      = pleasure.need.number;
  text   = pleasure.need.string;
}

local min_width = 64
local height    = 36
local x_pad     = 16

function Button:init()
  self.state  = "unpressed"
  self.width  = math.max(min_width, roboto.button:getWidth(self.text) + 2*x_pad)
  self.height = height
end

function Button.draw : _default_ ()
  local cx, cy, width, height = self.x, self.y-1, self.width, self.height
  local x, y = cx - width/2, cy - height/2

  -- drop shadow
  smooth_rectangle(x, y+1, width, height, 2, rgba(0,0,0,0.62))
  -- button
  smooth_rectangle(x, y, width, height, 2, rgb(56, 158, 255))
  love.graphics.setColor(1, 1, 1)
  font_writer.print_aligned(roboto.button, self.text:upper(), cx, cy, "middle", "center")
end

function Button.draw : hover ()
  local cx, cy, width, height = self.x, self.y-1, self.width, self.height
  local x, y = cx - width/2, cy - height/2

  -- drop shadow
  smooth_rectangle(x, y+1, width, height, 2, rgba(0,0,0,0.62))
  -- button
  smooth_rectangle(x, y, width, height, 2, rgb(42, 147, 247))
  love.graphics.setColor(1, 1, 1)
  font_writer.print_aligned(roboto.button, self.text:upper(), cx, cy, "middle", "center")
end

function Button.draw : pressed ()
  local cx, cy, width, height = self.x, self.y, self.width, self.height
  local x, y = cx - width/2, cy - height/2

  smooth_rectangle(x, y, width, height, 2, rgb(0, 116, 225))
  love.graphics.setColor(1,1,1)
  font_writer.print_aligned(roboto.button, self.text:upper(), cx, cy, "middle", "center")
end

function Button.mousemoved : unpressed (mx, my, dx, dy)
  if not pleasure.contains(self, mx, my) then return end
  self.state = "hover"
end

function Button.mousemoved : hover (mx, my, dx, dy)
  if pleasure.contains(self, mx, my) then return end
  self.state = "unpressed"
end

function Button.mousepressed : hover (mx, my, button_index)
  if button_index ~= 1 then return end
  self.state = "pressed"
end

function Button.mousereleased : pressed (mx, my, button_index)
  if button_index ~= 1 then return end

  if pleasure.contains(self, mx, my) then
    pleasure.try_invoke(self, "on_click", mx, my)
    self.state = "hover"
  else
    self.state = "unpressed"
  end
end

guilt.finalize_template(Button)
