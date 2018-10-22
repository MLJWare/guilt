local subpath = (...):match("(.-)[^%.]+$")

return require (subpath.."Color").from_rgb_pct
