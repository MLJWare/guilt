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

local try_invoke = pleasure.try.invoke

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

  function Group.new(class, id)
    local self = setmetatable({
      id = id;
      _data = {}
    }, class)
    return self
  end

  function Group:insert_row(key, value, opt_row_index)
    local data = self._data
    if opt_row_index then
      local index = 2*clamp(opt_row_index, 1, #data + 1)
      table.insert(self._data, index - 1, tostring(key   or "") or "")
      table.insert(self._data, index    , tostring(value or "") or "")
    else
      table.insert(self._data, tostring(key   or "") or "")
      table.insert(self._data, tostring(value or "") or "")
    end
    return self
  end

  function Group:get_row(row_index)
    local data = self._data
    local index = 2*row_index
    return data[index - 1], data[index]
  end

  -- NOTE assumes the row _already_ exists!
  function Group:set_row(row_index, key, value)
    local data = self._data
    local index = 2*row_index
    data[index - 1] = tostring(key   or "") or ""
    data[index    ] = tostring(value or "") or ""
  end

  function Group:get_field(index)
    return self._data[index]
  end

  -- NOTE assumes the field _already_ exists!
  function Group:set_field(index, text)
    self._data[index] = tostring(text or "") or ""
  end

  function Group:len()
    return math.ceil(#self._data/2)
  end

  function Group:rows()
    return coroutine.wrap(function ()
      local data = self._data
      for row_index = 1, self:len() do
        local index = row_index*2
        coroutine.yield(data[index - 1], data[index], row_index)
      end
    end)
  end
end

local Groups = {}
do
  Groups.__index = Groups

  function Groups.new(class)
    local self = setmetatable({}, class)
    return self
  end

  function Groups:add_group(group_id, opt_group_index)
    local group = Group:new(group_id)
    if opt_group_index then
      table.insert(self, opt_group_index, group)
    else
      table.insert(self, group)
    end
    return group
  end
end

function PropertyTable:init()
  self.keys_id   = self.keys_id   or "Property"
  self.values_id = self.values_id or "Value"
  self._groups   = Groups:new()
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

function PropertyTable:add_group(group_id, opt_group_index)
    return self._groups:add_group(group_id, opt_group_index)
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
      new_dy = new_dy + group:len()*row_height
    end
    if new_dy > my then
      local split_width = self.split_pct*width
      local row_index    = math.floor((my - dy)/row_height)
      local index = (mx < split_width) and row_index*2 - 1 or row_index*2
      return group, index
    end
    dy = new_dy
  end
end

function PropertyTable:_active_field_bounds()
  local group  = self._active_group
  local index = self._active_index
  if not (group and index) then return 0,0,0,0 end

  local _, _, width = self:bounds()
  local split_width = self.split_pct*width
  local dx, field_width
  if index%2 == 1 then
    dx, field_width = 0, split_width
  else
    dx, field_width = split_width, width - split_width
  end

  local dy = row_height*math.floor((index+1)/2)
  for _, group2 in ipairs(self._groups) do
    dy = dy + row_height
    if group == group2 then break end
    if not group2.collapsed then
      dy = dy + group2:len()*row_height
    end
  end

  return dx, dy, field_width, row_height
end

function PropertyTable:_set_active_field(group, index)
  local active_group  = self._active_group
  local active_index  = self._active_index

  if active_group and active_index then
    local old_text = active_group:get_field(active_index)
    local new_text = self._field.text
    active_group:set_field(active_index, new_text)
    if old_text ~= new_text then
      try_invoke(self, "on_field_change", active_group, active_index, old_text, new_text)
    end
  end

  self._edit_:set_text("")
  self._active_group  = group
  self._active_index  = index
  if not (group and index) then return end
  self._field.text = group:get_field(index)
end

function PropertyTable:mousepressed(mx, my, button, isTouch)
  local group, index = self:_find_field_at(mx, my)
  self.active = true

  if  group == self._active_group
  and index == self._active_index then
    local dx, dy = self:bounds()
    self._edit_:mousepressed(mx - dx, my - dy, button, isTouch)
  else
    if group and index and index <= 0 then
      group.collapsed = not group.collapsed
      self:_set_active_field(nil, nil)
      self.active = false
      return
    end
    self:_set_active_field(group, index)
    local dx, dy = self:bounds()
    self._edit_:mousepressed(mx - dx, my - dy, button, isTouch)
  end
end

function PropertyTable:has_active_field()
  return (self._active_group and self._active_index) and true or false
end

function PropertyTable:textinput(input)
  if not self:has_active_field() then return end
  self._edit_:textinput(input)
end

function PropertyTable:keypressed(key, scancode, isrepeat)
  if not self:has_active_field() then return end
  self._edit_:keypressed(key, scancode, isrepeat)
  try_invoke(self, "on_keypressed", key, scancode, isrepeat)
end

function PropertyTable:mousedragged(mx, my, dx, dy, button1, button2)
  if not self:has_active_field() then return end
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
  local active_index    = self._active_index

  for key, value, row_index in group:rows() do
    local key_is_active   = group_is_active and (row_index*2 - 1 == active_index)
    local value_is_active = group_is_active and (row_index*2     == active_index)

    self:draw_field(key, 0, group_height + dy, split_width, key_is_active)
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
  love.graphics.setColor(rgb(0,0,0))
  pleasure.push_region(x, y, width, row_height)
  font_writer.print_aligned(font, field_text, x_pad, y_pad, "left", "top")
  pleasure.pop_region()
end

guilt.finalize_template(PropertyTable)
