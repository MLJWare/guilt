local subpath = (...):match("(.-)[^%.]+$")
local roboto                  = require (subpath.."roboto")

local smooth_line             = require "utils.smooth_line"
local smooth_circle           = require "utils.smooth_circle"

local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"
local clamp                   = require "lib.math.clamp"

local SliderH = guilt.template("SliderH"):needs{
  progress = pleasure.need.non_negative_number;
}

SliderH.knob_radius      = 6
SliderH.knob_radius_held = 9

SliderH.align_y = 0.5

SliderH.knob_color      = rgb(0, 81, 157)
SliderH.bar_color_left  = rgb(0, 81, 157)
SliderH.bar_color_right = rgba(0, 0, 0, 0.5)

function SliderH:init()
  self:set_progress(self.progress)
  if not self.preferred_height then
    self.preferred_height = self.knob_radius*2
  end
end

function SliderH:set_progress(progress)
  self.progress = clamp(progress, 0, 1)
end

function SliderH:draw()
  local x, y, width, height = self:bounds()
  local knob_x = x + width*self.progress
  local knob_y = y + height/2
  self:draw_bar(x, y, width, height, knob_x, knob_y)
  self:draw_knob(knob_x, knob_y, x, y, width, height)
end

function SliderH:draw_knob(knob_x, knob_y, x, y, width, height)
  local radius = self.pressed1
             and self.knob_radius_held
              or self.knob_radius

  smooth_circle(knob_x, knob_y, radius, self.knob_color)
end

function SliderH:draw_bar(x, y, width, height, knob_x, knob_y)
  local x2     = x + width
  smooth_line(x, knob_y, knob_x, knob_y, 2, self.bar_color_left)
  smooth_line(knob_x, knob_y, x2, knob_y, 2, self.bar_color_right)
end

function SliderH:mousedragged (mx, my, dx, dy, button1, button2)
  if not button1 then return end
  local old_progress = self.progress

  local x, _, width = self:bounds()

  self:set_progress((mx - x)/width)
  pleasure.try.invoke(self, "on_change", old_progress)
end

function SliderH:mousepressed (mx, my, button_index)
  if button_index ~= 1 then return end

  local x1, y, width, height = self:bounds()
  local old_progress = self.progress

  local x2, knob_x = x1 + width, x1 + width*old_progress

  local knob_radius = self.knob_radius
  if math.abs(knob_x - mx) <= knob_radius then
    -- clicked on the knob, don't update `progress` value
  elseif mx >= x1 - knob_radius and mx <= x2 + knob_radius then
    -- clicked directly on the line, update `progress` value
    self:set_progress((mx - x1)/width)
    pleasure.try.invoke(self, "on_change", old_progress)
  end
end

guilt.finalize_template(SliderH)
