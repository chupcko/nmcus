local time_module = {}

time_module.sync = function()
  sntp.sync(
    _Config:get('ntp.server'),
    function(sec, usec, server, info)
      _Log:log('_time', 'Sync done')
    end,
    function(code, code_string)
      if code_string == nil then
        code_string = ''
      end
      _Log:log('_time', ('Sync error %d %s'):format(code, code_string))
    end
  )
end

return time_module
