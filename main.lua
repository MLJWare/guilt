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

for i, element in ipairs(love.filesystem.getDirectoryItems("samples")) do
  if element:find("^[A-Z][^%.]*%.lua$") then
    require ("samples."..element:sub(1, -5))
  end
end

local gui

function love.load(arg)
  local w, h = love.graphics.getDimensions()

  love.keyboard.setKeyRepeat(true)

  gui = guilt.gui{
    x      = 0;
    y      = 0;
    width  = w;
    height = h;
    resize = function (self, display_width, display_height)
      self.width  = display_width;
      self.height = display_height;
    end;
  }

  local textfield = gui:new("Textfield", {
    anchor_x = 0.5;
    align_x  = 0.5;
    anchor_y = 0.7;
    align_y  = 0.5;
    password = false;
    hint   = "Sample hint";
  });
  local calc_button = gui:new("StyleButton", {
    color_normal  = rgb(26, 129, 27);
    color_pressed = rgb(19, 69, 19);
    anchor_x = 0.5;
    align_x  = 0.5;
    anchor_y = 0.9;
    align_y  = 0.5;
    text   = "Calculate";
    mouseclicked = function (self)
      local status, result = pcall(loadstring("return "..textfield.text))
      if status then
         textfield:set_text(result)
       end
    end
  });
  local card = gui:new("Card", {
    anchor_x = 0.5;
    align_x = 0.5;
    anchor_y = 0.4;
    align_y = 0.5;
    width  = 300;
    height = 400;
  })

  card:add_children(
    gui:new("Label", {
      anchor_x = 0.5;
      align_x = 0.5;
      anchor_y = 0.1;
      align_y = 0.5;
      text   = "GUI sample (based on Material Design)";
      color  = rgb(18, 38, 121);
    }),
    gui:new("Button", {
      anchor_x = 0.4;
      align_x = 1;
      anchor_y = 0.3;
      align_y = 0.5;
      text   = "Password";
      mouseclicked = function (self, mx, my)
        local dx, dy = (mx - self.x)/self.width, (my - self.y)/self.height
        print(("Pressed the %q button at: (%.2f, %.2f)"):format(self.text, dx, dy))
        textfield.password = true
      end;
    }),
    gui:new("Button", {
      anchor_x = 0.6;
      align_x = 0;
      anchor_y = 0.3;
      align_y = 0.5;
      text   = "Text";
      mouseclicked = function (self, mx, my)
        local dx, dy = mx - self.x, my - self.y
        print(("Pressed the %q button"):format(self.text))
        textfield.password = false
      end;
    }),
    gui:new("SliderH", {
      anchor_x = 0.5;
      align_x  = 0.5;
      anchor_y = 0.5;
      align_y  = 0.5;
      width    = 200;
      progress = 0.5;
      on_change = function (self, old_progress)
        print(("Changed the slider from %.2f to %.2f."):format(old_progress, self.progress))
        textfield:set_text(math.floor(self.progress*100))
      end;
    }),
    textfield,
    calc_button)

  gui:add_children(
    card,
    gui:new("Button", {
      anchor_x = 0.5;
      align_x  = 0.5;
      anchor_y = 0.9;
      align_y  = 0.5;
      text = "Toggle card";
      mouseclicked = function (self)
        if self.card_height then
          card.height = self.card_height
          self.card_height = nil
        else
          self.card_height = card.height
          card.height = 300
        end
      end
    }))
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
