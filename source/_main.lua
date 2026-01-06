_Consts = {
  ['name']      = 'nmcus', -- CHANGE
  ['version']   = '0.0',
  ['ap_mac']    = wifi.ap.getmac(),
  ['ap_mac_s']  = wifi.ap.getmac():gsub(':', ''),
  ['sta_mac']   = wifi.sta.getmac(),
  ['sta_mac_s'] = wifi.sta.getmac():gsub(':', ''),
  ['log_size']  = 10
}

_Config = _Util.new(
  require('_config'),
  'config.data',
  {
    ['telnet.port']        = 23,
    ['telnet.password']    = 'secret', -- CHANGE
    ['telnet.timeout']     = 180,
    ['wifi.mode']          = 'ap', -- 'ap' or 'sta'
    ['wifi.ap.ssid']       = ('%s - %s'):format(_Consts.name, _Consts.ap_mac_s),
    ['wifi.ap.pwd']        = '12345678',
    ['wifi.ap.ip']         = '192.168.1.1',
    ['wifi.ap.netmask']    = '255.255.255.0',
    ['wifi.ap.gateway']    = '192.168.1.1',
    ['wifi.ap.dhcp_start'] = '192.168.1.100',
    ['wifi.sta.ssid']      = '',
    ['wifi.sta.pwd']       = '',
    ['ntp.server']         = 'pool.ntp.org',
    ['mqtt.host']          = '',
    ['mqtt.port']          = 8883,
    ['mqtt.tls']           = true,
    ['mqtt.cert']          = '',
    ['mqtt.key']           = '',
    ['mqtt.username']      = '',
    ['mqtt.password']      = '',
    ['mqtt.prefix']        = ('%s/'):format(_Consts.sta_mac_s)
  },
  function()
    return ('%s = %s = %s'):format(_Consts.name, _Consts.sta_mac, 'secret'):reverse() -- CHANGE
  end
)

_Log = _Util.new(require('_log'), _Consts.log_size)
_Telnet = _Util.new(
  require('_telnet'),
  _Config:get('telnet.port'),
  _Config:get('telnet.password'),
  _Config:get('telnet.timeout')
)
_Network = require('_network')
_Network.register_set(
  {
    ['sta_got_ip'] = function(result)
      _Time.sync()
      _Telnet:start()
    end
  }
)
_Network.start()
