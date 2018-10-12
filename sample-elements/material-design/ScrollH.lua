local subpath = (...):match("(.-)[^%.]+$")
local roboto                  = require (subpath.."roboto")

local smooth_line             = require "utils.smooth_line"
local smooth_circle           = require "utils.smooth_circle"
local smooth_rectangle        = require "utils.smooth_rectangle"

local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"
local clamp                   = require "lib.math.clamp"

local ScrollH = guilt.template("ScrollH"):needs{
  preferred_width = pleasure.need.non_negative_number;
}

ScrollH.align_y = 0.5

function ScrollH:init()
  self:set_progress(self.progress or 0)
  self.knob_width = self.knob_width or 40
  self.preferred_height = self.preferred_height or 9
end

function ScrollH:set_progress(progress)
  self.progress = (progress == progress)
              and clamp(progress, 0, 1)
               or 0
end

function ScrollH:draw()
  local x, y, width, height = self:bounds()
  local knob_width = self.knob_width
  local knob_x = x + (width - knob_width)*self.progress

  local r1 = (height-1)/2
  local r2 = (height-2)/2

  -- bar
  smooth_line(x, y + height/2, x + width, y + height/2, 1, rgb(6, 138, 79))

  -- shadow knob
  smooth_rectangle(knob_x, y+2, knob_width, height - 2, r2, rgba(0, 0, 0, 0.5))
  smooth_rectangle(knob_x, y+1, knob_width, height - 2, r2, rgb(13, 213, 109))
end

function ScrollH:mousedragged (mx, my, dx, dy, button1, button2)
  if not button1 then return end
  local old_progress = self.progress

  local x, _, width = self:bounds()

  self:set_progress(((mx - self._knob_dx) - x)/(width - self.knob_width))
  pleasure.try.invoke(self, "on_change", old_progress)
end

function ScrollH:mousepressed (mx, my, button_index)
  if button_index ~= 1 then return end

  local x, y, width, height = self:bounds()
  local x2 = x + width

  local old_progress = self.progress
  local knob_width = self.knob_width

  local knob_x = x + (width - knob_width)*old_progress
  local knob_y = y + height/2
  if knob_x <= mx and mx < knob_x + knob_width then
    self._knob_dx = mx - knob_x
    -- clicked on the knob, don't update `progress` value
  elseif x <= mx and mx < x2 then
    self._knob_dx = knob_width/2
    -- clicked directly on the line, update `progress` value
    self:set_progress((mx - x - knob_width/2)/(width - knob_width))
    pleasure.try.invoke(self, "on_change", old_progress)
  end
end

guilt.finalize_template(ScrollH)
