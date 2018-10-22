local subpath = (...):match("(.-)[^%.]+$")

return require (subpath.."Color").from_hsv
