local telnet_class = _Util.class()

function telnet_class:constructor(port, password, timeout)
  self.port = port
  self.password = password
  self.timeout = timeout
  self.buffer_size = 1024
  self.server = nil
  self.connection = nil
  self.authorized = false
end

function telnet_class:start()
  if self.server ~= nil then
    error(('The telnet server on port %d is already started'):format(self.port))
  end
  self.server = net.createServer(net.TCP, self.timeout);
  self.server:listen(
    self.port,
    function(connection)
      if self.connection ~= nil then
        connection:send('ALREADY CONNECTED\n')
        connection:close()
        return
      end
      self.connection = connection
      node.output(
        function(out_pipe)
          if self.connection ~= nil and self.authorized then
            while true do
              local data = out_pipe:read(self.buffer_size)
              if data == nil or #data == 0 then
                break
              end
              self.connection:send(data)
            end
          end
          return false
        end,
        1
      )
      self.connection:on(
        'receive',
        function(connection, data)
          print('DEBUG CONNECTION RECEIVE"'..data..'"')
          if self.authorized then
            node.input(data)
          else
            if data:gsub('\n$', '') == self.password then
              self.connection:send('AUTHORIZED\n')
              self.authorized = true
--              node.input('\n')
--            else
--              self.connection:send('ACCESS DENIED')
--              self.connection:close()
            end
         end
        end
      )
      self.connection:on(
        'disconnection',
        function(connection)
          self.connection = nil
          self.authorized = false
          node.output(nil)
        end
      )
      self.connection:send('CONNECTED\n')
      node.input('\n')
    end
  )
end

function telnet_class:stop()
  if self.server == nil then
    error(('The telnet server on port %dis not started'):format(self.port))
  end
  self.server:close()
  self.server = nil
end

return telnet_class
