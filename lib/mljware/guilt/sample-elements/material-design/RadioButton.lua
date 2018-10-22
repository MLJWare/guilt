local path = (...)
local sub1 = path:match("(.-)%.[^%.]+$")
local sub2 = sub1:match("(.-)%.[^%.]+$")
local sub3 = sub2:match("(.-)%.[^%.]+$")
local sub4 = sub3:match("(.-)%.[^%.]+$")

local roboto                  = require (sub1..".roboto")

local smooth_rectangle        = require (sub2..".utils.smooth_rectangle")
local smooth_rectangle_outline= require (sub2..".utils.smooth_rectangle_outline")
local font_writer             = require (sub2..".utils.font_writer")

local guilt                   = require (sub3)
local pleasure                = require (sub3..".pleasure")

local rgb                     = require (sub4..".color.rgb")
local rgba                    = require (sub4..".color.rgba")

local RadioButton = guilt.template("RadioButton"):needs{
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
  local cx, cy = x + width/2, y + height/2

  -- drop shadow
  smooth_rectangle_outline(x, y + 1, width, height, 2, 1, rgba(0,0,0,0.62))
  -- button
  smooth_rectangle_outline(x, y, width, height, 2, 1, rgb(56, 158, 255))
end

function RadioButton:draw_checked ()
  local x, y, width, height = self:bounds()
  local cx, cy = x + width/2, y + height/2

  local off = math.min(width, height)/5

  local x2, y2, width2, height2 = x + off, y + off, width - 2*off, height - 2*off

  -- drop shadow
  smooth_rectangle(x, y + 1, width, height, 2, rgba(0,0,0,0.62))
  -- button
  smooth_rectangle(x, y, width, height, 2, rgb(56, 158, 255))
end

function RadioButton:mousepressed(mx, my, button)
  self:select()
end

function RadioButton:select()
  self.group:select(self)
end

guilt.finalize_template(RadioButton)
