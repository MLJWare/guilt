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
local delegate_draw           = require (sub4..".guilt.delegate.draw")

local is_callable = pleasure.is.callable

local Card = guilt.template("Card")

function Card:init()
  if self._children then
    pleasure.need.table(self._children)
  else
    self._children = {}
  end
end

function Card:child_at_index(index)
  return self._children[index]
end

function Card:draw ()
  local x, y, width, height = self:bounds()

  -- drop shadow
  smooth_rectangle(x, y+1, width, height, 2, rgba(0,0,0,0.62))
  -- card
  smooth_rectangle(x, y, width, height, 2, rgb(255, 255, 255))
  -- content
  delegate_draw(self)
end

Card.mousepressed  = require "lib.mljware.guilt.delegate.mousepressed"
Card.mousemoved    = require "lib.mljware.guilt.delegate.mousemoved"
Card.mousereleased = require "lib.mljware.guilt.delegate.mousereleased"
Card.textinput     = require "lib.mljware.guilt.delegate.textinput"
Card.keypressed    = require "lib.mljware.guilt.delegate.keypressed"
Card.keyreleased   = require "lib.mljware.guilt.delegate.keyreleased"

guilt.finalize_template(Card)
