local spar_class = _Util.class()

function spar_class:constructor(file_name)
  self.file_name = file_name
  self.read_buffer_size = 1024
  self.file = nil
  self.files_size = 0
  self.files = {}
  self:init()
end

function spar_class:close()
  if self.file ~= nil then
    self.file:close()
    self.file = nil
  end
end

function spar_class:read_uint(size)
  local value = 0
  for i = 1, size do
    local byte = self.file:read(1)
    if byte == nil then
      return
    end
    value = bit.bor(bit.lshift(value, 8), byte:byte())
  end
  return value
end

function spar_class:init()
  self.file = file.open(self.file_name, 'r')
  if self.file == nil then
    --@ log
    print('cant open')
    return
  end
  if self.file:read(4) ~= 'SPAR' then
    --@ log
    print('missing magic')
    self.file:close()
    return
  end
  local data_len = self.file:read(1)
  if data_len == nil then
    --@ log
    print('missing version size')
    self.file:close()
    return
  end
  local data = self.file:read(data_len:byte())
  if data == nil then
    --@ log
    print('missing version')
    self.file:close()
    return
  end
  if data ~= _Consts['version'] then
    --@ log
    print('bad version')
    self.file:close()
    return
  end
  self.files_size = self:read_uint(2)
  if self.files_size == nil then
    --@ log
    print('missing files size')
    self.file:close()
    return
  end
  for i = 1, self.files_size do
    data_len = self.file:read(1)
    if data_len == nil then
      --@ log
      self.file:close()
      return
    end
    data = self.file:read(data_len:byte())
    if data == nil then
      --@ log
      self.file:close()
      return
    end
    local offset =  self:read_uint(4)
    if offset == nil then
      --@ log
      self.file:close()
      return
    end
    local size =  self:read_uint(4)
    if size == nil then
      --@ log
      self.file:close()
      return
    end
    self.files[data] = { offset = offset, size = size }
  end
   _Log:log('_spar', ('Loaded index %s'):format(self.file_name))
end

function spar_class:get_size(name)
  if self.file == nil then
    return
  end
  local file = self.files[name]
  if file == nil then
    return
  end
  return file.size
end

function spar_class:read(name, call)
  if self.file == nil then
    return
  end
  local file = self.files[name]
  if file == nil then
    return
  end
  self.file:seek('set', file.offset)
  local left = file.size
  while left > 0 do
    local chunk = self.file:read(math.min(self.read_buffer_size, left))
    if chunk == nil then
      return
    end
    left = left-#chunk
    call(chunk)
  end
  return true
end

return spar_class
