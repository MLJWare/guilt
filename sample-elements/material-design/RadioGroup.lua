local guilt                   = require "lib.guilt"
local try_invoke              = require "lib.guilt.pleasure.try".invoke

local RadioGroup = guilt.template("RadioGroup")

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

guilt.finalize_template(RadioGroup)
