local fs_module = {}

local fs_upload_class = _Util.class()

function fs_upload_class:constructor(file_name)
  self.file_name = file_name
  self.file = file.open(self.file_name, 'w')
end

function fs_upload_class:write(data)
  if self.file == nil then
    return
  end
  data:gsub(
    '([0-9a-zA-Z][0-9a-zA-Z])',
    function(hex)
      self.file:write(string.char(tonumber(hex, 16)))
      return ''
    end
  )
end

function fs_upload_class:close()
  if self.file == nil then
    return
  end
  self.file:close()
end

fs_module.upload = function(file_name)
  return _Util.new(fs_upload_class, file_name)
end

fs_module.list = function()
  local files = file.list()
  print('==LIST start')
  for name, size in pairs(files) do
    print(('\'%s\' %d'):format(name, size))
  end
  print('==LIST end')
end

fs_module.dump = function(file_name)
  local file = file.open(file_name, 'r')
  if file == nil then
    return
  end
  local buffer = ''
  print('==FILE start')
  while true do
    local data = file:read(256)
    if data == nil then
      break
    end
    buffer = buffer .. data
    while true do
      local end_line_start, end_line_end = buffer:find('\r?\n')
      if end_line_start == nil then
        break
      end
      print(buffer:sub(1, end_line_start-1))
      buffer = buffer:sub(end_line_end+1)
    end
  end
  if #buffer > 0 then
    print(buffer)
  end
  file:close()
  print('==FILE end')
end

fs_module.dump_hex = function(file_name, offset)
  if offset == nil then
    offset = 0
  end
  local file = file.open(file_name, 'r')
  if file == nil then
    return
  end
  file:seek('set', offset)
  local i = offset
  print('==HEX start')
  while true do
    local data = file:read(16)
    if data == nil then
      break
    end
    local row = {}
    for k = 1, #data do
      if k == 1 then
        table.insert(row, ('%02x'):format(data:byte(k)))
      else
        table.insert(row, (' %02x'):format(data:byte(k)))
      end
    end
    print(('%08x %s'):format(i, table.concat(row)))
    i = i+#data
  end
  file:close()
  print('==HEX end')
end

fs_module.delete = function(file_name)
  file.remove(file_name)
end

return fs_module
