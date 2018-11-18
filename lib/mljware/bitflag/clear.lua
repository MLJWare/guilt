local bnot, band, lshift
do
  local bit = require "bit"
  bnot, band, lshift = bit.bnot, bit.band, bit.lshift
end

return function (flags, bit)
  return band(flags, bnot(lshift(1, bit)))
end
