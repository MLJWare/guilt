local bor, lshift
do
  local bit = require "bit"
  bor, lshift = bit.bor, bit.lshift
end
return function (flags, bit)
  return bor(flags, lshift(1, bit))
end
