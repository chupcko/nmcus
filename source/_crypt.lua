local crypt_class = _Util.class()

function crypt_class:constructor(key_function)
  self.key_function = key_function
end

function crypt_class:encrypt(data)
  return encoder.toBase64(
    crypto.encrypt(
      'AES-CBC',
      encoder.toHex(crypto.hash('MD5', self.key_function())),
      data
    )
  )
end

function crypt_class:decrypt(data)
  local status, result = pcal(
    function()
      return crypto.decrypt(
        'AES-CBC',
        encoder.toHex(crypto.hash('MD5', self.key_function())),
        encoder.fromBase64(data)
      )
    end
  )
  if status == false then
    return nil
  end
  local nul_location = result:find('\0', 1, true)
  if nul_location ~= nil then
    result = result:sub(1, nul_location-1)
  end
  return result
end

return crypt_class
