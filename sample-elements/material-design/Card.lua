local subpath = (...):match("(.-)[^%.]+$")
local roboto                  = require (subpath.."roboto")

local smooth_rectangle        = require "utils.smooth_rectangle"
local font_writer             = require "utils.font_writer"

local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"

local is_callable = pleasure.is.callable

local Card = guilt.template("Card")

function Card:init()
  if self._children then
    pleasure.need.table(self._children)
  else
    self._children = {}
  end
end

function Card:draw ()
  local x, y, width, height = self:bounds()

  -- drop shadow
  smooth_rectangle(x, y+1, width, height, 2, rgba(0,0,0,0.62))
  -- card
  smooth_rectangle(x, y, width, height, 2, rgb(255, 255, 255))
  -- content
  pleasure.push_region(x, y, width, height)
  for i, child in self:children() do
    pleasure.try.invoke(child, "draw")
  end
  pleasure.pop_region()
end

Card.mousepressed  = require "lib.guilt.delegate.mousepressed"
Card.mousemoved    = require "lib.guilt.delegate.mousemoved"
Card.mousereleased = require "lib.guilt.delegate.mousereleased"
Card.textinput     = require "lib.guilt.delegate.textinput"
Card.keypressed    = require "lib.guilt.delegate.keypressed"
Card.keyreleased   = require "lib.guilt.delegate.keyreleased"

guilt.finalize_template(Card)
