local is = {}

function is.callable(x)
  if type(x) == "function" then return true end
  local meta = getmetatable(x)
  return meta and type(meta.__call) == "function"
end

function is.number(value)
  return type(value) == "number" and value == value
end

function is.positive_number(value)
  return type(value) == "number" and value > 0
end

function is.non_negative_number(value)
  return type(value) == "number" and value >= 0
end

function is.non_positive_number(value)
  return type(value) == "number" and value <= 0
end

function is.negative_number(value)
  return type(value) == "number" and value < 0
end

function is.integer(value)
  return type(value) == "number" and value%1==0
end

function is.positive_integer(value)
  return type(value) == "number" and value > 0 and value%1==0
end

function is.non_negative_integer(value)
  return type(value) == "number" and value >= 0 and value%1==0
end

function is.non_positive_integer(value)
  return type(value) == "number" and value <= 0 and value%1==0
end

function is.negative_integer(value)
  return type(value) == "number" and value < 0 and value%1==0
end

function is.string(value)
  return type(value) == "string"
end

function is.table(value)
  return type(value) == "table"
end

function is.kind(value, kind)
  local value_type = type(value)
  if value_type ~= "table" then return value_type == kind end
  local meta = getmetatable(value)
  return type(meta) == "table"
     and meta._kind_ == kind
end

return is
