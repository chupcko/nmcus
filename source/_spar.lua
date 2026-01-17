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
      return nil
    end
    value = bit.bor(bit.lshift(value, 8), byte:byte())
  end
  return value
end

function spar_class:init()
  self.file = file.open(self.file_name, 'r')
  if self.file == nil then
    _Log:log('_spar', ('Cannot open \'%s\''):format(self.file_name))
    return
  end
  if self.file:read(4) ~= 'SPAR' then
    _Log:log('_spar', ('Missing magic in \'%s\''):format(self.file_name))
    self.file:close()
    return
  end
  local data_len = self.file:read(1)
  if data_len == nil then
    _Log:log('_spar', ('Missing version size in \'%s\''):format(self.file_name))
    self.file:close()
    return
  end
  local data = self.file:read(data_len:byte())
  if data == nil then
    _Log:log('_spar', ('Missing version in \'%s\''):format(self.file_name))
    self.file:close()
    return
  end
  if data ~= _Consts['version'] then
    _Log:log('_spar', ('Bad version %s of \'%s\', must be %s'):format(data, self.file_name, _Consts['version']))
    self.file:close()
    return
  end
  self.files_size = self:read_uint(2)
  if self.files_size == nil then
    _Log:log('_spar', ('Missing files number in \'%s\''):format(self.file_name))
    self.file:close()
    return
  end
  for i = 1, self.files_size do
    data_len = self.file:read(1)
    if data_len == nil then
      _Log:log('_spar', ('Missing file name size in \'%s\''):format(self.file_name))
      self.file:close()
      return
    end
    data = self.file:read(data_len:byte())
    if data == nil then
      _Log:log('_spar', ('Missing file name in \'%s\''):format(self.file_name))
      self.file:close()
      return
    end
    local offset =  self:read_uint(4)
    if offset == nil then
      _Log:log('_spar', ('Missing file offset in \'%s\''):format(self.file_name))
      self.file:close()
      return
    end
    local size =  self:read_uint(4)
    if size == nil then
      _Log:log('_spar', ('Missing file size in \'%s\''):format(self.file_name))
      self.file:close()
      return
    end
    self.files[data] = { offset = offset, size = size }
  end
   _Log:log('_spar', ('Loaded index from \'%s\''):format(self.file_name))
end

function spar_class:get_size(name)
  if self.file == nil then
    return nil
  end
  local file = self.files[name]
  if file == nil then
    return nil
  end
  return file.size
end

function spar_class:read(name, call)
  if self.file == nil then
    return nil
  end
  local file = self.files[name]
  if file == nil then
    return nil
  end
  self.file:seek('set', file.offset)
  local left = file.size
  while left > 0 do
    local chunk = self.file:read(math.min(self.read_buffer_size, left))
    if chunk == nil then
      return nil
    end
    left = left-#chunk
    call(chunk)
  end
  return true
end

return spar_class
