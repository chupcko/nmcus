local time_module = {}

time_module.sync = function()
  sntp.sync(
    _Config.data['ntp.server'],
      function(sec, usec, server)
      end,
      function()
        error('ntp error')
      end
    )
end

time_module.time = function()
  return rtctime.get()
end

time_module.time_string = function()
  local sec, usec = rtctime.get()
  local tm = rtctime.epoch2cal(sec)
  return ('%04d-%02d-%02d %02d:%02d:%02d.%06d UTC'):format(tm.year, tm.mon, tm.day, tm.hour, tm.min, tm.sec, usec)
end

return time_module
