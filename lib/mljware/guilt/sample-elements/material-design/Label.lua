local path = (...)
local sub1 = path:match("(.-)%.[^%.]+$")
local sub2 = sub1:match("(.-)%.[^%.]+$")
local sub3 = sub2:match("(.-)%.[^%.]+$")
local sub4 = sub3:match("(.-)%.[^%.]+$")

local roboto                  = require (sub1..".roboto")

local smooth_rectangle        = require (sub2..".utils.smooth_rectangle")
local font_writer             = require (sub2..".utils.font_writer")

local guilt                   = require (sub3)
local pleasure                = require (sub3..".pleasure")

local rgb                     = require (sub4..".color.rgb")
local rgba                    = require (sub4..".color.rgba")

local namespace = guilt.namespace("material-design")

local Label = namespace:template("Label"):needs{
  text   = pleasure.need.string;
}

Label.font = roboto.body1
Label.text_color = rgb(255, 255, 255)

function Label:init()
  self.preferred_width  = math.max(self.preferred_width or 0, self.font:getWidth(self.text))
  self.preferred_height = self.font:getHeight()
end

function Label:draw ()
  local x, y, width, height = self:bounds()
  local cx, cy = x + width/2, y + height/2
  love.graphics.setColor(self.text_color)
  font_writer.print_aligned(self.font, self.text, cx, cy, "middle", "center")
end

namespace:finalize_template(Label)
