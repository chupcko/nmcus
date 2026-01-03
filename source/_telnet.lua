local telnet_class = _Util.class()

function telnet_class:constructor(port, password, timeout)
  self.port = port
  self.password = password
  self.timeout = timeout
  self.buffer_size = 1024
  self.server = nil
end

function telnet_class:start()
  self.server = net.createServer(net.TCP, self.timeout);
  self.server:listen(
    self.port,
    function(connection)
      node.output(
        function(out_pipe)
          if connection ~= nil then
            while true do
              local data = out_pipe:read(self.buffer_size)
              if data == nil or #data == 0 then
                break
              end
              connection:send(data)
            end
          end
          return false
        end,
        1
      )
      connection:on(
        'receive',
        function(connection, data)
          node.input(data)
        end
      )
      connection:on(
        'disconnection',
        function(connection)
          node.output(nil)
        end
      )
      connection:send('READY\n')
      node.input('\n')
    end
  )
end

function telnet_class:stop()
  self.server:close()
  self.server = nil
end

return telnet_class
