local roboto                  = require ("sample-elements.material-design.roboto")

local smooth_rectangle        = require "utils.smooth_rectangle"
local font_writer             = require "utils.font_writer"

local guilt                   = require "lib.guilt"
local pleasure                = require "lib.guilt.pleasure"
local rgb                     = require "lib.color.rgb"
local rgba                    = require "lib.color.rgba"

local is_callable = pleasure.is.callable
local try_invoke  = pleasure.try.invoke

local GridLayout = guilt.template("GridLayout"):needs{
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
  local index
  if not (i and j)
  or i < 1 or i > column_count
  or j < 1 or j > row_count then
    return false
  end

  local index = i + (j-1)*column_count

  self.content[index] = child
  child._parent = self
end

function GridLayout:add_children(...)
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

--TODO override `add_child`, `add_children`, `children` methods

--[[
function GridLayout:draw () --TODO make delegated version hereof
  local content = self.content
  local column_count = self.column_count
  local row_count    = self.row_count

  local x, y, width, height = self:bounds()
  local cell_width  = width/column_count
  local cell_height = height/row_count

  pleasure.push_region(x, y, width, height)
  for j = 1, row_count do
    local cell_y = (j-1)*cell_height
    local j_index = (j-1)*column_count
    for i = 1, column_count do
      local cell_x = (i-1)*cell_width
      smooth_rectangle(cell_x, cell_y, cell_width, cell_height, 0, ((i+j)%2==0) and rgb(128, 131, 133) or rgb(91, 195, 252))
      local child = self.content[i + j_index]
      if child then
        pleasure.push_region(cell_x, cell_y, cell_width, cell_height)
        try_invoke(child, "draw")
        pleasure.pop_region()
      end
    end
  end
  pleasure.pop_region()
end
--]]

GridLayout.draw          = require "lib.guilt.delegate.draw"
GridLayout.mousepressed  = require "lib.guilt.delegate.mousepressed"
GridLayout.mousemoved    = require "lib.guilt.delegate.mousemoved"
GridLayout.mousereleased = require "lib.guilt.delegate.mousereleased"
GridLayout.textinput     = require "lib.guilt.delegate.textinput"
GridLayout.keypressed    = require "lib.guilt.delegate.keypressed"
GridLayout.keyreleased   = require "lib.guilt.delegate.keyreleased"

guilt.finalize_template(GridLayout)
