local config_class = _Util.class()

function config_class:constructor(file_name, crypt, data_init)
  self.file_name = file_name
  self.crypt = crypt
  self.data = data_init
  self:load()
end

function config_class:get(key)
  return self.data[key]
end

function config_class:set(key, value)
  self.data[key] = value
end

function config_class:load()
  if file.exists(self.file_name) == false then
    return
  end
  local data_string = file.getcontents(self.file_name)
  if data_string == nil then
    error(('Cannot load \'%s\''):format(self.file_name))
  end
  local result, data = pcall(sjson.decode, self.crypt:decrypt(data_string))
  if result == false then
    error(('Bad content of \'%s\''):format(self.file_name))
  end
  self.data = _Util.table_shallow_copy(data)
end

function config_class:save()
  if file.putcontents(self.file_name, self.crypt:encrypt(sjson.encode(self.data))) == nil then
    error(('Cannot save \'%s\''):format(self.file_name))
  end
end

function config_class:delete()
  file.remove(self.file_name)
end

return config_class
