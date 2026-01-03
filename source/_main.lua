_Names = {
  ['name']  = 'nmcus', -- CHANGE
  ['mac']   = wifi.ap.getmac(),
  ['mac_s'] = wifi.ap.getmac():gsub(':', '')
}

_Config = _Util.new(
  require('_config'),
  'config.data',
  {
    ['telnet.port']        = 23,
    ['telnet.password']    = 'secret', -- CHANGE
    ['telnet.timeout']     = 180,
    ['wifi.mode']          = 'ap', -- 'ap' or 'sta'
    ['wifi.ap.ssid']       = ('%s - %s'):format(_Names.name, _Names.mac_s),
    ['wifi.ap.pwd']        = '12345678',
    ['wifi.ap.ip']         = '192.168.1.1',
    ['wifi.ap.netmask']    = '255.255.255.0',
    ['wifi.ap.gateway']    = '192.168.1.1',
    ['wifi.ap.dhcp_start'] = '192.168.1.100',
    ['wifi.sta.ssid']      = '',
    ['wifi.sta.pwd']       = '',
    ['mqtt.host']          = '',
    ['mqtt.port']          = 8883,
    ['mqtt.tls']           = true,
    ['mqtt.cert']          = '',
    ['mqtt.key']           = '',
    ['mqtt.username']      = '',
    ['mqtt.password']      = '',
    ['mqtt.prefix']        = ('%s/'):format(_Names.mac_s)
  },
  function()
    return ('%s = %s = %s'):format(_Names.name, _Names.mac, 'secret'):reverse() -- CHANGE
  end
)

_Telnet = _Util.new(
  require('_telnet'),
  _Config.data['telnet.port'],
  _Config.data['telnet.password'],
  _Config.data['telnet.timeout']
)
_Network = require('_network')
_Network.register_connected(
  function(result)
    _Util.dump(result)
    _Telnet:start()
  end
)
_Network.start()
