local path = (...)

for _, element in ipairs(love.filesystem.getDirectoryItems(path:gsub("%.", "/"))) do
  if element ~= "init.lua" and element:find("^[A-Z][^%.]*%.lua$") then
    require (("%s.%s"):format(path, element:sub(1, -5)))
  end
end
