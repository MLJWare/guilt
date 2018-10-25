local path = (...)
local sub1 = path:match("(.-)%.[^%.]+$")
local sub2 = sub1:match("(.-)%.[^%.]+$")
local sub3 = sub2:match("(.-)%.[^%.]+$")
local sub4 = sub3:match("(.-)%.[^%.]+$")

local roboto                  = require (sub2..".material-design.roboto")

local smooth_line             = require (sub2..".utils.smooth_line")
local smooth_rectangle        = require (sub2..".utils.smooth_rectangle")
local font_writer             = require (sub2..".utils.font_writer")

local EditableText            = require (sub2..".component.EditableText")

local guilt                   = require (sub3)
local pleasure                = require (sub3..".pleasure")

local rgb                     = require (sub4..".color.rgb")
local rgba                    = require (sub4..".color.rgba")
local clamp                   = require (sub4..".math.clamp")
local minmax                  = require (sub4..".math.minmax")
local unicode                 = require (sub4..".unicode")

local function ctrl_is_down () return love.keyboard.isDown("lctrl" , "rctrl" ) end
local function shift_is_down() return love.keyboard.isDown("lshift", "rshift") end

local function hline(x, y, width, color)
  x, y, width = math.floor(x), math.floor(y), math.floor(width)
  love.graphics.setLineStyle("rough")
  love.graphics.setColor(color)
  love.graphics.line(x, y, x + width, y)
end
local function vline(x, y, height, color)
  x, y, height = math.floor(x), math.floor(y), math.floor(height)
  love.graphics.setLineStyle("rough")
  love.graphics.setColor(color)
  love.graphics.line(x, y, x, y + height)
end

local function rect_fill(x, y, width, height, color)
  love.graphics.setLineStyle("rough")
  love.graphics.setColor(color)
  love.graphics.rectangle("fill", math.floor(x), math.floor(y), math.floor(width), math.floor(height))
end
local function rect_line(x, y, width, height, color)
  love.graphics.setLineStyle("rough")
  love.graphics.setColor(color)
  love.graphics.rectangle("line", math.floor(x), math.floor(y), math.floor(width), math.floor(height))
end

local PropertyTable = guilt.template("PropertyTable")

local font = roboto.body2

local wedge_open   = love.graphics.newImage(("%s/res/img/wedge/open.png"):format(sub2:gsub("%.", "/")))
local wedge_closed = love.graphics.newImage(("%s/res/img/wedge/closed.png"):format(sub2:gsub("%.", "/")))

local font_height = font:getHeight()
local x_pad = 8
local y_pad = font_height*0.2
local row_height = font_height + 2*y_pad
local row_mid_y  = row_height/2

local outline_color = rgb(144, 150, 169)
local fill_color    = rgb(255, 255, 255)

local Group = {}
do
  Group.__index = Group

  function Group:insert_row(key, value, opt_index)
    if opt_index then
      table.insert(self._keys  , opt_index, tostring(key   or "") or "")
      table.insert(self._values, opt_index, tostring(value or "") or "")
    else
      table.insert(self._keys  , tostring(key   or "") or "")
      table.insert(self._values, tostring(value or "") or "")
    end
    return self
  end
end

function PropertyTable:init()
  self.keys_id   = self.keys_id   or "Property"
  self.values_id = self.values_id or "Value"
  self._groups   = {}
  self._field = {
    text = "";
    hint = "";
    bounds = function ()
      return self:_active_field_bounds()
    end;
  }
  self._edit_ = EditableText:new(self._field)
  self._edit_.x_pad = x_pad
  self._edit_.font = font
  self.split_pct = 0.4
end

function PropertyTable:add_group(group_id, opt_index)
  local group = setmetatable({id = group_id, _keys = {}, _values = {}}, Group)
  if opt_index then
    table.insert(self._groups, opt_index, group)
  else
    table.insert(self._groups, group)
  end
  return group
end

function PropertyTable:group(group_id)
  return self._groups[group_id]
end

function PropertyTable:_find_field_at(mx, my)
  local x, y, width = self:bounds()
  mx, my = mx - x, my - y

  local dy = row_height
  for _, group in ipairs(self._groups) do
    local new_dy = dy + row_height
    if not group.collapsed then
      new_dy = new_dy + #group._keys*row_height
    end
    if new_dy > my then
      local split_width = self.split_pct*width
      local column      = (mx < split_width) and "_keys" or "_values"
      local index       = math.floor((my - dy)/row_height)

      return group, column, index
    end
    dy = new_dy
  end
end

function PropertyTable:_active_field_bounds()
  local group  = self._active_group
  local column = self._active_column
  local index  = self._active_index
  if not (group and column and index) then return 0,0,0,0 end

  local _, _, width = self:bounds()
  local split_width = self.split_pct*width
  local dx, field_width
  if column == "_values" then
    dx, field_width = split_width, width - split_width
  else
    dx, field_width = 0, split_width
  end

  local dy = row_height*index
  for _, group2 in ipairs(self._groups) do
    dy = dy + row_height
    if group == group2 then break end
    if not group2.collapsed then
      dy = dy + #group2._keys*row_height
    end
  end

  return dx, dy, field_width, row_height
end

