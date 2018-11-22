local path = (...)
local sub1 = path:match("(.-)%.[^%.]+$")
local sub2 = sub1:match("(.-)%.[^%.]+$")
local sub3 = sub2:match("(.-)%.[^%.]+$")
local sub4 = sub3:match("(.-)%.[^%.]+$")

local EditableText            = require (sub2..".component.EditableText")

local guilt                   = require (sub3)
local pleasure                = require (sub3..".pleasure")
local NOP                     = require (sub3..".pleasure.NOP")
local smooth_rectangle        = require (sub3..".sample-elements.utils.smooth_rectangle")

local rgb                     = require (sub4..".color.rgb")
local rgba                    = require (sub4..".color.rgba")

local namespace = guilt.namespace("material-design")

local Textfield = namespace:template("Textfield"):needs{
  hint   = pleasure.need.string;
}

Textfield.double_click_delay = 0.5

local min_width = 280
local preferred_height = 56

function Textfield:init()
  self.text   = ""
  self._edit_ = EditableText:new(self)
  self._edit_.drop_shadow = true
  self.preferred_width  = math.max(self.preferred_width or 0, min_width)
  self.preferred_height = preferred_height
end

function Textfield:set_text(text)
  self._edit_:set_text(text)
end

function Textfield:draw()
  if self.active then
    self:draw_active()
  else
    self:draw_default()
  end
end

function Textfield:text_as_shown()
  return self._edit_:text_as_shown()
end

function Textfield:draw_default ()
  self:draw_back()
  self._edit_:draw_default ()
end

function Textfield:draw_active ()
  self:draw_back()
  self._edit_:draw_active ()
end

function Textfield:draw_back()
  local x, y, width, height = self:bounds()
  smooth_rectangle(x, y + 1, width, height, 2, rgba(0, 0, 0, 0.62))
  smooth_rectangle(x, y, width, height, 2, rgb(255, 255, 255))
end

function Textfield:textinput (input)
  self._edit_:textinput (input)
end

function Textfield:keypressed (key, scancode, isrepeat)
  self._edit_:keypressed (key, scancode, isrepeat)
end

function Textfield:mousepressed (mx, my, button_index)
  self.active = true
  self._edit_:mousepressed (mx, my, button_index)
end

function Textfield:mousedragged (mx, my, dx, dy, button1, button2)
  self._edit_:mousedragged(mx, my, dx, dy, button1, button2)
end

Textfield.mouseclicked  = NOP

namespace:finalize_template(Textfield)
