local api_class = {}

function api_class:constructor(spar, index_file)
  self.spar = spar
  self.index_file = index_file
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
    local size = _Spar:get_size(uri)
    if size ~= nil then
      http_connection:send_header(200, 'OK', size)
      _Spar:read(
        uri,
        function(data)
          http_connection:send(data)
        end
      )
      http_connection:want_close_on_sent()
      return true
    end
  end
  return false
end

return api_class
