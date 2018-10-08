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
  x        = pleasure.need.number;
  y        = pleasure.need.number;
  length   = pleasure.need.positive_number;
  progress = pleasure.need.non_negative_number;
}

local knob_radius      = 6
local knob_radius_held = 9

function SliderH:init()
  self.state = "normal"
  self:set_progress(self.progress)
end

function SliderH:set_progress(progress)
  self.progress = clamp(progress, 0, 1)
end

function SliderH:draw()
  local length, y = self.length, self.y
  local x1 = self.x - length/2
  local x2, knob_x = x1 + length, x1 + length*self.progress

  local radius = (self.state == "dragged")
             and knob_radius_held
              or knob_radius

  smooth_line(x1, y, knob_x, y, 2, rgb(0, 81, 157))
  smooth_line(knob_x, y, x2, y, 2, rgba(0, 0, 0, 0.5))
  -- knob
  smooth_circle(knob_x, y, knob_radius, rgb(0, 81, 157))
end

function SliderH.mousemoved : dragged (mx, my, dx, dy)
  local old_progress = self.progress
  self:set_progress((mx - self.x)/self.length + 0.5)
  pleasure.try_invoke(self, "on_change", old_progress)
end

function SliderH.mousepressed : normal (mx, my, button_index)
  if button_index ~= 1 then return end

  local y = self.y
  local dy = math.abs(y - my)
  if dy > knob_radius then return end


  local length, old_progress = self.length, self.progress
  local x1 = self.x - length/2
  local x2, knob_x = x1 + length, x1 + length*old_progress

  if math.abs(knob_x - mx) <= knob_radius then
    -- clicked on the knob, don't update `progress` value
    self.state = "dragged"
  elseif mx >= x1 - knob_radius and mx <= x2 + knob_radius then
    -- clicked directly on the line, update `progress` value
    self.state = "dragged"
    self:set_progress((mx - x1)/length)
    pleasure.try_invoke(self, "on_change", old_progress)
  end
end

function SliderH.mousereleased : dragged (mx, my, button_index)
  if button_index ~= 1 then return end
  self.state = "normal"
end

guilt.finalize_template(SliderH)
