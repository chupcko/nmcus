local api_sender_class = _Util.class()

function api_sender_class:constructor(spar, name, http_connection, call_on_end)
  self.spar = spar
  self.name = name
  self.http_connection = http_connection
  self.call_on_end = call_on_end
  self.reader = self.spar:get_reader(name)
  if self.reader == false then
    return false
  end
  self:read_next()
end

function api_sender_class:read_next()
  self.reader:read_next(
    function(chunk, last)
      if last then
        self.http_connection:send(
          chunk,
          function()
            if type(self.call_on_end) == 'function' then
              self.call_on_end(true)
            end
          end,
          true
        )
      else
        self.http_connection:send(
          chunk,
          function()
            self:read_next()
          end
        )
      end
    end
  )
end

local api_class = {}

function api_class:constructor(spar, api_prefix, index_file_function)
  self.spar = spar
  self.api_prefix = api_prefix
  self.index_file_function = index_file_function
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

function api_class:get_file(http_connection)
  local uri = http_connection.uri
  if _Util.string_ends_with(uri, '/') then
    uri = uri .. self.index_file_function()
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
      local sender = _Util.new(
        api_sender_class,
        self.spar,
        uri,
        http_connection,
        function(status)
          sender = nil --@ do you need?
        end
      )
      if sender == false then
        http_connection:send_simple_response(404, 'Not Found', 'Not Found\r\n')
        sender = nil
      end
    end
  )
  return true
end

api_class.api_functions = {

  ['scan_ap'] = function(http_connection)
    _Network.scan_ap(
      function(aps)
        local data = sjson.encode(aps)
        http_connection:send_header(
          200,
          'OK',
          #data,
          'application/json',
          function()
            http_connection:send(data, nil, true)
          end
        )
      end
    )
  end,

  ['set_sta'] = function(http_connection)
  end,

  ['get_sta_state'] = function(http_connection)
  end,

  ['ok'] = function(http_connection)
    http_connection:send_simple_response(200, 'OK', 'OK\r\n')
  end

}

function api_class:execute(http_connection)
  if _Util.string_starts_with(http_connection.uri, self.api_prefix) then
    local method = http_connection.uri:sub(#self.api_prefix+1)
    if type(api_class.api_functions[method]) == 'function' then
      api_class.api_functions[method](http_connection)
      return true
    end
  end
  if http_connection.method == 'GET' then
    return self:get_file(http_connection)
  end
  if http_connection.body_file_name ~= nil then
    _Fs.delete(http_connection.body_file_name)
  end
  return false
end

return api_class
