local config_class = _Util.class()

function config_class:constructor(file_name, data_init, key_f)
  self.file_name = file_name
  self.data = data_init
  self.key_f = key_f
  local data_s = self:load()
  if data_s ~= nil then
    self:set(data_s)
  end
end

function config_class:get()
  return _Util.to_string(self.data, false)
end

function config_class:set(data_s)
  local data_f = loadstring(('return %s'):format(data_s))
  if data_f == nil then
    error(('Bad content of \'%s\''):format(self.file_name))
  end
  self.data = data_f()
end

function config_class:load()
  local data_s = nil
  if file.exists(self.file_name) == true then
    data_s = file.getcontents(self.file_name)
    if data_s == nil then
      error(('Cannot load \'%s\''):format(self.file_name))
    end
    data_s = crypto.decrypt(
      'AES-ECB',
      encoder.toHex(crypto.hash('MD5', self.key_f())),
      encoder.fromBase64(data_s)
    )
    local nul_location = data_s:find('\0', 1, true)
    if nul_location ~= nil then
      data_s = data_s:sub(1, nul_location-1)
    end
  end
  return data_s
end

function config_class:save()
  if file.putcontents(
    self.file_name,
    encoder.toBase64(
      crypto.encrypt(
        'AES-ECB',
        encoder.toHex(crypto.hash('MD5', self.key_f())),
        self:get()
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
