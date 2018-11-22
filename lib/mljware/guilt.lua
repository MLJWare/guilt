local path = (...)
local pleasure                = require (path..".pleasure")
local is                      = require (path..".pleasure.is")
local invoker                 = require (path..".pleasure.invoker")
local clone                   = require (path..".pleasure.clone")
local ensure                  = require (path..".pleasure.ensure")
local try_invoke              = require (path..".pleasure.try").invoke



local is_callable = is.callable

local EMPTY = {}

local function insist(condition, message, a)
  if condition then return end
  error(message:format(a), 3)
end

local function enforce(needs, props)
  for need, enforcer in pairs(needs) do
    local prop = props[need]
    enforcer(prop, need)
  end
end

local function add_child(self, child)
  table.insert(self._children, child)
  child._parent = self
end

local function add_children(self, ...)
  for i = 1, select("#", ...) do
    local child = select(i, ...)
    table.insert(self._children, child)
    child._parent = self
  end
end

local function element_size(self)
  --TODO change this
  return self.preferred_width
       , self.preferred_height
end

local function element_bounds(self)
  local parent = self._parent
  local region_x, region_y, region_width, region_height = parent:region_of(self)
  local x, y, width, height = self.x, self.y, self:size()

  local anchor_x = self.anchor_x or 0
  local anchor_y = self.anchor_y or 0

  local align_x  = self.align_x or 0
  local align_y  = self.align_y or 0

  local bounds_width  = math.min(region_width , width)
  local bounds_height = math.min(region_height, height)
  local bounds_x
  local bounds_y

  bounds_x = region_x + x + anchor_x*region_width  - align_x*bounds_width
  bounds_y = region_y + y + anchor_y*region_height - align_y*bounds_height

  return bounds_x
       , bounds_y
       , bounds_width
       , bounds_height
end

local function element_children(self)
  return ipairs(self._children or EMPTY)
end

local function previous(t, i)
  i = i - 1
  if i > 0 then return i, t[i] end
end

local function reverse_ipairs(t)
  return previous, t, #t + 1
end

local function element_reverse_children(self)
  return reverse_ipairs(self._children)
end

local function element_region_of(self, _)
  local width, height = self:size()
  return 0, 0, width, height
end

local function element_deactivate(self)
  self.active = nil
  if is.callable(self.children) then
    for _, child in self:children() do
      child:deactivate()
    end
  end
end

local Template = {}
function Template.__index(template, key)
  local value = rawget(Template, key)
  if not value then
    value = invoker()
    rawset(template, key, value)
  end
  return value
end

local guilt = {}

local function _new(gui, template, props)
  local self = props or {}
  for k, v in pairs(template) do
    if not (is.string(k) and k:find("^__"))
    and not self[k] then
      self[k] = clone(v)
    end
  end
  setmetatable(self, template)
  self._guilt_gui_ = gui
  pleasure.try.invoke(self, "init")
  return self
end

local basic_needs = {
  x                = pleasure.need.number;
  y                = pleasure.need.number;
  preferred_width  = pleasure.need.non_negative_number;
  preferred_height = pleasure.need.non_negative_number;
}

local GUI = {}
GUI.__index = GUI

function guilt.gui(props)
  insist(is.table(props), "GUI needs property table on creation.")
  enforce(basic_needs, props)

  props.tags = {}
  props._guilt_gui_ = props
  if props.render_scale then
    insist(is.positive_number(props.render_scale), "GUI property `render_scale` must be a positive number.")
  else
    props.render_scale = 1
  end

  if props._children then
    insist(is.table (props._children), "GUI property `children` must be a table.")
  else
    props._children = {}
  end
  return setmetatable(props, GUI)
end

local _namespaces = {}

local Namespace = {
  __immutable = true;
}
function Namespace.__index(self, key)
  return rawget(Namespace, key)
      or rawget(self, "_templates")[key]
end

function guilt.namespace(namespace_id)
  local namespace = _namespaces[namespace_id]
  if not namespace then
    namespace = setmetatable({
      _id        = namespace_id;
      _templates = {};
      _needs     = {};
     }, Namespace)
    _namespaces[namespace_id] = namespace
  end
  return namespace
end

function GUI:new(template, props)
  -- TODO enable argument checking
  --insist(is.template(template), "Template id must be a valid guilt Template.")
  --local template = _templates[template_id]
  --insist(is.table(template), "No template named %q exist.", template_id)
  --insist(getmetatable(template) ~= Template, "Template %q must be finalized before use.", template_id)

  local needs = template._namespace_._needs[template]
  if needs then
    insist(is.table (props), "Template `%s` needs property table on creation.", template._id)
    enforce(needs, props)
  end

  local instance = _new(self, template, props)
  enforce(basic_needs, instance)

  return instance
