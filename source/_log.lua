local log_class = _Util.class()

function log_class:constructor(size)
  self.size = size
  self.data = {}
end

function log_class:clean()
  self.data = {}
end

function log_class:log(who, message)
  if #self.data >= self.size then
    table.remove(self.data, 1)
  end
  local sec, usec = _Time.now()
  table.insert(self.data, { sec, usec, who, message })
end

function log_class:print()
  print('LOG start')
  for k, v in ipairs(self.data) do
    local time_string = _Time.string(v[1], v[2])
    print(('%s %s %s'):format(time_string, v[3], v[4]))
  end
  print('LOG end')
end

return log_class
