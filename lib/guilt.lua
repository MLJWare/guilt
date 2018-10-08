local path = (...)
local is                      = require (path..".pleasure.is")
local invoker                 = require (path..".pleasure.invoker")
local clone                   = require (path..".pleasure.clone")

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
local _templates = {}
local _needs = {}

local function _new(template, props)
  local self = props or {}
  for k, v in pairs(template) do
    if not (is.string(k) and k:find("^__")) then
      self[k] = clone(v)
    end
  end
  setmetatable(self, template)
  self:init()
  return self
end

function guilt.new(template_id, props)
  insist(is.string(template_id), "Template id must be a string.")
  local template = _templates[template_id]
  insist(is.table(template), "No template named %q exist.", template_id)
  insist(getmetatable(template) ~= Template, "Template %q must be finalized before use.", template_id)

  local needs = _needs[template_id]
  if needs then
    insist(is.table (props), "Template `%s` needs property table on creation.", template_id)
    enforce(needs, props)
  end

  return _new(template, props)
end

function guilt.template(template_id)
  insist(is.string(template_id), "Template id must be a string.")

  local template = setmetatable({}, Template)

  _templates[template_id] = template
  _templates[template] = template_id

  return template
end

-- TODO more code to finalize template?
function guilt.finalize_template(template)
  insist(is.table(template) and getmetatable(template) == Template, "Template provided must be an actual guilt Template.")
  setmetatable(template, nil)
  template.__index = template
end

function Template:from(parent)
  -- TODO extend self with parent
  return self
end

function Template:needs(props)
  insist(is.table(props), "Argument to `Template:needs` must be a table.")

  for need, enforcer in pairs(props) do
    insist(is.string(need), "Name of need must be a string.")
    insist(is.callable(enforcer), "Enforcer of need `%s` must callable.", need)
  end

  local name = _templates[self]
  _needs[name] = props

  return self
end

return guilt
