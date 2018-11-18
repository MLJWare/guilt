local path = (...)
local sub1 = path:match("(.-)%.[^%.]+$")
local sub2 = sub1:match("(.-)%.[^%.]+$")
local sub3 = sub2:match("(.-)%.[^%.]+$")
local sub4 = sub3:match("(.-)%.[^%.]+$")

local smooth_line             = require (sub2..".utils.smooth_line")
local smooth_rectangle        = require (sub2..".utils.smooth_rectangle")

local guilt                   = require (sub3)
local pleasure                = require (sub3..".pleasure")
local NOP                     = require (sub3..".pleasure.NOP")

local rgb                     = require (sub4..".color.rgb")
local rgba                    = require (sub4..".color.rgba")
local clamp                   = require (sub4..".math.clamp")

local namespace = guilt.namespace("material-design")

local ScrollH = namespace:template("ScrollH"):needs{
  preferred_width = pleasure.need.non_negative_number;
}

ScrollH.align_y = 0.5

function ScrollH:init()
  self:set_progress(self.progress or 0)
  self.knob_width = self.knob_width or 40
  self.preferred_height = self.preferred_height or 9
end

function ScrollH:set_progress(progress, no_event)
  local old_progress = self.progress
  self.progress = (progress == progress)
              and clamp(progress, 0, 1)
               or 0
  if no_event then return end
  pleasure.try.invoke(self, "on_change", old_progress)
end

function ScrollH:draw()
  local x, y, width, height = self:bounds()
  local knob_width = self.knob_width
  local knob_x = x + (width - knob_width)*self.progress

  self:draw_bar(x, y, width, height, knob_x, knob_width)
  self:draw_knob(x, y, width, height, knob_x, knob_width)
end

function ScrollH.draw_bar(_, x, y, width, height, _, _)
  smooth_line(x, y + height/2, x + width, y + height/2, 1, rgb(6, 138, 79))
end

function ScrollH.draw_knob(_, _, y, _, height, knob_x, knob_width)
  local h = height - 2
  local r = h/2
  smooth_rectangle(knob_x, y+2, knob_width, h, r, rgba(0, 0, 0, 0.5))
  smooth_rectangle(knob_x, y+1, knob_width, h, r, rgb(13, 213, 109))
end

function ScrollH:mousedragged (mx, _, _, _, button1, _)
  if not button1 then return end
  local x, _, width = self:bounds()

  self:set_progress(((mx - self._knob_dx) - x)/(width - self.knob_width))
end

function ScrollH:mousepressed (mx, _, button_index)
  if button_index ~= 1 then return end

  local x, _, width, _ = self:bounds()
  local x2 = x + width

  local old_progress = self.progress
  local knob_width = self.knob_width

  local knob_x = x + (width - knob_width)*old_progress
  if knob_x <= mx and mx < knob_x + knob_width then
    self._knob_dx = mx - knob_x
    -- clicked on the knob, don't update `progress` value
  elseif x <= mx and mx < x2 then
    self._knob_dx = knob_width/2
    -- clicked directly on the line, update `progress` value
    self:set_progress((mx - x - knob_width/2)/(width - knob_width))
  end
end

ScrollH.mousereleased = NOP
ScrollH.mouseclicked  = NOP

namespace:finalize_template(ScrollH)
