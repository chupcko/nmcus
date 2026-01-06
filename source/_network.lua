local network_module = {}

network_module.register_connected = function(call)
  wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, call)
end

network_module.register_disconnected = function(call)
  wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, call)
end

network_module.register_got_ip = function(call)
  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, call)
end

network_module.register_dhcp_timeout = function(call)
  wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, call)
end

network_module.start = function()
  local mode = _Config:get('wifi.mode')
  if mode == 'ap' then
    wifi.setmode(wifi.SOFTAP, false)
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
        pwd     = _Config:get('wifi.ap.pwd'),
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
        pwd  = _Config:get('wifi.sta.pwd'),
        save = false
      }
    )
  else
    error(('Bad wifi.mode \'%s\''):format(mode))
  end
end

return network_module
