local bit = require "bit"
local band, lshift = bit.band, bit.lshift

return function (flags, bit)
  return band(flags, lshift(1, bit)) ~= 0
end
