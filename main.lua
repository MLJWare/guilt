local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"

require "sample-elements.material-design.Button" -- loads the template into guilt
require "sample-elements.material-design.SliderH" -- loads the template into guilt

local gui

function love.load(arg)
  gui = {
    guilt.new("Button", {
      x      = 150;
      y      = 100;
      text   = "Hello";
      on_click = function (self, mx, my)
        local dx, dy = (mx - self.x)/self.width, (my - self.y)/self.height
        print(("Pressed the %q button at: (%.2f, %.2f)"):format(self.text, dx, dy))
      end;
    });
    guilt.new("Button", {
      x      = 250;
      y      = 100;
      text   = "World";
      on_click = function (self, mx, my)
        local dx, dy = mx - self.x, my - self.y
        print(("Pressed the %q button"):format(self.text))
      end;
    });
    guilt.new("SliderH", {
      x        = 200;
      y        = 200;
      length   = 170;
      progress = 0.5;
      on_change = function (self, old_progress)
        print(("Changed the slider from %.2f to %.2f."):format(old_progress, self.progress))
      end;
    });
  }
end

function love.resize(window_width, window_height)
  for i, btn in ipairs(gui) do
    pleasure.try_invoke(btn, "resize", mx, my, button, isTouch)
  end
end

function love.mousepressed(mx, my, button, isTouch)
  for i, btn in ipairs(gui) do
    pleasure.try_invoke(btn, "mousepressed", mx, my, button, isTouch)
  end
end

function love.mousemoved(mx, my, dx, dy)
  for i, btn in ipairs(gui) do
    pleasure.try_invoke(btn, "mousemoved", mx, my, dx, dy)
  end
end

function love.mousereleased(mx, my, button, isTouch)
  for i, btn in ipairs(gui) do
    pleasure.try_invoke(btn, "mousereleased", mx, my, button, isTouch)
  end
end

function love.draw()
  love.graphics.clear(rgb(226, 225, 223))
  for i, btn in ipairs(gui) do
    pleasure.try_invoke(btn, "draw")
  end
end
