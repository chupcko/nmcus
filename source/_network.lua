local network_module = {}

network_module.registers_set = function(calls_on)

  wifi.eventmon.register(
    wifi.eventmon.AP_PROBEREQRECVED,
    function(result)
      _Log:log('_network', ('ap_probereqrecved %s'):format(_Util.to_string(result, false)))
      if type(calls_on.ap_probereqrecved) == 'function' then
        calls_on.ap_probereqrecved(result)
      end
    end
  )

  wifi.eventmon.register(
    wifi.eventmon.AP_STACONNECTED,
    function(result)
      _Log:log('_network', ('ap_staconnected %s'):format(_Util.to_string(result, false)))
      if type(calls_on.ap_staconnected) == 'function' then
        calls_on.ap_staconnected(result)
      end
    end
  )

  wifi.eventmon.register(
    wifi.eventmon.AP_STADISCONNECTED,
    function(result)
      _Log:log('_network', ('ap_stadisconnected %s'):format(_Util.to_string(result, false)))
      if type(calls_on.ap_stadisconnected) == 'function' then
        calls_on.ap_stadisconnected(result)
      end
    end
  )

  wifi.eventmon.register(
    wifi.eventmon.STA_AUTHMODE_CHANGE,
    function(result)
      _Log:log('_network', ('sta_authmode_change %s'):format(_Util.to_string(result, false)))
      if type(calls_on.sta_authmode_change) == 'function' then
        calls_on.sta_authmode_change(result)
      end
    end
  )

  wifi.eventmon.register(
    wifi.eventmon.STA_CONNECTED,
    function(result)
      _Log:log('_network', ('sta_connected %s'):format(_Util.to_string(result, false)))
      if type(calls_on.sta_connected) == 'function' then
        calls_on.sta_connected(result)
      end
    end
  )

  wifi.eventmon.register(
    wifi.eventmon.STA_DHCP_TIMEOUT,
    function(result)
      _Log:log('_network', ('sta_dhcp_timeout %s'):format(_Util.to_string(result, false)))
      if type(calls_on.sta_dhcp_timeout) == 'function' then
        calls_on.sta_dhcp_timeout(result)
      end
    end
  )

  wifi.eventmon.register(
    wifi.eventmon.STA_DISCONNECTED,
    function(result)
      _Log:log('_network', ('sta_disconnected %s'):format(_Util.to_string(result, false)))
      if type(calls_on.sta_disconnected) == 'function' then
        calls_on.sta_disconnected(result)
      end
    end
  )

  wifi.eventmon.register(
    wifi.eventmon.STA_GOT_IP,
    function(result)
      _Log:log('_network', ('sta_got_ip %s'):format(_Util.to_string(result, false)))
      if type(calls_on.sta_got_ip) == 'function' then
        calls_on.sta_got_ip(result)
      end
    end
  )

end

network_module.start = function()
  local mode = _Config:get('wifi.mode')
  if mode == 'ap' then
    wifi.setmode(wifi.STATIONAP, false)
    wifi.ap.setip(
      {
        ip      = _Config:get('wifi.ap.ip'),
        netmask = _Config:get('wifi.ap.netmask'),
        gateway = _Config:get('wifi.ap.gateway'),
        save    = false
      }
    )
    wifi.ap.config(
      {
        ssid    = _Config:get('wifi.ap.ssid'),
        pwd     = _Crypt:decrypt(_Config:get('wifi.ap.password')),
        auth    = wifi.WPA_WPA2_PSK,
        save    = false
      }
    )
    wifi.ap.dhcp.config(
      {
        start = _Config:get('wifi.ap.dhcp_start')
      }
    )
    wifi.ap.dhcp.start()
  elseif mode == 'sta' then
    wifi.setmode(wifi.STATION, false)
    wifi.sta.config(
      {
        ssid = _Config:get('wifi.sta.ssid'),
        pwd  = _Crypt:decrypt(_Config:get('wifi.sta.password')),
        save = false
      }
    )
  else
    error(('Bad wifi.mode \'%s\''):format(mode))
  end
end

network_module.scan_ap = function(call)
  wifi.sta.getap(1, call)
end

return network_module
