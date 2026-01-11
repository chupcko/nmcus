local api_module = {}

api_module.execute = function(http_connection)
  _Util.dump(http_connection.method, http_connection.uri, http_connection.headers, http_connection.body)--# remove
  http_connection:send_simple_response(200, 'OK', 'OK\r\n')
  return true
end

return api_module
