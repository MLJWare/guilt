love.graphics.setDefaultFilter("nearest", "nearest")

local guilt                   = require "lib.mljware.guilt"
local pleasure                = require "lib.mljware.guilt.pleasure"
local rgb                     = require "lib.mljware.color.rgb"

local try_invoke  = pleasure.try.invoke
local contains    = pleasure.contains
local is_callable = pleasure.is.callable

require "lib.mljware.guilt.sample-elements.material-design"
require "lib.mljware.guilt.sample-elements.layout"
require "samples"

local gui

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
      for _, child in self:children() do
        try_invoke(child, "resize", self.preferred_width, self.preferred_height)
      end
    end;
  }

  layout = gui:new("GridLayout", {
    column_count = 5;
    row_count    = 10;
    preferred_width  = w;
    preferred_height = h;
    resize = function(self, display_width, display_height)
      self.preferred_width  = display_width
      self.preferred_height = display_height
    end;
  })
  gui:add_child(layout)

  for j = 1, layout.row_count do
    for i = 1, layout.column_count do
      layout:add_child(gui:new("Button", {
        anchor_x = 0.5; align_x = 0.5;
        anchor_y = 0.5; align_y = 0.5;
        text = ("%d:%d"):format(i, j);
      }), i, j)
    end
  end

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
  love.window.setTitle(love.timer.getFPS())
  love.graphics.clear(rgb(226, 225, 223))
  try_invoke(gui, "draw")
end
