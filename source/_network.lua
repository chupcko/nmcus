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
  if _Config.data['wifi.mode'] == 'ap' then
    wifi.setmode(wifi.SOFTAP, false)
    wifi.ap.setip(
      {
        ip      = _Config.data['wifi.ap.ip'],
        netmask = _Config.data['wifi.ap.netmask'],
        gateway = _Config.data['wifi.ap.gateway'],
        save    = false
      }
    )
    wifi.ap.config(
      {
        ssid    = _Config.data['wifi.ap.ssid'],
        pwd     = _Config.data['wifi.ap.pwd'],
        auth    = wifi.WPA_WPA2_PSK,
        save    = false
      }
    )
    wifi.ap.dhcp.config(
      {
        start = _Config.data['wifi.ap.dhcp_start']
      }
    )
    wifi.ap.dhcp.start()
  elseif _Config.data['wifi.mode'] == 'sta' then
    wifi.setmode(wifi.STATION, false)
    wifi.sta.config(
      {
        ssid = _Config.data['wifi.sta.ssid'],
        pwd  = _Config.data['wifi.sta.pwd'],
        save = false
      }
    )
  else
    error(('Bad wifi.mode \'%s\''):format(_Config.data['wifi.mode']))
  end
end

return network_module