end

function GUI:draw ()
  local scale = self.render_scale
  local x, y, width, height = self:bounds()
  pleasure.push_region(x, y, width*scale, height*scale)
  pleasure.scale(self.render_scale)
  for _, child in self:reverse_children() do
    pleasure.try.invoke(child, "draw")
  end
  pleasure.pop_region()
end

function GUI:bounds()
  return self.x, self.y, self:size()
end
function GUI:size()
  return self.preferred_width, self.preferred_height
end

GUI.contains = pleasure.contains

GUI.add_child     = add_child
GUI.add_children  = add_children
GUI.region_of     = element_region_of
GUI.children      = element_children
GUI.reverse_children = element_reverse_children
GUI.deactivate    = element_deactivate
GUI.textinput     = require "lib.mljware.guilt.delegate.textinput"
GUI.keypressed    = require "lib.mljware.guilt.delegate.keypressed"
GUI.keyreleased   = require "lib.mljware.guilt.delegate.keyreleased"

function GUI:mousepressed(mx, my, button, isTouch)
  self.active = true
  local press_tag = "pressed"..button

  local x, y = self:bounds()
  mx, my = mx - x, my - y

  local scale = self.render_scale or 1
  mx, my = mx/scale, my/scale

  local gui_tag_bag = ensure(self.tags, press_tag)

  local no_press = true

  for _, child in self:children() do
    -- TODO ensure [mx, my] contained in region
    child.active = nil
    if  no_press
    and child:contains(mx, my) then
      gui_tag_bag[child] = true
      child[press_tag] = true
      child.pressed    = true
      if is_callable(child.mousepressed) then
        child:mousepressed(mx, my, button, isTouch)
        no_press = false
      end
    end
  end

  if no_press then
    self:deactivate()
  end

  return not no_press
end

function GUI:mousemoved(mx, my, dx, dy)
  local x, y = self:bounds()
  mx, my = mx - x, my - y

  local scale = self.render_scale or 1
  mx, my = mx/scale, my/scale
  dx, dy = dx/scale, dy/scale

  local gui_pressed1_bag = self.tags.pressed1
  local gui_pressed2_bag = self.tags.pressed2
  local gui_pressed3_bag = self.tags.pressed3
  local gui_hovered_bag  = ensure(self.tags, "hovered")

  local not_found = true
  for _, child in self:children() do
    -- TODO ensure [mx, my] contained in region
    if  not_found
    and child:contains(mx, my) then
      gui_hovered_bag[child] = true
      if  not child.hovered
      and is_callable(child.mouseenter) then
        child:mouseenter(mx, my, dx, dy)
      end
      child.hovered = true
      if is_callable(child.mousemoved) then
        child:mousemoved(mx, my, dx, dy)
        not_found = false
      end
    else
      gui_hovered_bag[child] = nil
      if  child.hovered
      and is_callable(child.mouseleave) then
        child:mouseleave(mx, my, dx, dy)
      end
      child.hovered = nil
    end

    local pressed1 = gui_pressed1_bag and gui_pressed1_bag[child] or false
    local pressed2 = gui_pressed2_bag and gui_pressed2_bag[child] or false
    local pressed3 = gui_pressed3_bag and gui_pressed3_bag[child] or false
    if pressed1 or pressed2 or pressed3 then
      try_invoke(child, "mousedragged", mx, my, dx, dy, pressed1, pressed2, pressed3)
    end
  end
end

function GUI:wheelmoved(wheel_dx, wheel_dy)
  local x, y = self:bounds()
  local mx, my = love.mouse.getPosition()
  mx, my = mx - x, my - y

  local scale = self.render_scale or 1
  mx, my = mx/scale, my/scale

  for _, child in self:children() do
    -- TODO ensure [mx, my] contained in region
    if  child:contains(mx, my)
    and is_callable(child.mousewheelmoved) then
      child:mousewheelmoved(mx, my, wheel_dx, wheel_dy)
      break
    end
  end
end

