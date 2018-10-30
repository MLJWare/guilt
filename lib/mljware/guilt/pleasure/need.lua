local subpath = (...):match("(.-)[^%.]+$")
local is                      = require (subpath.."is")

local need = {}

local function ensure(condition, depth, msg, ...)
  if condition then return end
  error((msg):format(...), depth)
end

local function ensure_property(condition, specific, id)
  if condition then return end
  error(("Property %q must be %s."):format(id, specific), 3)
end

local function ensure_kind(value, kind, id)
  if is.kind(value, kind) then return end
  error(("Property %q must be of kind %q."):format(id, kind), 5)
end

function need.number(value, id)
  ensure_property(is.number(value), "a number", id)
end

function need.positive_number(value, id)
  ensure_property(is.positive_number(value), "a positive number", id)
end

function need.non_negative_number(value, id)
  ensure_property(is.non_negative_number(value), "a non-negative number", id)
end

function need.non_positive_number(value, id)
  ensure_property(is.non_positive_number(value), "a non-positive number", id)
end

function need.negative_number(value, id)
  ensure_property(is.negative_number(value), "a negative number", id)
end

function need.integer(value, id)
  ensure_property(is.integer(value), "a integer", id)
end

function need.positive_integer(value, id)
  ensure_property(is.positive_integer(value), "a positive integer", id)
end

function need.non_negative_integer(value, id)
  ensure_property(is.non_negative_integer(value), "a non-negative integer", id)
end

function need.non_positive_integer(value, id)
  ensure_property(is.non_positive_integer(value), "a non-positive integer", id)
end

function need.negative_integer(value, id)
  ensure_property(is.negative_integer(value), "a negative number", id)
end

function need.string(value, id)
  ensure_property(is.string(value), "a string", id)
end

function need.table(value, id)
  ensure_property(is.table(value), "a table", id)
end

function need.table_of(kind)
  return function (value, id)
    ensure(is.table(value), 5, "Property %q must be a table containing only elements of kind %q.", id, kind)
    for i, v in ipairs(value) do
      if not is.kind(v, kind) then
        error(("All elements of %q must be of kind %q (failed on element %d)."):format(id, kind, i), 4)
      end
    end
  end
end

function need.kind(kind)
  return function (value, id)
    ensure_kind(value, kind, id)
  end
end

return need
