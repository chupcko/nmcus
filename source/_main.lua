_Consts = {
  ['name']            = 'nmcus', -- CHANGE
  ['version']         = '0.0',
  ['ap_mac']          = wifi.ap.getmac(),
  ['ap_mac_s']        = wifi.ap.getmac():gsub(':', ''),
  ['sta_mac']         = wifi.sta.getmac(),
  ['sta_mac_s']       = wifi.sta.getmac():gsub(':', ''),
  ['log_size']        = 10,
  ['spar_file_name']  = 'http.spar'
}

_Config = _Util.new(
  require('_config'),
  'config.data',
  {
    ['telnetd.port']       = 23,
    ['telnetd.timeout']    = 180,
    ['telnetd.password']   = 'secret', -- CHANGE
    ['httpd.port']         = 80,
    ['httpd.timeout']      = 180,
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

_Telnetd = _Util.new(
  require('_telnetd'),
  _Config:get('telnetd.port'),
  _Config:get('telnetd.timeout'),
  _Config:get('telnetd.password')
)

_Spar = _Util.new(
  require('_spar'),
  _Consts.spar_file_name
)

_Api = require('_api')

_Httpd = _Util.new(
  require('_httpd'),
  _Config:get('httpd.port'),
  _Config:get('httpd.timeout'),
  _Api.execute
)

_Network = require('_network')
_Network.registers_set(
  {
    ['sta_got_ip'] = function(result)
      _Time.sync()
      _Telnetd:start()
      _Httpd:start()
      print('Got IP')
    end
  }
)
_Network.start()
