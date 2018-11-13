local path = (...)
local sub1 = path:match("(.-)%.[^%.]+$")
local sub2 = sub1:match("(.-)%.[^%.]+$")
local sub3 = sub2:match("(.-)%.[^%.]+$")
local sub4 = sub3:match("(.-)%.[^%.]+$")

local guilt                   = require (sub3)
local try_invoke              = require (sub3..".pleasure.try").invoke

local namespace = guilt.namespace("material-design")

local RadioGroup = namespace:template("RadioGroup")

RadioGroup.preferred_width  = 0
RadioGroup.preferred_height = 0

function RadioGroup:init()
  self._children = {}
end

function RadioGroup:select(selected)
  local previous_selected = self.selected
  self.selected = selected

  for _, child in ipairs(self._children) do
    child.checked = (child == selected)
  end
  if previous_selected ~= selected then
    try_invoke(self, "on_change", selected, previous_selected)
  end
end

namespace:finalize_template(RadioGroup)
