local band, lshift
do
  local bit = require "bit"
  band, lshift = bit.band, bit.lshift
end

return function (flags, bit)
  return band(flags, lshift(1, bit)) ~= 0
end
