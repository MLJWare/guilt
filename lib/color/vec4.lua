local subpath = (...):match("(.-)[^%.]+$")

return require (subpath.."Color").from_rgba_pct
