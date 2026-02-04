_Consts = {
  ['name']               = 'nmcus', -- CHANGE
  ['version']            = '0.0',
  ['config.file_name']   = 'config.data',
  ['log.size']           = 10,
  ['wifi.ap.mac']        = wifi.ap.getmac(),
  ['wifi.sta.mac']       = wifi.sta.getmac(),
  ['telnetd.port']       = 23,
  ['telnetd.timeout']    = 180,
  ['spar.file_name']     = 'http.spar',
  ['api.api_prefix']     = '/api/',
  ['api.ap.index_file']  = 'index.ap.html',
  ['api.sta.index_file'] = 'index.sta.html',
  ['httpd.port']         = 80,
  ['httpd.timeout']      = 180
}

_Log = _Util.new(require('_log'), _Consts['log.size'])

_Crypt = _Util.new(
  require('_crypt'),
  function()
    return ('%s = %s = %s'):format(_Consts['name'], _Consts['wifi.sta.mac'], 'secret'):reverse() -- CHANGE
  end
)

_Config = _Util.new(
  require('_config'),
  _Consts['config.file_name'],
  _Crypt,
  {
    ['wifi.mode']          = 'ap', -- 'ap' or 'sta'
    ['wifi.ap.ssid']       = ('%s - %s'):format(_Consts['name'], _Consts['wifi.ap.mac']:gsub(':', '')),
    ['wifi.ap.password']   = _Crypt:encrypt('12345678'), -- CHANGE
    ['wifi.ap.ip']         = '192.168.1.1',
    ['wifi.ap.netmask']    = '255.255.255.0',
    ['wifi.ap.gateway']    = '192.168.1.1',
    ['wifi.ap.dhcp_start'] = '192.168.1.100',
    ['wifi.sta.ssid']      = '',
    ['wifi.sta.password']  = _Crypt:encrypt(''),
    ['ntp.server']         = 'pool.ntp.org',
    ['telnetd.password']   = _Crypt:encrypt('secret'), -- CHANGE
    ['mqtt.host']          = '',
    ['mqtt.port']          = 8883,
    ['mqtt.tls']           = true,
    ['mqtt.cert']          = '',
    ['mqtt.key']           = '',
    ['mqtt.username']      = '',
    ['mqtt.password']      = '',
    ['mqtt.prefix']        = ('%s/'):format(_Consts['wifi.sta.mac']:gsub(':', ''))
  }
)

_Telnetd = _Util.new(
  require('_telnetd'),
  _Consts['telnetd.port'],
  _Consts['telnetd.timeout'],
  _Config:get('telnetd.password')
)

_Spar = _Util.new(
  require('_spar'),
  _Consts['spar.file_name']
)

_Api = _Util.new(
  require('_api'),
  _Spar,
  _Consts['api.api_prefix'],
  function()
    if _Config:get('wifi.mode') == 'ap' then
      return _Consts['api.ap.index_file']
    end
    return _Consts['api.sta.index_file']
  end
)

_Httpd = _Util.new(
  require('_httpd'),
  _Consts['httpd.port'],
  _Consts['httpd.timeout'],
  _Api
)

_Network = require('_network')
_Network.registers_set(
  {
    ['sta_got_ip'] = function(result)
      _Time.sync()
      _Telnetd:start()
      _Httpd:start()
      print(('==IP %s'):format(result.IP))
    end
  }
)
_Network.start()
