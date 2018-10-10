local subpath = (...):match("(.-)[^%.]+$")
local roboto                  = require (subpath.."roboto")

local smooth_rectangle        = require "utils.smooth_rectangle"
local font_writer             = require "utils.font_writer"

local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"

local Label = guilt.template("Label"):needs{
  text   = pleasure.need.string;
}

function Label:init()
  self.width  = roboto.body1:getWidth(self.text)
  self.height = roboto.body1:getHeight()
end

function Label:draw ()
  local x, y, width, height = self:bounds()
  local cx, cy = x + width/2, y + height/2
  love.graphics.setColor(self.color or  rgb(255, 255, 255))
  font_writer.print_aligned(roboto.body1, self.text, cx, cy, "middle", "center")
end

guilt.finalize_template(Label)
