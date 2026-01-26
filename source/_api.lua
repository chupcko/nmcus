local api_class = {}

function api_class:constructor(spar, index_file)
  self.spar = spar
  self.index_file = index_file
end

api_class.mime_types = {
  ['css']  = 'text/css',
  ['gif']  = 'image/gif',
  ['html'] = 'text/html',
  ['ico']  = 'image/x-icon',
  ['jpg']  = 'image/jpeg',
  ['js']   = 'text/javascript',
  ['json'] = 'application/json',
  ['png']  = 'image/png',
  ['svg']  = 'image/svg+xml',
  ['txt']  = 'text/plain',
  ['xml']  = 'application/xml'
}

api_class.get_mime_type = function(file_name)
  local ext = file_name:match('%.([^.]+)$')
  if ext ~= nil then
    ext = ext:lower()
    local mime_type = api_class.mime_types[ext]
    if mime_type ~= nil then
      return mime_type
    end
  end
  return 'application/octet-stream'
end

function api_class:execute(http_connection)
  if _Util.string_starts_with(http_connection.uri, '/api') then
    http_connection:send_simple_response(200, 'OK', 'OK\r\n')
    return true
  end
  if http_connection.method == 'GET' then
    local uri = http_connection.uri
    if _Util.string_ends_with(uri, '/') then
      uri = uri .. self.index_file
    end
    local size = self.spar:get_size(uri)
    if size == nil then
      return false
    end
    http_connection:send_header(
      200,
      'OK',
      size,
      api_class.get_mime_type(uri),
      function()
        local reader = self.spar:get_reader(
          uri,
          http_connection,
          function()
            reader = nil --@ do you need?
          end
        )
      end
    )
    return true
  end
  return false
end

return api_class
