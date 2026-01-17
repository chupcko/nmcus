local config_class = _Util.class()

function config_class:constructor(file_name, data_init, key_function)
  self.file_name = file_name
  self.data = data_init
  self.key_function = key_function
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
  data_string = file.getcontents(self.file_name)
  if data_string == nil then
    error(('Cannot load \'%s\''):format(self.file_name))
  end
  data_string = crypto.decrypt(
    'AES-ECB',
    encoder.toHex(crypto.hash('MD5', self.key_function())),
    encoder.fromBase64(data_string)
  )
  local nul_location = data_string:find('\0', 1, true)
  if nul_location ~= nil then
    data_string = data_string:sub(1, nul_location-1)
  end
  result, self.data = pcall(sjson.decode, data_string)
  if result == false then
    self.data = {}
    error(('Bad content of \'%s\''):format(self.file_name))
  end
end

function config_class:save()
  if file.putcontents(
    self.file_name,
    encoder.toBase64(
      crypto.encrypt(
        'AES-ECB',
        encoder.toHex(crypto.hash('MD5', self.key_function())),
        sjson.encode(self.data)
      )
    )
  ) == nil then
    error(('Cannot save \'%s\''):format(self.file_name))
  end
end

function config_class:delete()
  file.remove(self.file_name)
end

return config_class
