love.graphics.setDefaultFilter("nearest", "nearest")

local guilt                   = require "lib.mljware.guilt"
local pleasure                = require "lib.mljware.guilt.pleasure"
local rgb                     = require "lib.mljware.color.rgb"
local rgba                    = require "lib.mljware.color.rgba"
local smooth_rectangle        = require "lib.mljware.guilt.sample-elements.utils.smooth_rectangle"

local try_invoke  = pleasure.try.invoke
local contains    = pleasure.contains
local is_callable = pleasure.is.callable

require "lib.mljware.guilt.sample-elements.material-design"
require "lib.mljware.guilt.sample-elements.layout"
require "samples"

local gui, card, textfield, scroll_h, scroll_v
local square

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

  card = gui:new("Card", {
    anchor_x = 0.5;
    align_x = 0.5;
    anchor_y = 0.4;
    align_y = 0.5;
    preferred_width  = 300;
    preferred_height = 400;
  })

  info = gui:new("Textfield", {
    x =  10;
    y = 140;
    hint = "No selection";
    text_color = rgb(4, 114, 215);
    hint_color = rgba(4, 114, 215, 0.5);
  })

  local group = gui:new("RadioGroup", {
    on_change = function (self, selected, previous_selected)
      local element = card:child_at_index(selected.id*2)
      info.text = ("You selected: %q"):format(element.text)
    end
  })

  card:add_children(
    gui:new("RadioButton", { group = group; x = 20; y =  20; id = 1}),
    gui:new("Label", { x = 40; y =  20; text = "Option 1", text_color = rgb(4, 114, 215)}),
    gui:new("RadioButton", { group = group; x = 20; y =  40; id = 2}),
    gui:new("Label", { x = 40; y =  40; text = "Option 2", text_color = rgb(4, 114, 215)}),
    gui:new("RadioButton", { group = group; x = 20; y =  60; id = 3}),
    gui:new("Label", { x = 40; y =  60; text = "Option 3", text_color = rgb(4, 114, 215)}),
    gui:new("RadioButton", { group = group; x = 20; y =  80; id = 4}),
    gui:new("Label", { x = 40; y =  80; text = "Option 4", text_color = rgb(4, 114, 215)}),
    gui:new("RadioButton", { group = group; x = 20; y = 100; id = 5}),
    gui:new("Label", { x = 40; y = 100; text = "Option 5", text_color = rgb(4, 114, 215)}),
    gui:new("RadioButton", { group = group; x = 20; y = 120; id = 6}),
    gui:new("Label", { x = 40; y = 120; text = "Option 6", text_color = rgb(4, 114, 215)}),
    info
  )

  gui:add_children(
    card
  )
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
end
