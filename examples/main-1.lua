love.graphics.setDefaultFilter("nearest", "nearest")

local guilt                   = require "lib.mljware.guilt"
local pleasure                = require "lib.mljware.guilt.pleasure"
local rgb                     = require "lib.mljware.color.rgb"

local try_invoke  = pleasure.try.invoke

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
    end;
  }

  local textfield = gui:new("Textfield", {
    anchor_x = 0.5;
    align_x  = 0.5;
    anchor_y = 0.7;
    align_y  = 0.5;
    hint   = "Sample hint";
  });
  local calc_button = gui:new("StyleButton", {
    color_normal  = rgb(26, 129, 27);
    color_hover   = rgb(23, 115, 24);
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
    preferred_width  = 300;
    preferred_height = 400;
  })

  local scale_buttons = gui:new("GridLayout", {
    column_count = 2;
    row_count    = 1;
    preferred_width  = 250;
    preferred_height = 60;
    anchor_x = 0.5;
    align_x = 0.5;
    anchor_y = 0.4;
    align_y = 0.5;
  })

  scale_buttons:add_child(gui:new("Button", {
    text     = "Scale +";
    anchor_x = 0.5;
    align_x  = 0.5;
    anchor_y = 0.5;
    align_y  = 0.5;
    mouseclicked = function (self, mx, my)
      gui.render_scale = gui.render_scale*2
      gui.preferred_width  = gui.preferred_width/2
      gui.preferred_height = gui.preferred_height/2
    end;
  }), 1, 1)

  scale_buttons:add_child(gui:new("Button", {
    text     = "Scale -";
    anchor_x = 0.5;
    align_x  = 0.5;
    anchor_y = 0.5;
    align_y  = 0.5;
    mouseclicked = function (self, mx, my)
      gui.render_scale = gui.render_scale/2
      gui.preferred_width  = gui.preferred_width*2
      gui.preferred_height = gui.preferred_height*2
    end;
  }), 2, 1)

  card:add_children(
    gui:new("Label", {
      anchor_x = 0.5;
      align_x = 0.5;
      anchor_y = 0.1;
      align_y = 0.5;
      text   = "GUI sample (based on Material Design)";
      text_color = rgb(18, 38, 121);
    }),
    gui:new("Button", {
      x = -10;
      anchor_x = 0.5;
      align_x = 1;
      anchor_y = 0.25;
      align_y = 0.5;
      text   = "Password";
      mouseclicked = function (self, mx, my)
        local width, height = self:size()
        local dx, dy = (mx - self.x)/width, (my - self.y)/height
        print(("Pressed the %q button at: (%.2f, %.2f)"):format(self.text, dx, dy))
        textfield.texttype = "password"
      end;
    }),
    gui:new("Button", {
      x = 10;
      anchor_x = 0.5;
      align_x = 0;
      anchor_y = 0.25;
      align_y = 0.5;
      text   = "Text";
      mouseclicked = function (self, mx, my)
        local dx, dy = mx - self.x, my - self.y
        print(("Pressed the %q button"):format(self.text))
        textfield.texttype = nil
      end;
    }),
    scale_buttons,
    gui:new("SliderH", {
      anchor_x = 0.5;
      align_x  = 0.5;
      anchor_y = 0.5;
      align_y  = 0.5;
      preferred_width = 200;
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
          card.preferred_height = self.card_height
          self.card_height = nil
        else
          self.card_height = card.preferred_height
          card.preferred_height = 300
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