function PropertyTable:_set_active_field(group, column, index)
  local active_group  = self._active_group
  local active_column = self._active_column
  local active_index  = self._active_index

  if (active_group and active_column and active_index) then
    local it = active_group[active_column]
    if it then
      it[active_index] = self._field.text
    end
  end

  self._edit_:set_text("")
  self._active_group  = group
  self._active_column = column
  self._active_index  = index
  if not group then return end
  local data = group[column]
  self._field.text = tostring(data and data[index] or "")
end

function PropertyTable:mousepressed(mx, my, button, isTouch)
  local group, column, index = self:_find_field_at(mx, my)
  self.active = true

  if  self._active_group  == group
  and self._active_column == column
  and self._active_index  == index then
    local dx, dy = self:bounds()
    self._edit_:mousepressed(mx - dx, my - dy, button, isTouch)
  else
    if group and index and index <= 0 then
      group.collapsed = not group.collapsed
      self:_set_active_field(nil, nil, nil)
      self.active = false
      return
    end
    self:_set_active_field(group, column, index)
    local dx, dy = self:bounds()
    self._edit_:mousepressed(mx - dx, my - dy, button, isTouch)
  end
end

function PropertyTable:has_active_field()
  return (self._active_group and self._active_column and self._active_index)
    and true or false
end

function PropertyTable:textinput(input)
  if not self:has_active_field() then
    return
  end
  self._edit_:textinput(input)
end

function PropertyTable:keypressed(key, scancode, isrepeat)
  if not self:has_active_field() then
    return
  end
  self._edit_:keypressed(key, scancode, isrepeat)
  pleasure.try.invoke(self, "on_keypressed", key, scancode, isrepeat)
end

function PropertyTable:mousedragged(mx, my, dx, dy, button1, button2)
  if not self:has_active_field() then
    return
  end
  local x, y = self:bounds()
  self._edit_:mousedragged(mx - x, my - y, dx, dy, button1, button2)
end

function PropertyTable:draw()
  local x, y, width, height = self:bounds()
  love.graphics.setColor(.25,.25,.25)

  local split_width = self.split_pct*width

  rect_fill(x, y, width, height, fill_color)
  pleasure.push_region(x, y, width, height)

  self:draw_head(width, height, split_width)

  local dy = row_height

  for _, group in ipairs(self._groups) do
    local remaining_height = height - dy
    if remaining_height <= 0 then break end
    dy = dy + self:draw_group(group, width, remaining_height, split_width, dy)
  end
  pleasure.pop_region()

  vline(x + split_width, y, height, outline_color)
  rect_line(x, y, width, height, outline_color)
end

function PropertyTable:draw_head(width, height, split_width)
  rect_fill(0, 0, width, row_mid_y, rgb(192, 203, 220))
  rect_fill(0, 0, width, 1, rgb(205, 214, 227))
  rect_fill(0, row_mid_y, width, row_mid_y, rgb(180, 193, 213))
  vline(split_width, 0, row_height, rgb(171, 181, 201))
  hline(0, row_height, width, rgb(171, 181, 201))

  love.graphics.setColor(rgb(2, 25, 47))
  pleasure.push_region(0, 0, split_width, row_height)
  font_writer.print_aligned(font, self.keys_id, x_pad, row_mid_y, "left", "center")
  pleasure.pop_region()

  pleasure.push_region(split_width, 0, width - split_width, row_height)
  font_writer.print_aligned(font, self.values_id, x_pad, row_mid_y, "left", "center")
  pleasure.pop_region()
end

function PropertyTable:draw_group(group, width, height, split_width, dy)
  rect_fill(0, dy, width, row_height, outline_color)

  love.graphics.setColor(rgb(255, 255, 255))
  love.graphics.draw(group.collapsed and wedge_closed or wedge_open, 0, row_mid_y + dy - 4)
  font_writer.print_aligned(font, group.id, x_pad, row_mid_y + dy, "left", "center")

  if group.collapsed then return row_height end

  local group_height = row_height

  local group_is_active = self._active_group == group
  local active_index  = self._active_index
  local active_column_is_key = self._active_column == "_keys"

  for index, key in ipairs(group._keys) do
    local row_is_active = group_is_active and (active_index == index)
    local key_is_active   = row_is_active and active_column_is_key
    local value_is_active = row_is_active and not active_column_is_key

    self:draw_field(key, 0, group_height + dy, split_width, key_is_active)
    value = group._values[index]
    self:draw_field(value, split_width, group_height + dy, width - split_width, value_is_active)
    hline(0, dy + group_height, width, outline_color)

    group_height = group_height + row_height
    if group_height >= height then break end
    hline(0, dy + group_height, width, outline_color)
  end

  return group_height
end

function PropertyTable:draw_field(field_text, x, y, width, is_active)
  if is_active then
    if self.active then
      self._edit_:draw_active()
    else
      self._edit_:draw_default()
    end
    return
  end
  love.graphics.setColor(is_active and rgb(201, 197, 90) or rgb(0,0,0))
  pleasure.push_region(x, y, width, row_height)
  font_writer.print_aligned(font, field_text, x_pad, y_pad, "left", "top")
  pleasure.pop_region()
end

guilt.finalize_template(PropertyTable)
