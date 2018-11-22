local subpath = (...):match("(.-)[^%.]+$")
local rgb2hsv                 = require (subpath.."rgb2hsv")
local hsv2rgb                 = require (subpath.."hsv2rgb")

local _cache = {}

local Color = {
  _kind_     = "Color";
  __tostring = function (self)
    local r, g, b, a = unpack(self)
    r = r*255
    g = g*255
    b = b*255
    a = a*255
    return string.format("#%02X%02X%02X%02X", r, g, b, a)
  end;
}
Color.__index = Color

local function new_Color(r, g, b, a, h, s, v)
  return setmetatable({
    r,g,b,a;
    _hue = h;
    _sat = s;
    _val = v;
  }, Color)
end

function Color.from_rgba_pct(r, g, b, a)
  r = r <= 0 and 0 or r >= 1 and 1 or r
  g = g <= 0 and 0 or g >= 1 and 1 or g
  b = b <= 0 and 0 or b >= 1 and 1 or b
  a = a <= 0 and 0 or a >= 1 and 1 or a
  local id = string.format("#%02X%02X%02X%02X", r*255, g*255, b*255, a*255)
  if not _cache[id] then
    _cache[id] = new_Color(r,g,b,a,rgb2hsv(r,g,b))
  end
  return _cache[id]
end

function Color.from_hsva(h, s, v, a)
  local r, g, b = hsv2rgb(h,s,v)
  local id = string.format("#%02X%02X%02X%02X", r*255, g*255, b*255, a*255)
  if not _cache[id] then
    _cache[id] = new_Color(r,g,b,a,h,s,v)
  end
  return _cache[id]
end

function Color.from_hsv(h, s, v)
  return Color.from_hsva(h,s,v,1)
end

function Color.from_rgb_pct(r, g, b)
  return Color.from_rgba_pct(r, g, b, 1)
end

function Color.from_rgba_int(r, g, b, a)
  return Color.from_rgba_pct(r/255, g/255, b/255, a)
end

function Color.from_rgb_int(r, g, b)
  return Color.from_rgba_pct(r/255, g/255, b/255, 1)
end

function Color:brighten(pct)
  local r,g,b,a = unpack(self)
  return Color.from_rgba_pct(r+r*pct, g+g*pct, b+b*pct, a)
end

function Color:darken(pct)
  local r,g,b,a = unpack(self)
  return Color.from_rgba_pct(r-r*pct, g-g*pct, b-b*pct, a)
end

function Color:alpha(pct)
  local r,g,b,a = unpack(self)
  return Color.from_rgba_pct(r, g, b, a*pct)
end

Color.BLACK = Color.from_rgba_pct(0,0,0,1)
Color.WHITE = Color.from_rgba_pct(1,1,1,1)

return Color
