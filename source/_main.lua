_Consts = {
  ['name']             = 'nmcus', -- CHANGE
  ['version']          = '0.0',
  ['wifi.ap.mac']      = wifi.ap.getmac(),
  ['wifi.sta.mac']     = wifi.sta.getmac(),
  ['log.size']         = 10,
  ['config.file_name'] = 'config.data',
  ['spar.file_name']   = 'http.spar',
  ['api.index_file']   = 'index.html',
  ['telnetd.port']     = 23,
  ['telnetd.timeout']  = 180,
  ['httpd.port']       = 80,
  ['httpd.timeout']    = 180
}

_Config = _Util.new(
  require('_config'),
  _Consts['config.file_name'],
  {
    ['telnetd.password']   = 'secret', -- CHANGE
    ['wifi.mode']          = 'ap', -- 'ap' or 'sta'
    ['wifi.ap.ssid']       = ('%s - %s'):format(_Consts['name'], _Consts['wifi.ap.mac']:gsub(':', '')),
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
    ['mqtt.prefix']        = ('%s/'):format(_Consts['wifi.sta.mac']:gsub(':', ''))
  },
  function()
    return ('%s = %s = %s'):format(_Consts['name'], _Consts['wifi.sta.mac'], 'secret'):reverse() -- CHANGE
  end
)

_Log = _Util.new(require('_log'), _Consts['log.size'])

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

_Api = require('_api')

_Httpd = _Util.new(
  require('_httpd'),
  _Consts['httpd.port'],
  _Consts['httpd.timeout'],
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
