local http_connection_class = _Util.class()

function http_connection_class:constructor(httpd, socket)
  self.httpd = httpd
  self.socket = socket
  self.state = nil
  self.method = nil
  self.uri = nil
  self.headers = {}
  self.body_size = 0
  self.body = ''
  socket:on(
    'receive',
    function(socket, data)
      self.body = self.body .. data
      self:processing()
    end
  )
  socket:on(
    'sent',
    function(socket)
      if self.state == 'CLOSE_ON_SENT' then
        self.socket:close()
        self:destructor()
      end
    end
  )
  socket:on(
    'disconnection',
    function(socket, code)
      self:destructor()
    end
  )
end

function http_connection_class:destructor()
  self.httpd:unregister_connection(self)
end

function http_connection_class:want_close_on_sent()
  self.state = 'CLOSE_ON_SENT'
end

function http_connection_class:send_header(code, status, length, type)
  if type == nil then
    type = 'text/html'
  end
  local output = {}
  table.insert(output, ('HTTP/1.1 %d %s\r\n'):format(code, status))
  table.insert(output, ('Content-Type: %s\r\n'):format(type))
  if length ~= nil then
    table.insert(output, ('Content-Length: %d\r\n'):format(length))
  end
  table.insert(output, 'Connection: close\r\n')
  table.insert(output, '\r\n')
  self.socket:send(table.concat(output))
end

function http_connection_class:send_simple_response(code, status, text)
  self:send_header(code, status, text:len())
  self.socket:send(text)
  self:want_close_on_sent()
end

function http_connection_class:get_line(input)
  local end_line_start, end_line_end = self.body:find('\r?\n')
  if end_line_start == nil then
    return
  end
  local line = self.body:sub(1, end_line_start-1)
  self.body = self.body:sub(end_line_end+1)
  return line
end

function http_connection_class:processing()
  while true do
    if self.state == nil then
      local line = self:get_line()
      if line == nil then
        return
      end
      local version
      self.method, self.uri, version = line:match('^(%S*)%s(%S*)%s(.*)$')
      if self.method == nil then
        self:send_simple_response(400, 'Bad Request', 'Bad Request: bad method, uri, version\r\n')
        return
      end
      self.state = 'IN_HEADER'
    elseif self.state == 'IN_HEADER' then
      local line = self:get_line()
      if line == nil then
        return
      end
      if line == '' then
        self.state = 'HEADER_END'
      else
        local tag, value = line:match('^([^:]+):%s(.*)$')
        if tag == nil then
          self:send_simple_response(400, 'Bad Request', 'Bad Request: bad header\r\n')
          return
        end
        self.headers[tag] = value
      end
    elseif self.state == 'HEADER_END' then
      if self.method == 'POST' or self.method == 'PUT' then
        self.body_size = self.headers['Content-Length']
        if self.body_size == nil then
          self:send_simple_response(400, 'Bad Request', 'Bad Request: missing length\r\n')
          return
        end
        self.body_size = tonumber(self.body_size)
        self.state = 'IN_BODY'
      else
        self.state = 'DONE'
      end
    elseif self.state == 'IN_BODY' then
      if self.body:len() < self.body_len then
        return
      end
      self.state = 'DONE'
    elseif self.state == 'DONE' then
      local result = self.httpd.execute(self)
      if result == nil then
        self:send_simple_response(500, 'Internal Server Error', 'Internal Server Error\r\n')
        return
      end
      if result == false then
        self:send_simple_response(404, 'Not Found', 'Not Found\r\n')
        return
      end
      self:want_close_on_sent()
      return
    end
  end
end

local httpd_class = _Util.class()

function httpd_class:constructor(port, timeout, execute)
  self.port = port
  self.timeout = timeout
  self.execute = execute
  self.server = nil
  self.http_connections = {}
end

function httpd_class:unregister_connection(connection)
  self.http_connections[connection] = nil
end

function httpd_class:start()
  if self.server ~= nil then
    error(('The httpd on port %d is already started'):format(self.port))
  end
  self.server = net.createServer(net.TCP, self.timeout);
  self.server:listen(
    self.port,
    function(socket)
      local http_connection = _Util.new(http_connection_class, self, socket)
      self.http_connections[http_connection] = http_connection
    end
  )
end

function httpd_class:stop()
  if self.server == nil then
    error(('The httpd on port %d is not started'):format(self.port))
  end
  for http_connection in pairs(self.http_connections) do
    http_connection.socket:close()
    self.http_connections[http_connection] = nil
  end
  self.server:close()
  self.server = nil
end

return httpd_class
