local subpath = (...):match("(.-)[^%.]+$")
local roboto                  = require (subpath.."roboto")

local smooth_rectangle        = require "utils.smooth_rectangle"
local font_writer             = require "utils.font_writer"

local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"

local Label = guilt.template("Label"):needs{
  x      = pleasure.need.number;
  y      = pleasure.need.number;
  text   = pleasure.need.string;
}

function Label:init()
  self.width  = roboto.body1:getWidth(self.text)
  self.height = roboto.body1:getHeight()
end

function Label:draw ()
  local cx, cy, width, height = self.x, self.y, self.width, self.height
  love.graphics.setColor(self.color or  rgb(255, 255, 255))
  font_writer.print_aligned(roboto.body1, self.text, cx, cy, "middle", "center")
end

guilt.finalize_template(Label)
