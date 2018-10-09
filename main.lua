local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"

local try_invoke  = pleasure.try.invoke
local contains    = pleasure.contains
local is_callable = pleasure.is.callable

for i, element in ipairs(love.filesystem.getDirectoryItems("sample-elements/material-design")) do
  if element:find("^[A-Z][^%.]*%.lua$") then
    require ("sample-elements.material-design."..element:sub(1, -5))
  end
end

local gui

function love.load(arg)
  local w, h = love.graphics.getDimensions()

  gui = guilt.gui{
    x = w/2;
    y = h/2;
    width  = w;
    height = h;
  }

  local textfield = gui:new("Textfield", {
    x      = 150;
    y      = 240;
    hint   = "Sample hint";
  });
  local calc_button = gui:new("Button", {
    x      = 150;
    y      = 300;
    text   = "Calculate";
    mouseclicked = function (self)
      local status, result = pcall(loadstring("return "..textfield.text))
      if status then
         textfield:set_text(result)
       end
    end
  });
  local card = gui:new("Card", {
    x      = 180;
    y      = 210;
    width  = 300;
    height = 400;

    children = {
      gui:new("Label", {
        x      = 150;
        y      = 80;
        text   = "GUI sample (based on Material Design)";
        color  = rgb(18, 38, 121);
      });
      gui:new("Button", {
        x      = 100;
        y      = 140;
        text   = "Hello";
        mouseclicked = function (self, mx, my)
          local dx, dy = (mx - self.x)/self.width, (my - self.y)/self.height
          print(("Pressed the %q button at: (%.2f, %.2f)"):format(self.text, dx, dy))
          textfield:set_text(self.text)
        end;
      });
      gui:new("Button", {
        x      = 200;
        y      = 140;
        text   = "World";
        mouseclicked = function (self, mx, my)
          local dx, dy = mx - self.x, my - self.y
          print(("Pressed the %q button"):format(self.text))
          textfield:set_text(self.text)
        end;
      });
      gui:new("SliderH", {
        x        = 150;
        y        = 200;
        length   = 200;
        progress = 0.5;
        on_change = function (self, old_progress)
          print(("Changed the slider from %.2f to %.2f."):format(old_progress, self.progress))
          textfield:set_text(math.floor(self.progress*100))
        end;
      });
      textfield;
      calc_button;
    }
  })

  gui.children = {
    card;
    gui:new("Button", {
      x    = 180;
      y    = 500;
      text = "Toggle card";
      mouseclicked = function (self)
        if self.card_width then
          card.width = self.card_width
          self.card_width = nil
        else
          self.card_width = card.width
          card.width = 160
        end
      end
    });
  }
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
