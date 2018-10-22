local path = (...)
local sub1 = path:match("(.-)%.[^%.]+$")
local sub2 = sub1:match("(.-)%.[^%.]+$")
local sub3 = sub2:match("(.-)%.[^%.]+$")
local sub4 = sub3:match("(.-)%.[^%.]+$")

local roboto                  = require (sub1..".roboto")

local smooth_line             = require (sub2..".utils.smooth_line")
local smooth_circle           = require (sub2..".utils.smooth_circle")
local smooth_rectangle        = require (sub2..".utils.smooth_rectangle")

local guilt                   = require (sub3)
local pleasure                = require (sub3..".pleasure")

local rgb                     = require (sub4..".color.rgb")
local rgba                    = require (sub4..".color.rgba")
local clamp                   = require (sub4..".math.clamp")

local ScrollV = guilt.template("ScrollV"):needs{
  preferred_height = pleasure.need.non_negative_number;
}

ScrollV.align_x = 0.5

function ScrollV:init()
  self:set_progress(self.progress or 0)
  self.knob_height = self.knob_height or 40
  self.preferred_width = self.preferred_width or 9
end

function ScrollV:set_progress(progress)
  self.progress = (progress == progress)
              and clamp(progress, 0, 1)
               or 0
end

function ScrollV:draw()
  local x, y, width, height = self:bounds()
  local knob_height = self.knob_height
  local knob_y = y + (height - knob_height)*self.progress

  local r1 = (width-1)/2
  local r2 = (width-2)/2

  -- bar
  smooth_line(x + width/2, y, x + width/2, y + height, 1, rgb(6, 138, 79))

  --knob
  smooth_rectangle(x, knob_y+2, width, knob_height - 2, r2, rgba(0, 0, 0, 0.5))
  smooth_rectangle(x, knob_y+1, width, knob_height - 2, r2, rgb(13, 213, 109))
end

function ScrollV:mousedragged (mx, my, dx, dy, button1, button2)
  if not button1 then return end
  local old_progress = self.progress

  local _, y, _, height = self:bounds()

  self:set_progress(((my - self._knob_dy) - y)/(height - self.knob_height))
  pleasure.try.invoke(self, "on_change", old_progress)
end

function ScrollV:mousepressed (mx, my, button_index)
  if button_index ~= 1 then return end

  local x, y, width, height = self:bounds()
  local y2 = y + height

  local old_progress = self.progress
  local knob_height = self.knob_height

  local knob_x = x + width/2
  local knob_y = y + (height - knob_height)*old_progress
  if knob_y <= my and my < knob_y + knob_height then
    self._knob_dy = my - knob_y
    -- clicked on the knob, don't update `progress` value
  elseif y <= my and my < y2 then
    self._knob_dy = knob_height/2
    -- clicked directly on the line, update `progress` value
    self:set_progress((my - y - knob_height/2)/(height - knob_height))
    pleasure.try.invoke(self, "on_change", old_progress)
  end
end

guilt.finalize_template(ScrollV)
