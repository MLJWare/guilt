local function create (code)
  return load(code, nil, "t", nil)()
end

local function build_arg_list(prefix, count, postfix, extra_args)
  local builder = {}
  for i = 1, count do
    table.insert(builder, ("%s%d%s"):format(prefix or "", i, postfix or ""))
  end
  if extra_args then
    table.insert(builder, extra_args)
  end
  return table.concat(builder, ", ")
end

local function build_code(...)
  local builder = {}
  for i = 1, select("#", ...) do
    local value = select(i, ...)
    if type(value) == "function" then
      for str in coroutine.wrap(value) do
        table.insert(builder, tostring(str))
      end
    else
      table.insert(builder, tostring(value))
    end
  end
  return table.concat(builder, "")
end

local yield = coroutine.yield

return function (element_count)
  return create(build_code([[
local Group = {}
Group.__index = Group

function Group.new(class, id)
  local self = setmetatable({
    id = id;
    _data = {}
  }, class)
  return self
end

function Group:insert_row(]], build_arg_list("arg", element_count, "", "opt_row_index"), [[)
  local data = self._data
  if opt_row_index then
    local index = ]], element_count, [[*clamp(opt_row_index - 1, 0, #data)
]], function (builder)
      for i = 1, element_count do
        yield(build_code([[
    table.insert(self._data, index + ]], i, [[, tostring(arg]], i, [[ or "") or "")
]]))
      end
    end, [[
  else
]], function ()
      for i = 1, element_count do
        yield(build_code([[
    table.insert(self._data, tostring(arg]], i, [[ or "") or "")
]]))
      end
    end, [[
  end
  return self
end

function Group:get_row(row_index)
  local data = self._data
  local index = ]], element_count, [[*(row_index - 1)
  return ]], build_arg_list("data[index +", element_count, "] or \"\""), [[

end

-- NOTE assumes the row _already_ exists!
function Group:set_row(row_index, ]], build_arg_list("arg", element_count, ""), [[)
  local data = self._data
  local index = ]], element_count, [[*(row_index - 1)
]], function ()
  for i = 1, element_count do
    yield(build_code([[
  data[index + ]], i, [[] = tostring(arg]], i, [[ or "") or ""
]]))
  end
end, [[
end

function Group:get_field(index)
  return self._data[index] or ""
end

-- NOTE assumes the field _already_ exists!
function Group:set_field(index, text)
  self._data[index] = tostring(text or "") or ""
end

function Group:len()
  return math.ceil(#self._data/]], element_count, [[)
end

function Group:rows()
  return coroutine.wrap(function ()
    local data = self._data
    for row_index = 1, self:len() do
      local index = (row_index-1)*]], element_count, [[

      coroutine.yield(]], build_arg_list("data[index + ", element_count, "] or \"\"", "row_index"), [[)
    end
  end)
end

function Group:draw(property_table, hline, outline_color, width, height, row_height, dy, is_active, active_index)
  local group_height = row_height
  for ]], build_arg_list("field", element_count, "", "row_index"), [[ in self:rows() do
]], function ()
      for i = 1, element_count do
        yield(build_code([[
    local field]], i, [[_is_active = is_active and ((row_index-1)*]], element_count, [[ + ]], i, [[) == active_index
]]))
      end
    end, [[

    local dx, field_width

]], function ()
      for i = 1, element_count do
        yield(build_code([[
    dx, field_width = property_table:_column_dx_width(]], i, [[)
    property_table:draw_field(field]], i, [[, dx, group_height + dy, field_width, field]], i, [[_is_active)

]]))
      end
    end, [[
    hline(0, dy + group_height, width, outline_color)

    group_height = group_height + row_height
    if group_height >= height then break end
    hline(0, dy + group_height, width, outline_color)
  end
  return group_height
end

return Group]]))
end
