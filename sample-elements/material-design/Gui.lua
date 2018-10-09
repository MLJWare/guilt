local subpath = (...):match("(.-)[^%.]+$")
local roboto                  = require (subpath.."roboto")

local smooth_rectangle              = require "utils.smooth_rectangle"
local font_writer             = require "utils.font_writer"

local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"

local is_callable = pleasure.is.callable

local Gui = guilt.template("Gui")

function Gui:init()
  if self.children then
    pleasure.need.table(self.children)
  else
    self.children = {}
  end
end

function Gui:draw ()
  local cx, cy, width, height = self.x, self.y, self.width, self.height
  local x, y = cx - width/2, cy - height/2

  pleasure.push_region(x, y, width, height)
  for i, child in ipairs(self.children) do
    pleasure.try.invoke(child, "draw")
  end
  pleasure.pop_region()
end

Gui.resize        = require "lib.guilt.delegate.resize"
Gui.mousepressed  = require "lib.guilt.delegate.mousepressed"
Gui.mousemoved    = require "lib.guilt.delegate.mousemoved"
Gui.mousereleased = require "lib.guilt.delegate.mousereleased"
Gui.textinput     = require "lib.guilt.delegate.textinput"
Gui.keypressed    = require "lib.guilt.delegate.keypressed"
Gui.keyreleased   = require "lib.guilt.delegate.keyreleased"

guilt.finalize_template(Gui)
