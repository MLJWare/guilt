local path = (...)
local sub1 = path:match("(.-)%.[^%.]+$")
local sub2 = sub1:match("(.-)%.[^%.]+$")
local sub3 = sub2:match("(.-)%.[^%.]+$")
local sub4 = sub3:match("(.-)%.[^%.]+$")

local smooth_rectangle        = require (sub2..".utils.smooth_rectangle")
local smooth_rectangle_outline= require (sub2..".utils.smooth_rectangle_outline")

local guilt                   = require (sub3)
local pleasure                = require (sub3..".pleasure")

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
  -- drop shadow
  smooth_rectangle_outline(x, y + 1, width, height, 2, 1, rgba(0,0,0,0.62))
  -- button
  smooth_rectangle_outline(x, y, width, height, 2, 1, rgb(56, 158, 255))
end

function RadioButton:draw_checked ()
  local x, y, width, height = self:bounds()
  -- drop shadow
  smooth_rectangle(x, y + 1, width, height, 2, rgba(0,0,0,0.62))
  -- button
  smooth_rectangle(x, y, width, height, 2, rgb(56, 158, 255))
end

function RadioButton:mousepressed()
  self:select()
end

function RadioButton:select()
  self.group:select(self)
end

namespace:finalize_template(RadioButton)
