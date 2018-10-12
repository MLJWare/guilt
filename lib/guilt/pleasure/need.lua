local subpath = (...):match("(.-)[^%.]+$")
local is                      = require (subpath.."is")

local need = {}

local function ensure(condition, specific, id)
  if condition then return end
  error(("Property `%s` must be %s."):format(id, specific), 3)
end

local function ensure_kind(value, kind, id)
  if is.kind(value, kind) then return end
  error(("Property `%s` must be of kind %q."):format(id, kind), 5)
end

function need.number(value, id)
  ensure(is.number(value), "a number", id)
end

function need.positive_number(value, id)
  ensure(is.positive_number(value), "a positive number", id)
end

function need.non_negative_number(value, id)
  ensure(is.non_negative_number(value), "a non-negative number", id)
end

function need.non_positive_number(value, id)
  ensure(is.non_positive_number(value), "a non-positive number", id)
end

function need.negative_number(value, id)
  ensure(is.negative_number(value), "a negative number", id)
end

function need.integer(value, id)
  ensure(is.integer(value), "a integer", id)
end

function need.positive_integer(value, id)
  ensure(is.positive_integer(value), "a positive integer", id)
end

function need.non_negative_integer(value, id)
  ensure(is.non_negative_integer(value), "a non-negative integer", id)
end

function need.non_positive_integer(value, id)
  ensure(is.non_positive_integer(value), "a non-positive integer", id)
end

function need.negative_integer(value, id)
  ensure(is.negative_integer(value), "a negative number", id)
end

function need.string(value, id)
  ensure(is.string(value), "a string", id)
end

function need.table(value, id)
  ensure(is.table(value), "a table", id)
end

function need.kind(kind)
  return function (value, id)
    ensure_kind(value, kind, id)
  end
end

return need
