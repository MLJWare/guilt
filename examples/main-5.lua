love.graphics.setDefaultFilter("nearest", "nearest")

local guilt                   = require "lib.mljware.guilt"
local pleasure                = require "lib.mljware.guilt.pleasure"
local rgb                     = require "lib.mljware.color.rgb"

local try_invoke  = pleasure.try.invoke

require "lib.mljware.guilt.sample-elements.material-design"
require "lib.mljware.guilt.sample-elements.layout"
require "lib.mljware.guilt.sample-elements.standard"
require "samples"

local gui

local material = guilt.namespace("material-design")
local standard = guilt.namespace("standard")

function love.load(arg)
  local w, h = love.graphics.getDimensions()

  love.keyboard.setKeyRepeat(true)

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

  local card = gui:new(material.Card, {
    anchor_x = 0.5;
    align_x = 0.5;
    anchor_y = 0.4;
    align_y = 0.5;
    preferred_width  = 300;
    preferred_height = 400;
    fill_color = rgb(99, 227, 246);
  })

  local properties = gui:new(standard.PropertyTable, {
    column_names = {"Property", "Value", "Kind"};
    anchor_x = 0.5;
    align_x = 0.5;
    anchor_y = 0.5;
    align_y = 0.5;
    preferred_width  = card.preferred_width  - 64;
    preferred_height = card.preferred_height - 64;
  })

  properties:add_group("Map")
  : insert_row("x"      , 100, "number")
  : insert_row("y"      , 200, "number")
  : insert_row("width"  ,  45, "number")
  : insert_row("height" ,  62, "number")

  properties:add_group("Tile")
  : insert_row("id"   ,      52, "number")
  : insert_row("type" , "grass", "string")
  .collapsed = true

  properties:add_group("Entity")
  : insert_row("id"     , "player-1", "string")
  : insert_row("type"   , "player"  , "string")
  : insert_row("x"      ,         87, "number")
  : insert_row("y"      ,         32, "number")
  : insert_row("health" ,        100, "number")

  card:add_child(properties)

  gui:add_child(card)
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
