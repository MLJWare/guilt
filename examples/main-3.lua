love.graphics.setDefaultFilter("nearest", "nearest")

local guilt                   = require "lib.mljware.guilt"
local pleasure                = require "lib.mljware.guilt.pleasure"
local rgb                     = require "lib.mljware.color.rgb"
local smooth_rectangle        = require "lib.mljware.guilt.sample-elements.utils.smooth_rectangle"

local try_invoke  = pleasure.try.invoke

require "lib.mljware.guilt.sample-elements.material-design"
require "lib.mljware.guilt.sample-elements.layout"
require "samples"

local gui, card, textfield, scroll_h, scroll_v
local square

local material = guilt.namespace("material-design")

function love.load(arg)
  local w, h = love.graphics.getDimensions()

  love.keyboard.setKeyRepeat(true)

  square = {x = 0, y = 0}

  gui = guilt.gui{
    render_scale = 1;
    x      = 0;
    y      = 0;
    preferred_width  = w;
    preferred_height = h;
    resize = function (self, display_width, display_height)
      self.preferred_width  = display_width/self.render_scale;
      self.preferred_height = display_height/self.render_scale;
    end;
  }

  card = gui:new(material.Card, {
    anchor_x = 0.5;
    align_x = 0.5;
    anchor_y = 0.4;
    align_y = 0.5;
    preferred_width  = 300;
    preferred_height = 400;
  })

  textfield = gui:new(material.Textfield, {
    preferred_width = 200;
    anchor_x = 0.5;
    align_x  = 0.5;
    anchor_y = 0.8;
    hint = "";
  })

  scroll_h = gui:new(material.ScrollH, {
    x = 50;
    y = 260;
    preferred_width = 200;
    progress = 0.5;
    knob_width = 100;
    on_change = function (self, old_progress)
      square.x = math.floor(self.progress*150 + 0.5)
      textfield:set_text(("%d, %d"):format(square.x, square.y))
    end;
  })
  scroll_h:on_change()

  scroll_v = gui:new(material.ScrollV, {
    x = 260;
    y = 50;
    preferred_height = 200;
    progress = 0.5;
    knob_height = 100;
    on_change = function (self, old_progress)
      square.y = math.floor(self.progress*150 + 0.5)
      textfield:set_text(("%d, %d"):format(square.x, square.y))
    end;
  })
  scroll_v:on_change()

  card:add_children(
    scroll_h,
    scroll_v,
    textfield
  )

  gui:add_children(
    card
  )
end

function love.wheelmoved(dx, dy)
  scroll_h.knob_width  = math.max(10, math.min(scroll_h.knob_width  - dx, scroll_h.preferred_width ))
  scroll_v.knob_height = math.max(10, math.min(scroll_v.knob_height + dy, scroll_v.preferred_height))
end

for i, callback in ipairs{
  "keypressed";
  "keyreleased";
  "mousemoved";
  "mousepressed";
  "mousereleased";
  "resize";
  "textinput";
} do
  love[callback] = function (...)
    local width, height = love.graphics.getDimensions()
    try_invoke(gui, callback, ...)
  end
end

function love.draw()
  love.graphics.clear(rgb(226, 225, 223))
  try_invoke(gui, "draw")
  local x1, y1 = gui:bounds()
  local x2, y2 = card:bounds()

  local x = x1 + x2 + square.x + 50
  local y = y1 + y2 + square.y + 50
  smooth_rectangle(x, y, 50, 50, 5, rgb(255, 178, 87))
end
