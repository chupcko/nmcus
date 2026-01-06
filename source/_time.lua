local time_module = {}

time_module.sync = function()
  sntp.sync(
    _Config:get('ntp.server'),
    function(sec, usec, server, info)
      _Log:log('_time', 'Sync done')
    end,
    function(code, code_string)
      _Log:log('_time', ('Sync error %d %s'):format(code, code_string))
    end
  )
end

time_module.now = function()
  local sec, usec = rtctime.get()
  return sec, usec
end

time_module.string = function(sec, usec)
  local tm = rtctime.epoch2cal(sec)
  return ('%04d-%02d-%02d %02d:%02d:%02d.%06d UTC'):format(tm.year, tm.mon, tm.day, tm.hour, tm.min, tm.sec, usec)
end

return time_module
