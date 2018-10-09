local bit = require "bit"
local bor, lshift = bit.bor, bit.lshift

return function (flags, bit)
  return bor(flags, lshift(1, bit))
end
