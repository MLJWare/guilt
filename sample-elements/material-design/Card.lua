local subpath = (...):match("(.-)[^%.]+$")
local roboto                  = require (subpath.."roboto")

local smooth_rectangle              = require "utils.smooth_rectangle"
local font_writer             = require "utils.font_writer"

local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"

local Card = guilt.template("Card"):needs{
  x      = pleasure.need.number;
  y      = pleasure.need.number;
  width  = pleasure.need.non_negative_number;
  height = pleasure.need.non_negative_number;
}

local x_pad     = 16
local y_pad     = 16

function Card:init()
  if self.children then
    pleasure.need.table(self.children)
  else
    self.children = {}
  end
end

function Card:draw ()
  local cx, cy, width, height = self.x, self.y, self.width, self.height
  local x, y = cx - width/2, cy - height/2

  -- drop shadow
  smooth_rectangle(x, y+1, width, height, 2, rgba(0,0,0,0.62))
  -- card
  smooth_rectangle(x, y, width, height, 2, rgb(255, 255, 255))
  -- content
  love.graphics.push()
  local sx, sy, sw, sh = love.graphics.getScissor()
  love.graphics.intersectScissor(x, y, width, height)
  love.graphics.translate(x, y)
  for i, child in ipairs(self.children) do
    pleasure.try_invoke(child, "draw")
  end
  love.graphics.setScissor(sx, sy, sw, sh)
  love.graphics.pop()
end

function Card:mousepressed (mx, my, button, isTouch)
  --if not pleasure.contains(self, mx, my) then return end

  mx, my = mx - self.x + self.width/2, my - self.y + self.height/2
  for i, child in ipairs(self.children) do
    pleasure.try_invoke(child, "mousepressed", mx, my, button, isTouch)
  end
end

function Card:mousemoved (mx, my, dx, dy)
  if not pleasure.contains(self, mx, my) then return end

  mx, my = mx - self.x + self.width/2, my - self.y + self.height/2
  for i, child in ipairs(self.children) do
    pleasure.try_invoke(child, "mousemoved", mx, my, dx, dy)
  end
end

function Card:mousereleased (mx, my, button, isTouch)
  if not pleasure.contains(self, mx, my) then return end

  mx, my = mx - self.x + self.width/2, my - self.y + self.height/2
  for i, child in ipairs(self.children) do
    pleasure.try_invoke(child, "mousereleased", mx, my, button, isTouch)
  end
end

function Card:keypressed (key, scancode, isrepeat)
  for i, child in ipairs(self.children) do
    pleasure.try_invoke(child, "keypressed", key, scancode, isrepeat)
  end
end

function Card:keyreleased (key)
  for i, child in ipairs(self.children) do
    pleasure.try_invoke(child, "keyreleased", key)
  end
end

function Card:textinput (input)
  for i, child in ipairs(self.children) do
    pleasure.try_invoke(child, "textinput", input)
  end
end

guilt.finalize_template(Card)
