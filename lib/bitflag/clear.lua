local bit = require "bit"
local bnot, band, lshift = bit.bnot, bit.band, bit.lshift

return function (flags, bit)
  return band(flags, bnot(lshift(1, bit)))
end
