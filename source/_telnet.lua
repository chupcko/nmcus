local telnet_class = _Util.class()

function telnet_class:constructor(port, password, timeout)
  self.port = port
  self.password = password
  self.timeout = timeout
  self.buffer_size = 1024
  self.server = nil
  self.socket = nil
  self.state = nil
end

telnet_class.output_in_use = false

function telnet_class:register_output()
  node.output(
    function(out_pipe)
      if self.socket ~= nil then
        while true do
          local data = out_pipe:read(self.buffer_size)
          if data == nil or #data == 0 then
            break
          end
          self.socket:send(data)
        end
      end
      return false
    end,
    1
  )
end

function telnet_class:clean()
  node.output(nil)
  telnet_class.output_in_use = nil
  self.socket = nil
  self.state = nil
end

function telnet_class:start()
  if self.server ~= nil then
    error(('The telnet server on port %d is already started'):format(self.port))
  end
  self.server = net.createServer(net.TCP, self.timeout);
  self.server:listen(
    self.port,
    function(socket)
      if telnet_class.output_in_use then
        socket:send('==OUTPUT ALREADY IN USE\r\n')
        socket:close()
        return
      end
      telnet_class.output_in_use = true
      self.socket = socket
      self.socket:on(
        'receive',
        function(socket, data)
          if data:byte(1) == 0xff then
            return
          end
          if self.state == 'CONNECTED' then
            if data:gsub('[\r\n]+$', '') == self.password then
              self.state = 'ALLOWED'
              self.socket:send('\255\252\001\r\n==ACCESS ALLOWED\r\n')
              self:register_output()
              node.input('\n')
            else
              self.state = 'CLOSE_AFTER_SEND'
              self.socket:send('\r\n==ACCESS DENIED\r\n')
            end
          elseif self.state == 'ALLOWED' then
            node.input(data)
          end
        end
      )
      self.socket:on(
        'sent',
        function(socket)
          if self.state == 'CLOSE_AFTER_SEND' then
            self.socket:close()
            self:clean()
          end
        end
      )
      self.socket:on(
        'disconnection',
        function(socket, code)
          self.clean()
        end
      )
      self.socket:send('==PASSWORD: \255\251\001\255\252\003')
      self.state = 'CONNECTED'
    end
 )
end

function telnet_class:stop()
  if self.server == nil then
    error(('The telnet server on port %d is not started'):format(self.port))
  end
  if self.socket ~= nil then
    self.socket:close()
    self.server:clean()
  end
  self.server = nil
end

return telnet_class
