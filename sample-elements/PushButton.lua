local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"

local smooth_rectangle              = require "utils.smooth_rectangle"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"

local PushButton = guilt.template("PushButton"):needs{
  x      = pleasure.need.number;
  y      = pleasure.need.number;
  width  = pleasure.need.non_negative_number;
  height = pleasure.need.non_negative_number;
}

function PushButton:init()
  self.state = "unpressed"
end

function PushButton.draw : _always_ ()
  smooth_rectangle(self.x, self.y, self.width, self.height, 2, rgba(0,0,0,0.62))
end

function PushButton.draw : _default_ ()
  smooth_rectangle(self.x, self.y-1, self.width, self.height, 2, rgb(56, 158, 255))
end

function PushButton.draw : pressed ()
  smooth_rectangle(self.x  , self.y, self.width, self.height, 2, rgb(0, 116, 225))
end

function PushButton.mousepressed : unpressed (mx, my, button_index)
  if button_index == 1 and pleasure.contains(self, mx, my) then
    self.state = "pressed"
  end
end

function PushButton.mousereleased : pressed (mx, my, button_index)
  if button_index == 1 and pleasure.contains(self, mx, my) then
    pleasure.try_invoke(self, "on_click", mx, my)
  end
  self.state = "unpressed"
end

guilt.finalize_template(PushButton)
