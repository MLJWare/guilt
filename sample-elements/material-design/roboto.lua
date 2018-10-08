local OS = love.system.getOS()

local font_path = "res/font/%s/%s.ttf"

local dpi_scale = love.window.getDPIScale()
local function make_font(typeface, weight, size)
  return love.graphics.newFont(font_path:format(typeface, weight), size*dpi_scale);
end

return {
  H1        = make_font( "Roboto" , "Light"   , 96);
  H2        = make_font( "Roboto" , "Light"   , 60);
  H3        = make_font( "Roboto" , "Regular" , 48);
  H4        = make_font( "Roboto" , "Regular" , 34);
  H5        = make_font( "Roboto" , "Regular" , 24);
  H6        = make_font( "Roboto" , "Medium"  , 20);
  subtitle1 = make_font( "Roboto" , "Regular" , 16);
  subtitle2 = make_font( "Roboto" , "Medium"  , 14);
  body1     = make_font( "Roboto" , "Regular" , 16);
  body2     = make_font( "Roboto" , "Regular" , 14);
  button    = make_font( "Roboto" , "Medium"  , 14);
  caption   = make_font( "Roboto" , "Regular" , 12);
  overline  = make_font( "Roboto" , "Regular" , 10);
}