function GUI:mousereleased(mx, my, button, isTouch)
  local press_tag = "pressed"..button

  local x, y = self:bounds()
  mx, my = mx - x, my - y

  local scale = self.render_scale or 1
  mx, my = mx/scale, my/scale

  local gui_tags = self.tags
  local gui_tag_bag = ensure(gui_tags, press_tag)

  local no_release = true
  local no_click   = true
  for _, child in self:children() do
    -- TODO ensure [mx, my] contained in region
    if  child:contains(mx, my) then
      if no_release and is_callable(child.mousereleased) then
        child:mousereleased(mx, my, button, isTouch)
        no_release = false
      end

      if no_click and gui_tag_bag[child] and is_callable(child.mouseclicked) then
        child:mouseclicked(mx, my, button)
        no_click = false
      end
    end
  end

  local pressed1 = ensure(gui_tags, "pressed1")
  local pressed2 = ensure(gui_tags, "pressed2")
  local pressed3 = ensure(gui_tags, "pressed3")

  for child in pairs(gui_tag_bag) do
    child[press_tag]   = nil
    gui_tag_bag[child] = nil

    child.pressed = pressed1[child]
                  or pressed2[child]
                  or pressed3[child]
                  or nil
  end

  return not no_release
end



function Namespace:template(template_id)
  insist(is.string(template_id), "Template id must be a string.")

  local template = setmetatable({
    _namespace_ = self;
  }, Template)

  self._templates[template_id] = template
  self._templates[template] = template_id

  return template
end

-- TODO more code to finalize template?
function Namespace:finalize_template(template)
  insist(is.table(template) and getmetatable(template) == Template, "Template provided must be an actual guilt Template.")
  setmetatable(template, nil)
  insist(template.bounds == nil, "Template must not override internal `bounds` method.")
  insist(template.size   == nil, "Template must not override internal `size` method.")

  --template.anchor_x = template.anchor_x or 0
  --template.anchor_y = template.anchor_y or 0
  --template.align_x  = template.align_x  or 0
  --template.align_y  = template.align_y  or 0
  template.x        = template.x        or 0
  template.y        = template.y        or 0

  if template.add_child then
    insist(is.callable(template.add_child), "Property `add_child` must be a method.")
  else
    template.add_child = add_child
  end

  if template.add_children then
    insist(is.callable(template.add_children), "Property `add_children` must be a method.")
  else
    template.add_children = add_children
  end

  if template.children then
    insist(is.callable(template.children), "Property `children` must be a method.")
  else
    template.children = element_children
  end

  if template.reverse_children then
    insist(is.callable(template.reverse_children), "Property `reverse_children` must be a method.")
  else
    template.reverse_children = element_reverse_children
  end

  if template.contains then
    insist(is.callable(template.contains), "Property `contains` must be a method.")
  else
    template.contains = pleasure.contains
  end

  if template.region_of then
    insist(is.callable(template.region_of), "Property `region_of` must be a method.")
  else
    template.region_of = element_region_of
  end

  template.bounds       = element_bounds
  template.size         = element_size
  template.deactivate   = element_deactivate
  template.__index      = template

  template._kind_ = self._templates[template]
end

-- FIXME broken
function Namespace:template_try_call(template_id, method_id, ...)
  insist(is.string(template_id), "First argument to `guilt.template_invoke` must be a string referencing a previously finalized Template.")
  local template = self._templates[template_id]
  insist(is.string(method_id), "Second argument to `guilt.template_invoke` must be a string referencing a method on the template.")
  local method = template[method_id]
  if method and is.callable(method) then
    return method(...)
  end
end

function Template:from(parent)
  -- TODO reneable argument checking
  --insist(is.string(parent_id), "Argument to `Template:from` must be a string referencing a previously finalized Template.")
  --local parent = self._namespace_._templates[parent_id]
  --insist(is.table(parent), "No template named %q exist.", parent_id)
  --insist(getmetatable(parent) ~= Template, "Template %q must be finalized before it can be used in `Template:from`.", parent_id)

  for k, v in pairs(parent) do
    if is.string(k)
    and k ~= "__index"
    and k ~= "bounds"
    and k ~= "deactivate"
    and k ~= "size" then
      self[k] = clone(v)
    end
  end

  local parent_needs = self._namespace_._needs[parent]
  if parent_needs then
    local needs = ensure(self._namespace_._needs, self)
    for k, v in pairs(parent_needs) do
      if not needs[k] then
        needs[k] = v
      end
    end
  end

  return self
end

function Template:needs(props)
  insist(is.table(props), "Argument to `Template:needs` must be a table.")

  for need, enforcer in pairs(props) do
    insist(is.string(need), "Name of need must be a string.")
    insist(is.callable(enforcer), "Enforcer of need `%s` must callable.", need)
  end

  local _needs = self._namespace_._needs
  local needs = _needs[self]
  if not needs then
    _needs[self] = props
  else
    for k, v in pairs(props) do
      if not needs[k] then
        needs[k] = v
      end
    end
  end

  return self
end

return guilt
