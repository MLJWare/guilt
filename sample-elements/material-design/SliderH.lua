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

local knob_radius      = 6
local knob_radius_held = 9

SliderH.align_y = 0.5

function SliderH:init()
  self:set_progress(self.progress)
  self.height = knob_radius*2
end

function SliderH:set_progress(progress)
  self.progress = clamp(progress, 0, 1)
end

function SliderH:draw()
  local x1, y, width, height = self:bounds()
  local x2, knob_x = x1 + width, x1 + width*self.progress

  local radius = self.pressed1
             and knob_radius_held
              or knob_radius

  local y2 = y + height/2
  smooth_line(x1, y2, knob_x, y2, 2, rgb(0, 81, 157))
  smooth_line(knob_x, y2, x2, y2, 2, rgba(0, 0, 0, 0.5))
  -- knob
  smooth_circle(knob_x, y2, radius, rgb(0, 81, 157))
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
  local old_progress = self.width, self.progress

  local x2, knob_x = x1 + width, x1 + width*old_progress

  if math.abs(knob_x - mx) <= knob_radius then
    -- clicked on the knob, don't update `progress` value
  elseif mx >= x1 - knob_radius and mx <= x2 + knob_radius then
    -- clicked directly on the line, update `progress` value
    self:set_progress((mx - x1)/width)
    pleasure.try.invoke(self, "on_change", old_progress)
  end
end

guilt.finalize_template(SliderH)
