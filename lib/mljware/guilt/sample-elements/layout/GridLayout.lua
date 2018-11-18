local path = (...)
local sub1 = path:match("(.-)%.[^%.]+$")
local sub2 = sub1:match("(.-)%.[^%.]+$")
local sub3 = sub2:match("(.-)%.[^%.]+$")

local guilt                   = require (sub3)
local pleasure                = require (sub3..".pleasure")


local namespace = guilt.namespace("layout")

local GridLayout = namespace:template("GridLayout"):needs{
  row_count    = pleasure.need.positive_integer;
  column_count = pleasure.need.positive_integer;
}

function GridLayout:init()
  self.content = {}
  self._last_add_index = 0
end

-- TODO better handling of (optional) indices, `i` and `j`
function GridLayout:add_child(child, i, j)
  local column_count, row_count = self.column_count, self.row_count
  if not (i and j)
  or i < 1 or i > column_count
  or j < 1 or j > row_count then
    return false
  end

  local index = i + (j-1)*column_count

  self.content[index] = child
  child._parent = self
end

function GridLayout.add_children()
  error ("Method `add_children` not allowed with GridLayout.")
end

-- TODO convert to stateless iterator
function GridLayout:children()
  return coroutine.wrap(function ()
    local content = self.content
    local column_count = self.column_count
    local row_count    = self.row_count

    local _, _, width, height = self:bounds()
    local cell_width  = width/column_count
    local cell_height = height/row_count

    for index = 1, column_count*row_count do
      local element = content[index]
      if element then
        local dx = ((index - 1)%column_count)*cell_width
        local dy = math.floor((index - 1)/column_count)*cell_height
        coroutine.yield(index, element, dx, dy, cell_width, cell_height)
      end
    end
  end)
end

function GridLayout:reverse_children()
  return coroutine.wrap(function ()
    local content = self.content
    local column_count = self.column_count
    local row_count    = self.row_count

    local _, _, width, height = self:bounds()
    local cell_width  = width/column_count
    local cell_height = height/row_count

    for index = column_count*row_count, 1, -1 do
      local element = content[index]
      if element then
        local dx = ((index - 1)%column_count)*cell_width
        local dy = math.floor((index - 1)/column_count)*cell_height
        coroutine.yield(index, element, dx, dy, cell_width, cell_height)
      end
    end
  end)
end

function GridLayout:region_of(child)
  local content = self.content
  local column_count = self.column_count
  local row_count    = self.row_count

  local _, _, width, height = self:bounds()
  for index = 1, column_count*row_count do
    if child == content[index] then
      local cell_width  = width/column_count
      local cell_height = height/row_count

      local dx = ((index - 1)%column_count)*cell_width
      local dy = math.floor((index - 1)/column_count)*cell_height
      return dx, dy, cell_width, cell_height
    end
  end
end

GridLayout.draw          = require "lib.mljware.guilt.delegate.draw"
GridLayout.mousepressed  = require "lib.mljware.guilt.delegate.mousepressed"
GridLayout.mousemoved    = require "lib.mljware.guilt.delegate.mousemoved"
GridLayout.mousereleased = require "lib.mljware.guilt.delegate.mousereleased"
GridLayout.textinput     = require "lib.mljware.guilt.delegate.textinput"
GridLayout.keypressed    = require "lib.mljware.guilt.delegate.keypressed"
GridLayout.keyreleased   = require "lib.mljware.guilt.delegate.keyreleased"
GridLayout.mouseclicked  = function () end

namespace:finalize_template(GridLayout)
