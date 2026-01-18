local telnetd_class = _Util.class()

function telnetd_class:constructor(port, timeout, password)
  self.port = port
  self.timeout = timeout
  self.password = password
  self.buffer_size = 1024
  self.server = nil
  self.socket = nil
  self.state = nil
end

telnetd_class.output_in_use = false

function telnetd_class:register_output()
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

function telnetd_class:clean()
  node.output(nil)
  telnetd_class.output_in_use = nil
  self.socket = nil
  self.state = nil
end

function telnetd_class:start()
  if self.server ~= nil then
    error(('The telnetd on port %d is already started'):format(self.port))
  end
  self.server = net.createServer(net.TCP, self.timeout);
  self.server:listen(
    self.port,
    function(socket)
      if telnetd_class.output_in_use == true then
        socket:send('==OUTPUT ALREADY IN USE\r\n')
        socket:close()
        return
      end
      telnetd_class.output_in_use = true
      self.socket = socket
      self.socket:on(
        'receive',
        function(socket, data)
          if data:byte(1) == 0xff then
            return
          end
          if self.state == 'CONNECTED' then
            if data:gsub('[\r\n]+$', '') == _Crypt:decrypt(self.password) then
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
          self:clean()
        end
      )
      self.socket:send('==PASSWORD: \255\251\001\255\252\003')
      self.state = 'CONNECTED'
    end
  )
end

function telnetd_class:stop()
  if self.server == nil then
    error(('The telnetd on port %d is not started'):format(self.port))
  end
  if self.socket ~= nil then
    self.socket:close()
    self.server:clean()
  end
  self.server:close()
  self.server = nil
end

return telnetd_class
