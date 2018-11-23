local path = (...)
local sub1 = path:match("(.-)%.[^%.]+$")
local sub2 = sub1:match("(.-)%.[^%.]+$")
local sub3 = sub2:match("(.-)%.[^%.]+$")
local sub4 = sub3:match("(.-)%.[^%.]+$")

local smooth_circle        = require (sub2..".utils.smooth_circle")
local smooth_circle_outline= require (sub2..".utils.smooth_circle_outline")

local guilt                   = require (sub3)
local pleasure                = require (sub3..".pleasure")
local NOP                     = require (sub3..".pleasure.NOP")

local rgb                     = require (sub4..".color.rgb")
local rgba                    = require (sub4..".color.rgba")

local namespace = guilt.namespace("material-design")

local RadioButton = namespace:template("RadioButton"):needs{
  group = pleasure.need.kind("RadioGroup");
}

function RadioButton:init()
  self.preferred_width  = self.preferred_width  or 16
  self.preferred_height = self.preferred_height or self.preferred_width
  self.group:add_child(self)
end

function RadioButton:draw ()
  if self.checked then
    self:draw_checked()
  else
    self:draw_normal()
  end
end

function RadioButton:draw_normal()
  local x, y, width, height = self:bounds()
  local radius = math.min(width, height)/2
  x, y = x + radius, y + radius
  -- drop shadow
  smooth_circle_outline(x, y + 1, radius, 1, rgba(0,0,0,0.62))
  -- button
  smooth_circle_outline(x, y, radius, 1, rgb(56, 158, 255))
end

function RadioButton:draw_checked ()
  self:draw_normal()

  local x, y, width, height = self:bounds()
  local radius = math.min(width, height)/2
  x, y = x + radius, y + radius
  -- drop shadow
  smooth_circle(x, y + 1, radius - 4, rgba(0,0,0,0.62))
  -- button
  smooth_circle(x, y, radius - 4, rgb(56, 158, 255))
end

function RadioButton:mousepressed()
  self:select()
end

RadioButton.mousereleased = NOP
RadioButton.mouseclicked  = NOP

function RadioButton:select()
  self.group:select(self)
end

namespace:finalize_template(RadioButton)
