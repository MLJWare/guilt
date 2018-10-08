local INVOKER = {
  __call = function (invoker, self, ...)
    local callback = invoker["_always_"]
    if callback then callback(self, ...) end

    local state = self.state
    if state then
      local callback = invoker[state]
      if callback then return callback(self, ...) end
    end

    local callback = invoker["_default_"]
    if callback then return callback(self, ...) end
  end;
}
return function ()
  return setmetatable({}, INVOKER)
end
