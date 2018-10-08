local subpath = (...):match("(.-)[^%.]+$")
local roboto                  = require (subpath.."roboto")

local smooth_line             = require "utils.smooth_line"
local smooth_rectangle        = require "utils.smooth_rectangle"
local font_writer             = require "utils.font_writer"

local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"
local clamp                   = require "lib.math.clamp"
local minmax                  = require "lib.math.minmax"
local unicode                 = require "lib.unicode"

local function ctrl_is_down () return love.keyboard.isDown("lctrl" , "rctrl" ) end
local function shift_is_down() return love.keyboard.isDown("lshift", "rshift") end

local Textfield = guilt.template("Textfield"):needs{
  x      = pleasure.need.number;
  y      = pleasure.need.number;
  hint   = pleasure.need.string;
}

local min_width = 280
local height    =  56
local x_pad     =  12
local font = roboto.body1

function Textfield:init()
  self.text   = ""
  self.state  = "normal"
  self.width  = math.max(self.width or 0, min_width)
  self.height = height
  self.caret  = 1
  self.off_x  = 0
end

function Textfield:set_text(text)
  self.text   = tostring(text or "")
  self.select = nil
  self.caret  = unicode.len(self.text)
end

function Textfield:_set_caret(new_caret)
  self.select = shift_is_down() and (self.select or self.caret) or nil
  self.caret  = clamp(new_caret, 1, unicode.len(self.text) + 1)
end

function Textfield:_text_x()
  local left_x  = self.x - self.width/2 + x_pad
  local right_x = left_x + self.width - 2*x_pad
  local caret_x = left_x + font:getWidth(unicode.sub(self.text, 1, self.caret - 1))
  local off_x = self.off_x

  if caret_x + off_x < left_x then
    off_x = left_x - caret_x
  end

  if caret_x + off_x >= right_x then
    off_x = right_x - caret_x
  end

  self.off_x = off_x

  return left_x + off_x
end

function Textfield.draw : _default_ ()
  local cx, cy, width, height = self.x, self.y-1, self.width, self.height
  local x, y = cx - width/2, cy - height/2
  local text_x = self:_text_x()
  local text = self.text

  -- drop shadow
  smooth_rectangle(x, y + 1, width, height, 2, rgba(0, 0, 0, 0.62))
  -- field
  smooth_rectangle(x, y, width, height, 2, rgb(255, 255, 255))

  local sx, sy, sw, sh = love.graphics.getScissor()
  love.graphics.intersectScissor(x + x_pad, y, width - 2*x_pad, height)
  if #text == 0 then
    love.graphics.setColor(rgba(0, 0, 0, 0.3))
    font_writer.print_aligned(font, self.hint, text_x, cy, "left", "center")
  else
    -- TODO if text is to long, add elipsis near right border
    love.graphics.setColor(rgba(0, 0, 0, 0.8))
    font_writer.print_aligned(font, text, text_x, cy, "left", "center")
  end
  love.graphics.setScissor(sx, sy, sw, sh)
end

function Textfield.draw : active ()
  local cx, cy, width, height = self.x, self.y - 1, self.width, self.height
  local x, y = cx - width/2, cy - height/2
  local text_x = self:_text_x()

  -- drop shadow
  smooth_rectangle(x, y + 1, width, height, 2, rgba(0, 0, 0, 0.62))
  -- field
  smooth_rectangle(x, y, width, height, 2, rgb(255, 255, 255))

  love.graphics.push()
  local sx, sy, sw, sh = love.graphics.getScissor()
  love.graphics.intersectScissor(x + x_pad - 1, y, width - 2*x_pad + 2, height)
  do
    local text, caret = self.text, self.caret

    local blink = (love.timer.getTime() % 1 < 0.5)
    if not blink then -- show caret
      local left  = unicode.sub(text, 1, caret - 1)
      local caret_x = text_x + font:getWidth(left)
      smooth_line(caret_x, cy - 6, caret_x, cy + 6, 1, rgb(0, 0, 0))
    end

    local select = self.select
    if select then
      local start, stop = minmax(select, caret)
      local from_x = text_x + font:getWidth(unicode.sub(text, 1, start - 1))
      local size = font:getWidth(unicode.sub(text, start, stop - 1))
      smooth_rectangle(from_x, cy - 8, size, 16, 0, rgb(30, 147, 213))
    end

    love.graphics.setColor(rgb(0, 0, 0))
    font_writer.print_aligned(font, self.text, text_x, cy, "left", "center")
  end
  love.graphics.setScissor(sx, sy, sw, sh)
  love.graphics.pop()
end

function Textfield:_paste_text(input)
  local select, old_caret = self.select, self.caret
  local start, stop

  if select then
    start, stop = minmax(select, old_caret)
    self.select = nil
  else
    start, stop = old_caret, old_caret
  end

  self.text = unicode.splice(self.text, start, input, stop - start)
  self.caret = start + unicode.len(input)
end

function Textfield.textinput : active (input)
  self:_paste_text(input)
end

function Textfield:_copy_to_clipboard()
  local select, old_caret = self.select, self.caret
  if not select then return end
  local from, to = minmax(select, old_caret)
  local clip = unicode.sub(self.text, from, to - 1)
  love.system.setClipboardText(clip)
end

function Textfield.keypressed : active (key, scancode, isrepeat)
  local select, old_caret = self.select, self.caret

  -- TODO ctrl-a, ctrl-c, ctrl-v, ctrl-x

  if ctrl_is_down() then
    if key == "a" then
      self:_set_caret(1)
      self.select = unicode.len(self.text) + 1
      return
    elseif key == "c" then
      self:_copy_to_clipboard()
      return
    elseif key == "v" then
      self:_paste_text(love.system.getClipboardText() or "")
      return
    elseif key == "x" then
      self:_copy_to_clipboard()
      self:_paste_text("")
      return
    end
  end

  if key == "backspace" then
    if select then
      local start  = math.min(select, old_caret)
      local length = math.abs(select - old_caret)
      self.text = unicode.splice(self.text, start, "", length)
      self:_set_caret(start)
      self.select = nil
    elseif self.caret > 1 then
      self.text = unicode.splice(self.text, self.caret - 1, "", 1)
      self:_set_caret(self.caret - 1)
    end
    return
  end

  if key == "left" then
    self:_set_caret(self.caret - 1)
  elseif key == "right" then
    self:_set_caret(self.caret + 1)
  elseif key == "home" then
    self:_set_caret(1)
  elseif key == "end" then
    self:_set_caret(math.huge)
  end
end

function Textfield:mousepressed (mx, my, button_index)
  if button_index ~= 1 then return end

  if not pleasure.contains(self, mx, my) then
    self.state = "normal"
    return
  end

  self.state = "active"

  local text = self.text
  local text_x = self:_text_x()

  local text_len = unicode.len(text)
  for i = 0, text_len do
    local char_x = text_x + font:getWidth(unicode.sub(text, 1, i))
    if char_x >= mx then
      self:_set_caret(i)
      return
    end
  end
  self:_set_caret(text_len + 1)
end

guilt.finalize_template(Textfield)
