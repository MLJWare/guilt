local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"

for i, element in ipairs(love.filesystem.getDirectoryItems("sample-elements/material-design")) do
  if element:find("^[A-Z][^%.]*%.lua$") then
    require ("sample-elements.material-design."..element:sub(1, -5))
  end
end

local gui

function love.load(arg)
  local textfield = guilt.new("Textfield", {
    x      = 180;
    y      = 240;
    hint   = "Sample hint";
  });


  gui = {
    guilt.new("Label", {
      x      = 180;
      y      = 80;
      text   = "GUI sample (based on Material Design)";
      color  = rgb(18, 38, 121);
    });
    guilt.new("Button", {
      x      = 120;
      y      = 140;
      text   = "Hello";
      on_click = function (self, mx, my)
        local dx, dy = (mx - self.x)/self.width, (my - self.y)/self.height
        print(("Pressed the %q button at: (%.2f, %.2f)"):format(self.text, dx, dy))
        textfield:set_text(self.text)
      end;
    });
    guilt.new("Button", {
      x      = 240;
      y      = 140;
      text   = "World";
      on_click = function (self, mx, my)
        local dx, dy = mx - self.x, my - self.y
        print(("Pressed the %q button"):format(self.text))
        textfield:set_text(self.text)
      end;
    });
    guilt.new("SliderH", {
      x        = 180;
      y        = 200;
      length   = 200;
      progress = 0.5;
      on_change = function (self, old_progress)
        print(("Changed the slider from %.2f to %.2f."):format(old_progress, self.progress))
        textfield:set_text(math.floor(self.progress*100))
      end;
    });
    textfield;
  }
end

for _, callback in ipairs{
  "resize";
  "mousepressed";
  "textinput";
  "keypressed";
  "mousemoved";
  "mousereleased";
} do
  love[callback] = function (...)
    for i, element in ipairs(gui) do
      pleasure.try_invoke(element, callback, ...)
    end
  end
end

function love.draw()
  love.graphics.clear(rgb(226, 225, 223))
  for i, btn in ipairs(gui) do
    pleasure.try_invoke(btn, "draw")
  end
end
